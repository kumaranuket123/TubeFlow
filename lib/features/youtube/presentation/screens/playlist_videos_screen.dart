import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/quota/quota_tracker.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../upload/domain/upload_manager.dart';
import '../../domain/entities/youtube_playlist.dart';
import '../../domain/services/youtube_playlist_service.dart';
import '../open_playlist.dart';
import '../providers/youtube_auth_providers.dart';

/// Lists a playlist's videos and lets the user multi-select them to switch
/// their visibility to private or unlisted.
class PlaylistVideosScreen extends ConsumerStatefulWidget {
  const PlaylistVideosScreen({super.key, required this.playlist});

  final YoutubePlaylist playlist;

  @override
  ConsumerState<PlaylistVideosScreen> createState() =>
      _PlaylistVideosScreenState();
}

class _PlaylistVideosScreenState extends ConsumerState<PlaylistVideosScreen> {
  final _selected = <String>{};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(playlistVideosProvider(widget.playlist.id));
    final ids =
        videos.value?.map((v) => v.videoId).toList() ?? const <String>[];
    // Drop ids that vanished from the playlist after a refresh.
    if (videos.hasValue && !videos.isLoading) _selected.retainAll(ids);
    final selecting = _selected.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: selecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _busy ? null : () => setState(_selected.clear),
              )
            : null,
        title: Text(
          selecting ? '${_selected.length} selected' : widget.playlist.title,
        ),
        actions: [
          if (ids.isNotEmpty)
            IconButton(
              tooltip: 'Select all',
              icon: const Icon(Icons.select_all),
              onPressed: _busy
                  ? null
                  : () => setState(() => _selected.addAll(ids)),
            ),
          if (!selecting)
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _busy
                  ? null
                  : () => ref.invalidate(
                      playlistVideosProvider(widget.playlist.id),
                    ),
            ),
        ],
      ),
      bottomNavigationBar: selecting
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _busy
                    ? const LinearProgressIndicator()
                    : Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _apply('private'),
                              icon: const Icon(Icons.lock_outline),
                              label: const Text('Make private'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () => _apply('unlisted'),
                              icon: const Icon(Icons.link),
                              label: const Text('Make unlisted'),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton.filledTonal(
                            tooltip: 'Delete from YouTube',
                            onPressed: _delete,
                            style: IconButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
              ),
            )
          : null,
      body: videos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load videos.\n$e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    playlistVideosProvider(widget.playlist.id),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(child: Text('This playlist has no videos.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final v = list[i];
                  final checked = _selected.contains(v.videoId);
                  void toggle(bool? on) => setState(() {
                    on == true
                        ? _selected.add(v.videoId)
                        : _selected.remove(v.videoId);
                  });
                  return ListTile(
                    selected: checked,
                    onTap: _busy ? null : () => toggle(!checked),
                    leading: v.thumbnailUrl == null
                        ? const Icon(Icons.video_library_outlined)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              v.thumbnailUrl!,
                              width: 64,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.video_library_outlined),
                            ),
                          ),
                    title: Text(
                      v.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(v.privacyStatus ?? 'unknown'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Open video on YouTube',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () =>
                              openVideoOnYoutube(context, v.videoId),
                        ),
                        Checkbox(value: checked, onChanged: _busy ? null : toggle),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _apply(String privacy) {
    final n = _selected.length;
    return _run(
      title: 'Make $n video${n == 1 ? '' : 's'} $privacy?',
      confirmLabel: 'Continue',
      op: (service, id) => service.setVideoPrivacy(id, privacy),
      doneLabel: (done) => 'set to $privacy',
    );
  }

  Future<void> _delete() {
    final n = _selected.length;
    return _run(
      title: 'Permanently delete $n video${n == 1 ? '' : 's'}?',
      warning: 'This deletes the video${n == 1 ? '' : 's'} from YouTube '
          'entirely, not just from this playlist. It cannot be undone.\n\n',
      confirmLabel: 'Delete',
      destructive: true,
      op: (service, id) => service.deleteVideo(id),
      doneLabel: (done) => 'deleted',
    );
  }

  /// Confirms, then runs [op] on every selected video one at a time. Stops on
  /// quota / auth errors; failed videos stay selected.
  Future<void> _run({
    required String title,
    String warning = '',
    required String confirmLabel,
    bool destructive = false,
    required Future<void> Function(YoutubePlaylistService service, String id) op,
    required String Function(int done) doneLabel,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(youtubePlaylistServiceProvider);
    final toChange = _selected.toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(
          '${warning}Each change uses 50 YouTube API quota units '
          '(~${toChange.length * 50} total of the 10,000 daily quota, which '
          'is shared with uploads).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);

    final failed = <String>[];
    String? firstError;
    for (var i = 0; i < toChange.length; i++) {
      final id = toChange[i];
      try {
        await op(service, id);
      } catch (e) {
        failed.add(id);
        firstError ??= e is YoutubeApiException ? e.message : e.toString();
        // Quota / auth failures hit every remaining video too: stop. The
        // quota is shared with uploads, so hold the upload queue as well.
        if (e is QuotaExceededException) {
          await ref.read(settingsRepositoryProvider).setQuotaPausedUntil(
                QuotaTracker.nextReset(DateTime.now())
                    .add(UploadManager.quotaResumeMargin),
              );
        }
        if (e is ReauthRequiredException || e is QuotaExceededException) {
          failed.addAll(toChange.skip(i + 1));
          break;
        }
      }
    }

    ref.invalidate(playlistVideosProvider(widget.playlist.id));
    ref.invalidate(playlistsProvider); // item counts changed
    if (!mounted) return;
    setState(() {
      _busy = false;
      _selected
        ..clear()
        ..addAll(failed);
    });
    final done = toChange.length - failed.length;
    final label = doneLabel(done);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          failed.isEmpty
              ? '$done video${done == 1 ? '' : 's'} $label.'
              : '$done $label, ${failed.length} failed: $firstError',
        ),
      ),
    );
  }
}
