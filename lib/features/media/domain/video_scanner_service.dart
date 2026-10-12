import 'dart:io';

import '../../settings/domain/settings_repository.dart';
import '../../upload/domain/entities/video_upload_item.dart';
import '../../upload/domain/upload_manager.dart';
import 'media_video.dart';

class ScanResult {
  const ScanResult({
    this.found = 0,
    this.added = 0,
    this.duplicates = 0,
    this.unstable = 0,
    this.unreadable = 0,
  });

  final int found;
  final int added;
  final int duplicates;

  /// Still being written (size changing); picked up by a later scan.
  final int unstable;
  final int unreadable;
}

/// Finds finished camera recordings in MediaStore and enqueues unseen ones.
/// Never uploads a partial file: MediaStore excludes IS_PENDING rows, and a
/// size-stability check (MediaStore size and file length equal, and
/// unchanged after [stabilityDelay]) guards cameras that don't use the flag.
class VideoScannerService {
  VideoScannerService({
    required MediaStoreService mediaStore,
    required UploadManager manager,
    required SettingsRepository settings,
    this.stabilityDelay = const Duration(seconds: 2),
    this.lookback = const Duration(hours: 24),
  })  : _mediaStore = mediaStore,
        _manager = manager,
        _settings = settings;

  final MediaStoreService _mediaStore;
  final UploadManager _manager;
  final SettingsRepository _settings;
  final Duration stabilityDelay;
  final Duration lookback;

  bool _scanning = false;

  /// Throws `MediaPermissionDeniedException` without video access.
  Future<ScanResult> scan() async {
    if (_scanning) return const ScanResult();
    _scanning = true;
    try {
      final baseline = await _settings.ensureScanBaseline();
      final videos = await _mediaStore.queryVideos(since: baseline.subtract(lookback));

      final readable = <MediaVideo>[];
      var unreadable = 0;
      for (final v in videos) {
        if (_fileLength(v) == null) {
          unreadable++;
        } else {
          readable.add(v);
        }
      }

      // Snapshot sizes, wait once, compare.
      final before = {for (final v in readable) v.uri: _fileLength(v)};
      if (readable.isNotEmpty) await Future<void>.delayed(stabilityDelay);

      var added = 0, duplicates = 0, unstable = 0;
      for (final v in readable) {
        final after = _fileLength(v);
        final storeSize = await _mediaStore.currentSize(v.uri);
        final stable = after != null &&
            after > 0 &&
            after == before[v.uri] &&
            after == v.size &&
            (storeSize == null || storeSize == after);
        if (!stable) {
          unstable++;
          continue;
        }
        final item = await _manager.enqueue(NewVideo(
          mediaStoreId: v.id,
          contentUri: v.uri,
          localPath: v.path,
          fileName: v.name,
          fileSize: v.size,
          dateTaken: v.createdAt,
        ));
        item == null ? duplicates++ : added++;
      }
      return ScanResult(
        found: videos.length,
        added: added,
        duplicates: duplicates,
        unstable: unstable,
        unreadable: unreadable,
      );
    } finally {
      _scanning = false;
    }
  }

  int? _fileLength(MediaVideo v) {
    final path = v.path;
    if (path == null) return null;
    try {
      final f = File(path);
      return f.existsSync() ? f.lengthSync() : null;
    } on FileSystemException {
      return null;
    }
  }
}
