import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../media/presentation/providers/media_providers.dart';
import '../../../upload/presentation/providers/upload_providers.dart';
import 'settings_providers.dart';

/// Turning Auto Upload on needs video access (to detect recordings) and
/// notification permission (for the upload progress notification). The
/// periodic background scan is scheduled by backgroundScheduleSyncProvider. Returns false if video access was
/// refused, in which case the setting stays off.
Future<bool> setAutoUpload(WidgetRef ref, bool enabled) async {
  final settings = ref.read(settingsRepositoryProvider);
  if (enabled) {
    if (!await ref.read(mediaPermissionServiceProvider).request()) {
      return false;
    }
    await FlutterForegroundTask.requestNotificationPermission();
  }
  await settings.setAutoUpload(enabled);
  return true;
}

/// While the app process is alive, react to new recordings quickly instead of
/// waiting for the 15-minute worker. Debounced so a recording in progress
/// (many MediaStore changes) triggers one scan after it settles.
final mediaChangeWatcherProvider = Provider<void>((ref) {
  Timer? debounce;
  final sub = ref.watch(mediaStoreServiceProvider).changes.listen((_) {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 20), () async {
      final s = await ref.read(settingsRepositoryProvider).get();
      if (!s.autoUpload) return;
      if (!await ref.read(mediaPermissionServiceProvider).isGranted()) return;
      final r = await ref.read(videoScannerServiceProvider).scan();
      if (r.added > 0) await ref.read(uploadTriggerProvider)();
    });
  });
  ref.onDispose(() {
    debounce?.cancel();
    sub.cancel();
  });
});
