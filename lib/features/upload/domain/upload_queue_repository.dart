import 'entities/upload_status.dart';
import 'entities/video_upload_item.dart';

abstract class UploadQueueRepository {
  Stream<List<VideoUploadItem>> watchAll();
  Future<VideoUploadItem?> get(String id);

  /// Inserts the video unless it is a duplicate (same MediaStore id, content
  /// URI, or name+size+dateTaken as a non-cancelled item). Returns null for
  /// duplicates.
  Future<VideoUploadItem?> enqueue(NewVideo video, {String? playlistId});

  /// Oldest item that is WAITING, or ADDING_TO_PLAYLIST left over from an
  /// interrupted run.
  Future<VideoUploadItem?> nextPending({Set<String> excluding = const {}});

  Future<void> update(
    String id, {
    UploadStatus? status,
    double? progress,
    String? youtubeVideoId,
    String? sessionUri,
    String? privacyStatus,
    String? playlistId,
    int? retryCount,
    String? errorMessage,
    bool clearError = false,
    bool clearSessionUri = false,
  });

  /// After a crash/restart: PREPARING/UPLOADING/PROCESSING items go back to
  /// WAITING. Items that already have a YouTube id keep ADDING_TO_PLAYLIST.
  Future<void> resetInterrupted();

  Future<void> delete(String id);

  /// Forgets a deleted playlist on queued items so they fall back to the
  /// currently selected one.
  Future<void> clearPlaylist(String playlistId);

  Future<void> markOriginalsDeleted(Iterable<String> ids);
}
