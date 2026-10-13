import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/upload/domain/entities/upload_status.dart';
import '../../features/upload/domain/entities/video_upload_item.dart';
import '../../features/upload/presentation/providers/upload_providers.dart';
import 'background_work.dart';

/// Android foreground service (type dataSync) that keeps uploads running
/// with the screen locked or the app in the background, showing:
///   TubeFlow
///   Uploading IMG_20260919_0930.mp4 72%
/// It stops itself when the queue is drained. Start it only while the app is
/// visible (Android 12+ forbids starting it from the background).
class ForegroundUploadService {
  ForegroundUploadService._();

  static const _serviceId = 7001;

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tubeflow_uploads',
        channelName: 'Video uploads',
        channelDescription: 'Shows progress while TubeFlow uploads videos.',
        visibility: NotificationVisibility.VISIBILITY_PRIVATE,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// True if the service is running (already or newly started).
  static Future<bool> start() async {
    if (await FlutterForegroundTask.isRunningService) return true;
    if (await FlutterForegroundTask.checkNotificationPermission() !=
        NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    final result = await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: 'TubeFlow',
      notificationText: 'Preparing uploads…',
      callback: uploadServiceStartCallback,
    );
    return result is ServiceRequestSuccess;
  }
}

@pragma('vm:entry-point')
void uploadServiceStartCallback() {
  FlutterForegroundTask.setTaskHandler(_UploadTaskHandler());
}

class _UploadTaskHandler extends TaskHandler {
  ProviderContainer? _container;
  StreamSubscription<List<VideoUploadItem>>? _sub;
  String? _lastText;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final container = _container = ProviderContainer();
    _sub = container
        .read(uploadQueueRepositoryProvider)
        .watchAll()
        .listen(_updateNotification);
    // onStart must return promptly (the plugin treats it as initialisation);
    // a multi-minute upload awaited here left the service "executing" and the
    // app unresponsive. Run the cycle in the background and stop when done.
    unawaited(_run(container));
  }

  Future<void> _run(ProviderContainer container) async {
    try {
      await runBackgroundCycle(container, scan: false);
    } catch (_) {
      // Failures are recorded on the queue items themselves.
    } finally {
      await FlutterForegroundTask.stopService();
    }
  }

  void _updateNotification(List<VideoUploadItem> items) {
    final active = items.where((i) => i.status.isInFlight).toList();
    if (active.isEmpty) return;
    final i = active.first;
    final text = switch (i.status) {
      UploadStatus.uploading =>
        'Uploading ${i.fileName} ${(i.progress * 100).round()}%',
      UploadStatus.addingToPlaylist => 'Adding ${i.fileName} to playlist',
      _ => 'Preparing ${i.fileName}',
    };
    if (text == _lastText) return;
    _lastText = text;
    FlutterForegroundTask.updateService(
        notificationTitle: 'TubeFlow', notificationText: text);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _sub?.cancel();
    // Release the lease so another runner can take over promptly.
    _container?.read(uploadManagerProvider).pause();
    _container?.dispose();
  }
}
