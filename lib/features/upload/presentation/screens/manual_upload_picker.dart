import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../media/domain/media_video.dart';
import '../../data/shared_video_service.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../../domain/entities/video_upload_item.dart';
import '../providers/upload_providers.dart';

/// Opens the system picker and enqueues the chosen videos through the shared
/// UploadManager. Returns how many were skipped as duplicates.
Future<int> pickAndEnqueueVideos(WidgetRef ref) async {
  final files = await FilePicker.pickFiles(type: FileType.video);
  final manager = ref.read(uploadManagerProvider);
  var duplicates = 0;
  final library = await _mediaLibrary(ref);
  for (final f in files) {
    final path = f.path;
    if (path == null) continue;
    final file = File(path);
    final size = await file.length();
    // The picker may hand back a cache copy. Link it to the real MediaStore
    // row (same name + size) so the original can be offered for deletion and
    // the scanner never uploads it a second time.
    final match = library
        .where((v) => v.name == f.name && v.size == size)
        .firstOrNull;
    final item = await manager.enqueue(NewVideo(
      mediaStoreId: match?.id,
      contentUri: match?.uri ?? file.uri.toString(),
      localPath: path,
      fileName: f.name,
      fileSize: size,
      dateTaken: file.lastModifiedSync(),
    ));
    if (item == null) duplicates++;
  }
  await ref.read(uploadTriggerProvider)();
  return duplicates;
}

/// All MediaStore videos, or empty if the permission is missing or the query
/// fails (the upload itself does not need it).
Future<List<MediaVideo>> _mediaLibrary(WidgetRef ref) async {
  try {
    return await ref.read(mediaStoreServiceProvider).queryVideos();
  } catch (_) {
    return const [];
  }
}

/// Enqueues videos shared from another app. Returns how many were skipped as
/// duplicates.
Future<int> enqueueSharedVideos(WidgetRef ref, List<SharedVideo> videos) async {
  final manager = ref.read(uploadManagerProvider);
  var duplicates = 0;
  for (final v in videos) {
    final item = await manager.enqueue(NewVideo(
      mediaStoreId: v.mediaStoreId,
      contentUri: v.uri,
      localPath: v.path,
      fileName: v.name,
      fileSize: v.size,
      dateTaken: File(v.path).lastModifiedSync(),
    ));
    if (item == null) duplicates++;
  }
  await ref.read(uploadTriggerProvider)();
  return duplicates;
}
