import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/youtube_api_remote_datasource.dart';
import '../../data/datasources/youtube_auth_appauth_datasource.dart';
import '../../data/repositories/youtube_auth_repository_impl.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/youtube_auth_repository.dart';
import '../../domain/usecases/connect_account.dart';
import '../../domain/usecases/disconnect_account.dart';
import '../../domain/usecases/get_valid_access_token.dart';

final youtubeAuthAppAuthDataSourceProvider =
    Provider<YoutubeAuthAppAuthDataSource>((ref) {
  return YoutubeAuthAppAuthDataSource(ref.watch(flutterAppAuthProvider));
});

final youtubeApiRemoteDataSourceProvider =
    Provider<YoutubeApiRemoteDataSource>((ref) {
  return YoutubeApiRemoteDataSource(ref.watch(dioProvider));
});

final youtubeAuthRepositoryProvider = Provider<YoutubeAuthRepository>((ref) {
  return YoutubeAuthRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    appAuthDataSource: ref.watch(youtubeAuthAppAuthDataSourceProvider),
    apiDataSource: ref.watch(youtubeApiRemoteDataSourceProvider),
    dio: ref.watch(dioProvider),
  );
});

final connectAccountProvider = Provider<ConnectAccount>((ref) {
  return ConnectAccount(ref.watch(youtubeAuthRepositoryProvider));
});

final disconnectAccountProvider = Provider<DisconnectAccount>((ref) {
  return DisconnectAccount(ref.watch(youtubeAuthRepositoryProvider));
});

/// The provider every other feature (playlists, upload) should depend on to
/// obtain a usable access token.
final getValidAccessTokenProvider = Provider<GetValidAccessToken>((ref) {
  return GetValidAccessToken(ref.watch(youtubeAuthRepositoryProvider));
});

final youtubeAuthControllerProvider =
    NotifierProvider<YoutubeAuthController, AuthState>(
  YoutubeAuthController.new,
);

class YoutubeAuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repository = ref.watch(youtubeAuthRepositoryProvider);

    // Mirror the repository's own state stream (which restores from the
    // Drift cache on startup and is updated by connect/disconnect) into this
    // Notifier, so widgets only ever depend on Riverpod, never the
    // repository directly.
    final subscription = repository.watchAuthState().listen((s) => state = s);
    ref.onDispose(subscription.cancel);

    // After an optimistic cache restore, silently verify the token is still
    // usable. A failure here downgrades to AuthDisconnected via the
    // repository itself (getValidAccessToken clears state on
    // ReauthRequiredException), so no explicit handling is needed beyond
    // swallowing the exception.
    Future.microtask(() async {
      try {
        await ref.read(getValidAccessTokenProvider).call();
      } on ReauthRequiredException {
        // Repository already downgraded state to AuthDisconnected.
      } catch (_) {
        // Network hiccup on startup shouldn't force a disconnect; the
        // cached "connected" UI stays until the user tries an action that
        // needs a token.
      }
    });

    return repository.currentState;
  }

  Future<void> connect() => ref.read(connectAccountProvider).call();

  Future<void> disconnect() => ref.read(disconnectAccountProvider).call();
}
