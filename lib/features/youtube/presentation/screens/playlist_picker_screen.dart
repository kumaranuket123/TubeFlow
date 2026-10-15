import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_providers.dart';
import '../open_playlist.dart';
import '../providers/youtube_auth_providers.dart';

class PlaylistPickerScreen extends ConsumerWidget {
  const PlaylistPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final selectedId = ref.watch(appSettingsProvider).value?.selectedPlaylistId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload playlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(playlistsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPlaylist(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New playlist'),
      ),
      body: playlists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load playlists.\n$e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(playlistsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No playlists found on this channel.'))
            : RadioGroup<String>(
                groupValue: selectedId,
                onChanged: (id) async {
                  if (id == null) return;
                  final p = list.firstWhere((e) => e.id == id);
                  await ref
                      .read(settingsRepositoryProvider)
                      .setPlaylist(p.id, p.title);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return RadioListTile<String>(
                      value: p.id,
                      secondary: IconButton(
                        tooltip: 'Open on YouTube',
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => openPlaylistOnYoutube(context, p.id),
                      ),
                      title: Text(p.title),
                      subtitle: Text([
                        if (p.itemCount != null) '${p.itemCount} videos',
                        if (p.privacyStatus != null) p.privacyStatus!,
                      ].join(' · ')),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String title, String privacy})>(
      context: context,
      builder: (_) => const _NewPlaylistDialog(),
    );
    if (result == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final created = await ref
          .read(youtubePlaylistServiceProvider)
          .createPlaylist(result.title, privacyStatus: result.privacy);
      await ref.read(settingsRepositoryProvider).setPlaylist(created.id, created.title);
      ref.invalidate(playlistsProvider);
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not create playlist: $e')));
    }
  }
}

class _NewPlaylistDialog extends StatefulWidget {
  const _NewPlaylistDialog();

  @override
  State<_NewPlaylistDialog> createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<_NewPlaylistDialog> {
  final _controller = TextEditingController();
  String _privacy = 'private';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) Navigator.of(context).pop((title: title, privacy: _privacy));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 150,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Playlist name'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _privacy,
            decoration: const InputDecoration(labelText: 'Visibility'),
            items: const [
              DropdownMenuItem(value: 'private', child: Text('Private')),
              DropdownMenuItem(value: 'unlisted', child: Text('Unlisted')),
              DropdownMenuItem(value: 'public', child: Text('Public')),
            ],
            onChanged: (v) => setState(() => _privacy = v ?? 'private'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
