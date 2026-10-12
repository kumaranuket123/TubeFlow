import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_providers.dart';
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
}
