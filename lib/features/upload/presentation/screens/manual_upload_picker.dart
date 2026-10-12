import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/video_upload_item.dart';
import '../providers/upload_providers.dart';

/// Opens the system picker and enqueues the chosen videos through the shared
/// UploadManager. Returns how many were skipped as duplicates.
Future<int> pickAndEnqueueVideos(WidgetRef ref) async {
  final files = await FilePicker.pickFiles(type: FileType.video);
  final manager = ref.read(uploadManagerProvider);
  var duplicates = 0;
  for (final f in files) {
    final path = f.path;
    if (path == null) continue;
    final file = File(path);
    final item = await manager.enqueue(NewVideo(
      contentUri: file.uri.toString(),
      localPath: path,
      fileName: f.name,
      fileSize: await file.length(),
      dateTaken: file.lastModifiedSync(),
    ));
    if (item == null) duplicates++;
  }
  await ref.read(uploadTriggerProvider)();
  return duplicates;
}
