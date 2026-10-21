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

/// The daily YouTube API quota (or the channel's daily upload limit) is used
/// up. Unlike other API errors this is not the video's fault: the queue
/// pauses until the quota resets instead of failing items.
class QuotaExceededException extends YoutubeApiException {
  const QuotaExceededException(super.message, {super.statusCode});
}

/// A recoverable failure (network loss, 5xx) after in-request retries were
/// exhausted. The upload keeps its session and is retried later.
class TransientUploadException implements Exception {
  const TransientUploadException([this.message = 'Upload interrupted. Retrying...']);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when the signed-in Google account has no YouTube channel yet.
class NoYoutubeChannelException implements Exception {
  const NoYoutubeChannelException();

  @override
  String toString() => 'No YouTube channel found for this Google account';
}
