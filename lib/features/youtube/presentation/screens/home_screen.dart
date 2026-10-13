import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_service.dart';
import '../../../media/presentation/providers/media_providers.dart';
import '../../../upload/domain/entities/video_upload_item.dart';
import '../../../media/presentation/widgets/scan_button.dart';
import '../../../settings/presentation/providers/auto_upload_controller.dart';
import '../../../settings/presentation/screens/auto_upload_settings_screen.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/auth_state.dart';
import '../providers/youtube_auth_providers.dart';
import '../../../upload/presentation/screens/manual_upload_picker.dart';
import '../../../upload/presentation/providers/upload_providers.dart';
import '../../../upload/presentation/widgets/upload_queue_list.dart';
import 'playlist_picker_screen.dart';
import 'youtube_connect_screen.dart';

/// Home shell. Later phases add the upload queue, scan and manual-upload
/// actions and the settings screen here.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Videos already offered in a popup this session ("Not now" is respected;
  /// the banner on this screen stays available).
  final _prompted = <Object>{};
  bool _dialogOpen = false;

  /// Asks Android to delete [items] (system confirmation dialog) and reports
  /// the outcome.
  Future<void> _deleteOriginals(List<VideoUploadItem> items) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await ref
          .read(originalCleanupServiceProvider)
          .deleteUploadedOriginals(items);
      messenger.showSnackBar(SnackBar(
          content: Text(n > 0
              ? 'Deleted $n original video(s).'
              : 'Nothing was deleted.')));
    } on UnsupportedError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${e.message}')));
    }
  }

  /// Popup shown when uploads finish and originals can be deleted.
  Future<void> _promptDelete(List<VideoUploadItem> items) async {
    final fresh = items.where((i) => !_prompted.contains(i.id)).toList();
    if (fresh.isEmpty || _dialogOpen || !mounted) return;
    _prompted.addAll(fresh.map((i) => i.id));
    _dialogOpen = true;
    final names = fresh.take(3).map((i) => '• ${i.fileName}').join('\n');
    final more = fresh.length > 3 ? '\n…and ${fresh.length - 3} more' : '';
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(fresh.length == 1
            ? 'Upload complete'
            : '${fresh.length} uploads complete'),
        content: Text(
          '$names$more\n\nSafely uploaded to YouTube as private. '
          'Delete the original from your phone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    _dialogOpen = false;
    if (yes == true && mounted) await _deleteOriginals(fresh);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deletableOriginalsProvider, (_, next) => _promptDelete(next));
    final auth = ref.watch(youtubeAuthControllerProvider);
    // Creating the manager resumes any queue left over from a previous run.
    if (auth is AuthConnected) {
      ref.watch(resumePendingUploadsProvider);
      ref.watch(mediaChangeWatcherProvider);
      ref.watch(resumeOnConditionsProvider);
      ref.watch(backgroundScheduleSyncProvider);
    }
    final settings = ref.watch(appSettingsProvider).value;
    final blocked = ref.watch(uploadBlockReasonProvider);
    final deletable = ref.watch(deletableOriginalsProvider);
    final network = ref.watch(networkKindProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('TubeFlow')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.smart_display_outlined),
            title: const Text('YouTube'),
            subtitle: Text(switch (auth) {
              AuthConnected(:final channel) => '✓ Connected · ${channel.title}',
              _ => 'Not connected',
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const YoutubeConnectScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_check),
            title: const Text('Playlist'),
            subtitle: Text(settings?.selectedPlaylistTitle ?? 'Not selected'),
            trailing: const Icon(Icons.arrow_drop_down),
            enabled: auth is AuthConnected,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlaylistPickerScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.autorenew),
            title: const Text('Auto Upload'),
            subtitle: Text([
              (settings?.autoUpload ?? false) ? 'ON' : 'OFF',
              (settings?.wifiOnly ?? true) ? 'Wi-Fi only' : 'Any network',
              if (settings?.chargingOnly ?? false) 'While charging',
            ].join(' · ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const AutoUploadSettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.network_check),
            title: const Text('Network'),
            subtitle: Text(switch (network) {
              NetworkKind.wifi => 'Wi-Fi',
              NetworkKind.mobile => 'Mobile data',
              NetworkKind.none => 'Offline',
              null => 'Checking…',
            }),
          ),
          if (blocked != null)
            ListTile(
              leading: const Icon(Icons.hourglass_empty),
              title: Text(blocked.message),
              subtitle: const Text('Queued videos will upload automatically.'),
              tileColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          if (deletable.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text('Delete ${deletable.length} original video(s)?'),
              subtitle: const Text('They are safely uploaded to YouTube.'),
              tileColor: Theme.of(context).colorScheme.tertiaryContainer,
              trailing: FilledButton(
                onPressed: () => _deleteOriginals(deletable),
                child: const Text('Delete'),
              ),
            ),
          if (auth is AuthConnected) const ScanButton(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Queue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const UploadQueueList(),
        ],
      ),
      floatingActionButton: auth is AuthConnected
          ? FloatingActionButton.extended(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final dupes = await pickAndEnqueueVideos(ref);
                if (dupes > 0) {
                  messenger.showSnackBar(SnackBar(
                      content: Text('$dupes video(s) already in the queue.')));
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload video'),
            )
          : null,
    );
  }
}
