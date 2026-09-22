/// Thrown when a stored refresh token is no longer valid (revoked, expired,
/// or never existed) and the user must go through the OAuth flow again.
class ReauthRequiredException implements Exception {
  const ReauthRequiredException([this.message = 'Please reconnect your YouTube account']);

  final String message;

  @override
  String toString() => message;
}

/// Thrown for any unexpected failure talking to a Google/YouTube endpoint.
class YoutubeApiException implements Exception {
  const YoutubeApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'YoutubeApiException($statusCode): $message';
}
