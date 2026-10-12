import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_status.dart';
import '../../domain/entities/video_upload_item.dart';
import '../providers/upload_providers.dart';

class UploadQueueList extends ConsumerWidget {
  const UploadQueueList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(uploadQueueProvider);
    return queue.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
      data: (items) => items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No uploads yet.')),
            )
          : Column(children: [for (final i in items) _QueueTile(item: i)]),
    );
  }
}

String _label(VideoUploadItem i) => switch (i.status) {
      UploadStatus.waiting => i.errorMessage ?? 'Waiting',
      UploadStatus.preparing => 'Preparing',
      UploadStatus.uploading => 'Uploading ${(i.progress * 100).round()}%',
      UploadStatus.processing => 'Verifying',
      UploadStatus.addingToPlaylist => 'Adding to playlist',
      UploadStatus.completed => '✓ Completed',
      UploadStatus.failed => i.errorMessage ?? 'Failed',
      UploadStatus.cancelled => 'Cancelled',
    };

class _QueueTile extends ConsumerWidget {
  const _QueueTile({required this.item});

  final VideoUploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(uploadManagerProvider);
    final s = item.status;
    return ListTile(
      leading: const Icon(Icons.movie),
      title: Text(item.fileName, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s == UploadStatus.uploading)
            LinearProgressIndicator(value: item.progress),
          Text(
            _label(item),
            style: s == UploadStatus.failed
                ? TextStyle(color: Theme.of(context).colorScheme.error)
                : null,
          ),
        ],
      ),
      trailing: switch (s) {
        UploadStatus.failed || UploadStatus.cancelled => IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Retry',
            onPressed: () async {
              await manager.retry(item.id, autoStart: false);
              await ref.read(uploadTriggerProvider)();
            },
          ),
        UploadStatus.completed => IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Remove from list',
            onPressed: () => manager.remove(item.id),
          ),
        _ => IconButton(
            icon: const Icon(Icons.cancel_outlined),
            tooltip: 'Cancel',
            onPressed: () => manager.cancel(item.id),
          ),
      },
    );
  }
}
