import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../youtube/presentation/screens/playlist_picker_screen.dart';
import '../providers/auto_upload_controller.dart';
import '../providers/settings_providers.dart';
import '../../domain/entities/app_settings.dart';

class AutoUploadSettingsScreen extends ConsumerWidget {
  const AutoUploadSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider).value ?? const AppSettings();
    final repo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auto Upload')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Auto Upload'),
            subtitle: const Text('Upload new camera videos automatically'),
            value: s.autoUpload,
            onChanged: (v) async {
              final messenger = ScaffoldMessenger.of(context);
              if (!await setAutoUpload(ref, v)) {
                messenger.showSnackBar(const SnackBar(
                    content: Text('Video access is needed for Auto Upload.')));
              }
            },
          ),
          SwitchListTile(
            title: const Text('Wi-Fi only'),
            subtitle: const Text(
                'Never use mobile data. Leaving Wi-Fi pauses an upload; it resumes later.'),
            value: s.wifiOnly,
            onChanged: repo.setWifiOnly,
          ),
          SwitchListTile(
            title: const Text('Upload only while charging'),
            subtitle: const Text(
                'No new upload starts on battery. A video already uploading finishes.'),
            value: s.chargingOnly,
            onChanged: repo.setChargingOnly,
          ),
          SwitchListTile(
            title: const Text('Keep original video'),
            subtitle: const Text(
                'Off: after a video is safely on YouTube, TubeFlow offers to delete the original. Android always asks you to confirm.'),
            value: s.keepOriginal,
            onChanged: repo.setKeepOriginal,
          ),
          ListTile(
            title: const Text('Default playlist'),
            subtitle: Text(s.selectedPlaylistTitle ?? 'Not selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const PlaylistPickerScreen())),
          ),
          const ListTile(
            title: Text('Visibility'),
            subtitle: Text('Private (always)'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
