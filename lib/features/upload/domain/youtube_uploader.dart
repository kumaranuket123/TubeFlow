import 'dart:io';

import 'package:dio/dio.dart';

/// The YouTube operations the upload pipeline needs. Each call obtains a
/// fresh valid access token itself (so long uploads survive token expiry
/// between steps) and throws `ReauthRequiredException` / `YoutubeApiException`.
abstract class YoutubeUploader {
  /// Resumable: pass the stored [sessionUri] to continue an interrupted
  /// upload; [onSessionStarted] must persist a new session URI before bytes
  /// are sent. Throws `TransientUploadException` for recoverable failures.
  Future<String> uploadVideo({
    required File file,
    required String title,
    required String description,
    required String privacyStatus,
    String? sessionUri,
    required Future<void> Function(String sessionUri) onSessionStarted,
    required void Function(double) onProgress,
    required CancelToken cancelToken,
  });

  /// The video's current `privacyStatus`, or null if YouTube does not (yet)
  /// return it.
  Future<String?> privacyStatusOf(String videoId);

  Future<void> addToPlaylist(String playlistId, String videoId);
}
