import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Turns a failed YouTube HTTP call into the exception the upload pipeline
/// understands, with the user-facing wording:
///  - no response / 5xx  → [TransientUploadException] (retried automatically)
///  - 401                → [ReauthRequiredException]
///  - quota reasons      → "YouTube upload quota reached. Try again later."
///  - playlist missing   → "Selected playlist is no longer available."
///  - anything else      → [YoutubeApiException] with [fallback]
/// Cancelled requests must be rethrown by the caller before mapping.
Exception mapYoutubeDioError(
  DioException e, {
  String fallback = 'Request to YouTube failed',
  bool notFoundIsPlaylist = false,
}) {
  final code = e.response?.statusCode;
  if (code == null || code >= 500) return const TransientUploadException();
  if (code == 401) return const ReauthRequiredException();

  final message = switch (youtubeErrorReason(e.response?.data)) {
    'quotaExceeded' ||
    'uploadLimitExceeded' ||
    'dailyLimitExceeded' ||
    'rateLimitExceeded' =>
      'YouTube upload quota reached. Try again later.',
    'playlistNotFound' => 'Selected playlist is no longer available.',
    'forbidden' || 'insufficientPermissions' =>
      'YouTube denied the request. Please reconnect your YouTube account.',
    _ when code == 404 && notFoundIsPlaylist =>
      'Selected playlist is no longer available.',
    _ => fallback,
  };
  return YoutubeApiException(message, statusCode: code);
}

/// `error.errors[0].reason` from a YouTube API error body, if present.
String? youtubeErrorReason(dynamic body) {
  try {
    return body['error']['errors'][0]['reason'] as String?;
  } catch (_) {
    return null;
  }
}
