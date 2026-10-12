import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/media_video.dart';
import '../../../upload/presentation/providers/upload_providers.dart';
import '../providers/media_providers.dart';

/// "Scan Camera Videos": asks for video access if needed, queries MediaStore,
/// enqueues unseen finished videos, then starts the queue.
class ScanButton extends ConsumerStatefulWidget {
  const ScanButton({super.key});

  @override
  ConsumerState<ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends ConsumerState<ScanButton> {
  bool _busy = false;

  Future<void> _scan() async {
    final messenger = ScaffoldMessenger.of(context);
    void say(String m) => messenger.showSnackBar(SnackBar(content: Text(m)));
    setState(() => _busy = true);
    try {
      final perms = ref.read(mediaPermissionServiceProvider);
      if (!await perms.request()) {
        if (await perms.isPermanentlyDenied()) {
          messenger.showSnackBar(SnackBar(
            content: const Text('Video access is needed to scan.'),
            action: SnackBarAction(label: 'Settings', onPressed: perms.openSettings),
          ));
        } else {
          say('Video access is needed to scan.');
        }
        return;
      }
      final r = await ref.read(videoScannerServiceProvider).scan();
      say([
        '${r.added} new video(s) queued',
        if (r.duplicates > 0) '${r.duplicates} already known',
        if (r.unstable > 0) '${r.unstable} still being recorded',
      ].join(' · '));
      if (r.added > 0) ref.read(uploadTriggerProvider)();
    } on MediaPermissionDeniedException catch (e) {
      say(e.toString());
    } catch (e) {
      say('Scan failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _busy
          ? const SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.video_library_outlined),
      title: const Text('Scan Camera Videos'),
      subtitle: const Text('Find new recordings and add them to the queue'),
      onTap: _busy ? null : _scan,
    );
  }
}
