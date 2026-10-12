import '../../settings/domain/settings_repository.dart';
import '../../upload/domain/entities/video_upload_item.dart';
import '../../upload/domain/upload_queue_repository.dart';
import 'media_video.dart';

/// "Keep original video: OFF". Originals are only ever deleted when
///  - the user turned Keep original off,
///  - the upload is COMPLETED (video on YouTube and in the playlist), and
///  - the user confirms in Android's own delete dialog (never silent).
/// The queue row is kept so the video is never uploaded again.
class OriginalCleanupService {
  OriginalCleanupService({
    required UploadQueueRepository queue,
    required MediaStoreService mediaStore,
    required SettingsRepository settings,
  })  : _queue = queue,
        _mediaStore = mediaStore,
        _settings = settings;

  final UploadQueueRepository _queue;
  final MediaStoreService _mediaStore;
  final SettingsRepository _settings;

  /// Returns how many originals were deleted (0 if refused or kept).
  Future<int> deleteUploadedOriginals(List<VideoUploadItem> items) async {
    if ((await _settings.get()).keepOriginal) return 0;
    final targets = items.where((i) => i.originalDeletable).toList();
    if (targets.isEmpty) return 0;
    final confirmed =
        await _mediaStore.deleteVideos(targets.map((i) => i.contentUri).toList());
    if (!confirmed) return 0;
    await _queue.markOriginalsDeleted(targets.map((i) => i.id));
    return targets.length;
  }
}
