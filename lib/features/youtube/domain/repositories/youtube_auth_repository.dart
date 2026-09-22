import '../entities/auth_state.dart';

/// The single seam every other feature (playlists, upload) will call through
/// to get a usable access token — designed now so later phases never need to
/// touch this interface, only add new callers of [getValidAccessToken].
abstract interface class YoutubeAuthRepository {
  /// Runs the full OAuth authorization-code + PKCE flow, persists tokens
  /// securely, fetches and caches the connected channel, and emits
  /// [AuthConnected] on success.
  Future<void> connect();

  /// Revokes the refresh token best-effort, clears all local state, and
  /// emits [AuthDisconnected].
  Future<void> disconnect();

  /// Returns a non-expired access token, transparently refreshing it first
  /// if needed. Throws [ReauthRequiredException] (see core/error) if the
  /// refresh token is missing or has been revoked.
  Future<String> getValidAccessToken();

  AuthState get currentState;

  Stream<AuthState> watchAuthState();
}
