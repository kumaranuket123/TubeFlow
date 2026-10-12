import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permissions/media_permission_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../upload/presentation/providers/upload_providers.dart';
import '../../../upload/domain/entities/video_upload_item.dart';
import '../../data/media_store_service_impl.dart';
import '../../domain/original_cleanup_service.dart';
import '../../domain/media_video.dart';
import '../../domain/video_scanner_service.dart';

final mediaPermissionServiceProvider =
    Provider<MediaPermissionService>((ref) => MediaPermissionService());

final mediaStoreServiceProvider =
    Provider<MediaStoreService>((ref) => MediaStoreServiceImpl());

final videoScannerServiceProvider = Provider<VideoScannerService>((ref) {
  return VideoScannerService(
    mediaStore: ref.watch(mediaStoreServiceProvider),
    manager: ref.watch(uploadManagerProvider),
    settings: ref.watch(settingsRepositoryProvider),
  );
});

final originalCleanupServiceProvider = Provider<OriginalCleanupService>((ref) {
  return OriginalCleanupService(
    queue: ref.watch(uploadQueueRepositoryProvider),
    mediaStore: ref.watch(mediaStoreServiceProvider),
    settings: ref.watch(settingsRepositoryProvider),
  );
});

/// Uploaded originals waiting for the user's delete confirmation (only when
/// Keep original is OFF).
final deletableOriginalsProvider = Provider<List<VideoUploadItem>>((ref) {
  final keep = ref.watch(appSettingsProvider.select((a) => a.value?.keepOriginal ?? true));
  if (keep) return const [];
  final items = ref.watch(uploadQueueProvider).value ?? const [];
  return items.where((i) => i.originalDeletable).toList();
});
