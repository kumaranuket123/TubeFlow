import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permissions/phone_state_permission_service.dart';
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
          ListTile(
            title: const Text('Upload over'),
            subtitle: Text(
                '${s.uploadNetwork.label}. ${s.uploadNetwork.description}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _chooseNetwork(context, ref, s.uploadNetwork),
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

Future<void> _chooseNetwork(
    BuildContext context, WidgetRef ref, UploadNetwork current) async {
  final choice = await showDialog<UploadNetwork>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Upload over'),
      children: [
        RadioGroup<UploadNetwork>(
          groupValue: current,
          onChanged: (v) => Navigator.of(ctx).pop(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in UploadNetwork.values)
                RadioListTile<UploadNetwork>(
                  value: o,
                  title: Text(o.label),
                  subtitle: Text(o.description),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  if (choice == null || choice == current || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  if (choice == UploadNetwork.wifiOr5g) {
    // Phone-state permission is only needed to tell 5G from 4G.
    final perm = PhoneStatePermissionService();
    if (!await perm.request()) {
      final forever = await perm.isPermanentlyDenied();
      messenger.showSnackBar(SnackBar(
        content: const Text('Phone-state permission is needed to detect 5G.'),
        action: forever
            ? SnackBarAction(label: 'Settings', onPressed: perm.openSettings)
            : null,
      ));
      return;
    }
  }
  await ref.read(settingsRepositoryProvider).setUploadNetwork(choice);
}
