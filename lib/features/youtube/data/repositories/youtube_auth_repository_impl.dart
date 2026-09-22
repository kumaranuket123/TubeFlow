import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../../core/constants/youtube_api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/security/secure_token_storage.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/youtube_channel.dart';
import '../../domain/repositories/youtube_auth_repository.dart';
import '../datasources/youtube_api_remote_datasource.dart';
import '../datasources/youtube_auth_appauth_datasource.dart';

/// The token is refreshed a little before its real expiry to avoid a race
/// where a request is sent with a token that expires mid-flight.
const _expiryBuffer = Duration(seconds: 60);

class YoutubeAuthRepositoryImpl implements YoutubeAuthRepository {
  YoutubeAuthRepositoryImpl({
    required AppDatabase database,
    required SecureTokenStorage tokenStorage,
    required YoutubeAuthAppAuthDataSource appAuthDataSource,
    required YoutubeApiRemoteDataSource apiDataSource,
    required Dio dio,
  })  : _database = database,
        _tokenStorage = tokenStorage,
        _appAuthDataSource = appAuthDataSource,
        _apiDataSource = apiDataSource,
        _dio = dio {
    unawaited(_restoreFromCache());
  }

  final AppDatabase _database;
  final SecureTokenStorage _tokenStorage;
  final YoutubeAuthAppAuthDataSource _appAuthDataSource;
  final YoutubeApiRemoteDataSource _apiDataSource;
  final Dio _dio;

  AuthState _state = const AuthInitial();
  final _controller = StreamController<AuthState>.broadcast();

  @override
  AuthState get currentState => _state;

  @override
  Stream<AuthState> watchAuthState() => _controller.stream;

  void _emit(AuthState state) {
    _state = state;
    _controller.add(state);
  }

  Future<void> _restoreFromCache() async {
    final row = await (_database.select(_database.youtubeAccounts)
          ..limit(1))
        .getSingleOrNull();
    if (row != null) {
      _emit(AuthConnected(YoutubeChannel(
        channelId: row.channelId,
        title: row.channelTitle,
        thumbnailUrl: row.channelThumbnailUrl,
      )));
    } else {
      _emit(const AuthDisconnected());
    }
  }

  @override
  Future<void> connect() async {
    _emit(const AuthLoading());
    try {
      final tokenResult = await _appAuthDataSource.authorizeAndExchange();
      await _tokenStorage.saveTokens(
        accessToken: tokenResult.accessToken,
        refreshToken: tokenResult.refreshToken,
        accessTokenExpiry: tokenResult.accessTokenExpiry,
      );

      final channel = await _apiDataSource.getMyChannel(tokenResult.accessToken);
      await _cacheChannel(channel);

      _emit(AuthConnected(channel));
    } catch (e) {
      _emit(AuthError('Could not connect YouTube account: $e'));
    }
  }

  Future<void> _cacheChannel(YoutubeChannel channel) async {
    await _database.transaction(() async {
      await _database.delete(_database.youtubeAccounts).go();
      await _database.into(_database.youtubeAccounts).insert(
            YoutubeAccountsCompanion.insert(
              channelId: channel.channelId,
              channelTitle: channel.title,
              channelThumbnailUrl: Value(channel.thumbnailUrl),
              connectedAt: DateTime.now(),
            ),
          );
    });
  }

  @override
  Future<String> getValidAccessToken() async {
    final expiry = await _tokenStorage.readAccessTokenExpiry();
    final cachedAccessToken = await _tokenStorage.readAccessToken();

    final isStillValid = cachedAccessToken != null &&
        expiry != null &&
        DateTime.now().isBefore(expiry.subtract(_expiryBuffer));

    if (isStillValid) {
      return cachedAccessToken;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      await _handleReauthRequired();
      throw const ReauthRequiredException();
    }

    try {
      final refreshed = await _appAuthDataSource.refresh(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: refreshed.accessToken,
        // Google doesn't always reissue a refresh token on refresh; keep the
        // existing one when it doesn't.
        refreshToken: refreshed.refreshToken ?? refreshToken,
        accessTokenExpiry: refreshed.accessTokenExpiry,
      );
      return refreshed.accessToken;
    } catch (_) {
      await _handleReauthRequired();
      throw const ReauthRequiredException();
    }
  }

  Future<void> _handleReauthRequired() async {
    await _tokenStorage.clear();
    await _database.delete(_database.youtubeAccounts).go();
    _emit(const AuthDisconnected());
  }

  @override
  Future<void> disconnect() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    final accessToken = await _tokenStorage.readAccessToken();
    final tokenToRevoke = refreshToken ?? accessToken;

    if (tokenToRevoke != null) {
      try {
        await _dio.post<void>(
          YoutubeApiConstants.revokeEndpoint,
          data: {'token': tokenToRevoke},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );
      } catch (_) {
        // Best-effort: even if the revoke call fails (offline, already
        // revoked, etc.), we still clear all local state below.
      }
    }

    await _tokenStorage.clear();
    await _database.delete(_database.youtubeAccounts).go();
    _emit(const AuthDisconnected());
  }
}
