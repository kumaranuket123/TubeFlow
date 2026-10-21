import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../youtube/presentation/open_playlist.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/video_upload_item.dart';
import '../providers/upload_providers.dart';

/// "Queue" heading with bulk actions: cancel everything that is pending or
/// uploading, or clear the finished entries from the list.
class QueueHeader extends ConsumerWidget {
  const QueueHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(uploadQueueProvider).value ?? const [];
    final open = items.where((i) => !i.status.isTerminal).length;
    final finished = items.where((i) => i.clearable).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text('Queue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          PopupMenuButton<String>(
            tooltip: 'Queue actions',
            enabled: items.isNotEmpty,
            onSelected: (v) => v == 'cancel'
                ? _cancelAll(context, ref, open)
                : _clear(context, ref, finished),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'cancel',
                enabled: open > 0,
                child: Text('Cancel all uploads ($open)'),
              ),
              PopupMenuItem(
                value: 'clear',
                enabled: finished > 0,
                child: Text('Clear finished ($finished)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String body,
    String action,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _cancelAll(BuildContext context, WidgetRef ref, int n) async {
    final messenger = ScaffoldMessenger.of(context);
    final manager = ref.read(uploadManagerProvider);
    if (!await _confirm(
      context,
      'Cancel $n upload${n == 1 ? '' : 's'}?',
      'Waiting and in-progress uploads are stopped. You can retry any of '
          'them from the list. Videos already on YouTube are not touched.',
      'Cancel all',
    )) {
      return;
    }
    final done = await manager.cancelAll();
    messenger.showSnackBar(
      SnackBar(content: Text('Cancelled $done upload(s).')),
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref, int n) async {
    final messenger = ScaffoldMessenger.of(context);
    final manager = ref.read(uploadManagerProvider);
    if (!await _confirm(
      context,
      'Clear $n finished item${n == 1 ? '' : 's'}?',
      'Completed, failed and cancelled entries are removed from this list. '
          'Nothing is deleted from YouTube or your phone.',
      'Clear',
    )) {
      return;
    }
    final done = await manager.clearFinished();
    messenger.showSnackBar(SnackBar(content: Text('Cleared $done item(s).')));
  }
}

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
      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
      data: (items) => items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No uploads yet.')),
            )
          : Column(
              children: [
                for (final i in _uploadingFirst(items)) _QueueTile(item: i),
              ],
            ),
    );
  }
}

/// Items being worked on go to the top, then waiting ones, then finished
/// ones; the existing (newest-first) order is kept within each group.
List<VideoUploadItem> _uploadingFirst(List<VideoUploadItem> items) {
  int rank(VideoUploadItem i) => i.status.isInFlight
      ? 0
      : i.status == UploadStatus.waiting
      ? 1
      : 2;
  final indexed = items.indexed.toList()
    ..sort((a, b) {
      final r = rank(a.$2).compareTo(rank(b.$2));
      return r != 0 ? r : a.$1.compareTo(b.$1);
    });
  return [for (final e in indexed) e.$2];
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
        UploadStatus.completed => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.youtubeVideoId != null)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Open video on YouTube',
                onPressed: () =>
                    openVideoOnYoutube(context, item.youtubeVideoId!),
              ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove from list',
              onPressed: () => manager.remove(item.id),
            ),
          ],
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
