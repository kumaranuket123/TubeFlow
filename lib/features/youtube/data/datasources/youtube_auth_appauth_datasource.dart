import 'package:flutter_appauth/flutter_appauth.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/youtube_api_constants.dart';

/// Result of a successful authorization or refresh call.
class AppAuthTokenResult {
  const AppAuthTokenResult({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
  });

  final String accessToken;

  /// Null on a refresh response if Google didn't reissue one — callers must
  /// keep the previously stored refresh token in that case.
  final String? refreshToken;
  final DateTime? accessTokenExpiry;
}

/// Thin wrapper around [FlutterAppAuth] — the only place in the app that
/// talks to the AppAuth plugin directly.
class YoutubeAuthAppAuthDataSource {
  YoutubeAuthAppAuthDataSource(this._appAuth);

  final FlutterAppAuth _appAuth;

  static const _serviceConfiguration = AuthorizationServiceConfiguration(
    authorizationEndpoint: YoutubeApiConstants.authorizationEndpoint,
    tokenEndpoint: YoutubeApiConstants.tokenEndpoint,
  );

  /// Runs the PKCE authorization-code flow via Chrome Custom Tabs.
  ///
  /// `promptValues: ['consent']` + `access_type=offline` are required on
  /// every call (not just first-ever connect) so Google reliably reissues a
  /// refresh token even for a user reconnecting after a prior disconnect.
  Future<AppAuthTokenResult> authorizeAndExchange() async {
    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        kGoogleOAuthClientId,
        kOAuthRedirectUri,
        serviceConfiguration: _serviceConfiguration,
        scopes: YoutubeApiConstants.scopes,
        promptValues: const ['consent'],
        additionalParameters: const {'access_type': 'offline'},
      ),
    );

    return AppAuthTokenResult(
      accessToken: response.accessToken!,
      refreshToken: response.refreshToken,
      accessTokenExpiry: response.accessTokenExpirationDateTime,
    );
  }

  Future<AppAuthTokenResult> refresh(String refreshToken) async {
    final response = await _appAuth.token(
      TokenRequest(
        kGoogleOAuthClientId,
        kOAuthRedirectUri,
        serviceConfiguration: _serviceConfiguration,
        refreshToken: refreshToken,
        grantType: 'refresh_token',
        scopes: YoutubeApiConstants.scopes,
      ),
    );

    return AppAuthTokenResult(
      accessToken: response.accessToken!,
      refreshToken: response.refreshToken,
      accessTokenExpiry: response.accessTokenExpirationDateTime,
    );
  }
}
