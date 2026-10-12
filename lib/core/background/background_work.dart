import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/media/presentation/providers/media_providers.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import '../../features/upload/presentation/providers/upload_providers.dart';
import '../../features/youtube/domain/entities/auth_state.dart';
import '../../features/youtube/domain/repositories/youtube_auth_repository.dart';
import '../../features/youtube/presentation/providers/youtube_auth_providers.dart';

/// One background pass, shared by the foreground service and the WorkManager
/// worker: optionally scan for new camera videos (Auto Upload ON), then drain
/// the queue. [budget] stops *new* uploads from starting once exceeded
/// (WorkManager workers are killed after ~10 minutes).
Future<void> runBackgroundCycle(
  ProviderContainer container, {
  required bool scan,
  Duration? budget,
}) async {
  final auth = container.read(youtubeAuthRepositoryProvider);
  if (await awaitAuthRestored(auth) is! AuthConnected) return;

  if (scan) {
    final settings = await container.read(settingsRepositoryProvider).get();
    if (settings.autoUpload &&
        await container.read(mediaPermissionServiceProvider).isGranted()) {
      try {
        await container.read(videoScannerServiceProvider).scan();
      } catch (_) {
        // A failed scan must not block uploading what is already queued.
      }
    }
  }

  final manager = container.read(uploadManagerProvider);
  final timer = budget == null ? null : Timer(budget, manager.pause);
  try {
    await manager.start();
  } finally {
    timer?.cancel();
  }
}

/// A freshly created auth repository (every background engine builds its own)
/// starts as [AuthInitial] and restores "connected" from the database
/// asynchronously. Checking `currentState` right away wrongly concluded "not
/// connected" and the cycle exited without uploading anything.
Future<AuthState> awaitAuthRestored(
  YoutubeAuthRepository auth, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  bool settled(AuthState s) => s is! AuthInitial && s is! AuthLoading;
  if (settled(auth.currentState)) return auth.currentState;

  final done = Completer<AuthState>();
  final sub = auth.watchAuthState().listen((s) {
    if (settled(s) && !done.isCompleted) done.complete(s);
  });
  try {
    // Re-check: the restore may have finished before we subscribed.
    if (settled(auth.currentState)) return auth.currentState;
    return await done.future
        .timeout(timeout, onTimeout: () => auth.currentState);
  } finally {
    await sub.cancel();
  }
}
