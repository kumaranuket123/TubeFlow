import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../youtube/data/datasources/youtube_playlist_remote_datasource.dart';
import '../../../youtube/presentation/providers/youtube_auth_providers.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/background/foreground_upload_service.dart';
import '../../../../core/background/background_scheduler.dart';
import '../../../../core/battery/battery_service.dart';
import '../../../../core/network/network_service.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/upload_conditions.dart';
import '../../data/repositories/drift_runner_lease.dart';
import '../../data/repositories/upload_queue_repository_impl.dart';
import '../../data/youtube_upload_remote_datasource.dart';
import '../../data/youtube_uploader_impl.dart';
import '../../domain/entities/video_upload_item.dart';
import '../../domain/upload_manager.dart';
import '../../domain/upload_queue_repository.dart';
import '../../domain/youtube_uploader.dart';

final networkServiceProvider =
    Provider<NetworkService>((ref) => ConnectivityNetworkService());

final batteryServiceProvider =
    Provider<BatteryService>((ref) => BatteryPlusService());

final uploadConditionCheckerProvider = Provider<UploadConditionChecker>((ref) {
  return UploadConditionChecker(
    settings: ref.watch(settingsRepositoryProvider),
    network: ref.watch(networkServiceProvider),
    battery: ref.watch(batteryServiceProvider),
  );
});

/// Live network kind / charging state for the UI.
final networkKindProvider = StreamProvider<NetworkKind>((ref) async* {
  final svc = ref.watch(networkServiceProvider);
  yield await svc.current();
  yield* svc.watch();
});

final chargingProvider = StreamProvider<bool>((ref) async* {
  final svc = ref.watch(batteryServiceProvider);
  yield await svc.isCharging();
  yield* svc.watch();
});

/// Why new uploads are currently held back (null = free to upload).
final uploadBlockReasonProvider = Provider<BlockReason?>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  if (settings == null) return null;
  return evaluateSettings(
    settings,
    ref.watch(networkKindProvider).value,
    ref.watch(chargingProvider).value,
  );
});

/// When the rules become satisfied (Wi-Fi connected, charger plugged in...)
/// resume waiting uploads without the user doing anything. Active while the
/// app process is alive; WorkManager constraints cover the rest.
final resumeOnConditionsProvider = Provider<void>((ref) {
  ref.listen<BlockReason?>(uploadBlockReasonProvider, (prev, next) async {
    if (prev != null && next == null &&
        await ref.read(uploadQueueRepositoryProvider).nextPending() != null) {
      await ref.read(uploadTriggerProvider)();
    }
  });
});

/// Keeps the WorkManager schedule in line with the settings: runs only while
/// Auto Upload is on or uploads are waiting, and only under the user's
/// network/charging constraints.
final backgroundScheduleSyncProvider = Provider<void>((ref) {
  final rules = ref.watch(appSettingsProvider.select((a) {
    final s = a.value;
    return s == null ? null : (s.autoUpload, s.wifiOnly, s.chargingOnly, s.allow5g);
  }));
  final hasPending = ref.watch(uploadQueueProvider.select(
      (a) => a.value?.any((i) => !i.status.isTerminal) ?? false));
  if (rules == null) return;
  BackgroundScheduler.sync(
    autoUpload: rules.$1,
    hasPending: hasPending,
    wifiOnly: rules.$2,
    chargingOnly: rules.$3,
    allow5g: rules.$4,
  );
});

final uploadQueueRepositoryProvider = Provider<UploadQueueRepository>((ref) {
  return UploadQueueRepositoryImpl(ref.watch(appDatabaseProvider));
});

final youtubeUploaderProvider = Provider<YoutubeUploader>((ref) {
  final dio = ref.watch(dioProvider);
  return YoutubeUploaderImpl(
    ref.watch(youtubeAuthRepositoryProvider),
    YoutubeUploadRemoteDataSource(dio),
    YoutubePlaylistRemoteDataSource(dio),
  );
});

/// The single entry point for all uploads (manual now; scanner and
/// background worker in later phases).
final uploadManagerProvider = Provider<UploadManager>((ref) {
  final manager = UploadManager(
    queue: ref.watch(uploadQueueRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    uploader: ref.watch(youtubeUploaderProvider),
    conditions: ref.watch(uploadConditionCheckerProvider),
    ensurePlaylist: ref.watch(playlistProvisionerProvider).ensureDefaultPlaylist,
    lease: DriftRunnerLease(ref.watch(appDatabaseProvider)),
    owner: const Uuid().v4(), // one per isolate/container
  );
  return manager;
});

/// Starts uploading in the most robust way available: the foreground service
/// (survives screen lock/backgrounding). Falls back to running in this
/// isolate if the service can't start.
final uploadTriggerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      if (await ForegroundUploadService.start()) return;
    } catch (_) {}
    await ref.read(uploadManagerProvider).start();
  };
});

/// On app open: resume anything left in the queue by a previous run.
final resumePendingUploadsProvider = FutureProvider<void>((ref) async {
  if (await ref.read(uploadQueueRepositoryProvider).nextPending() != null) {
    await ref.read(uploadTriggerProvider)();
  }
});

/// The foreground service / worker write the queue from other Flutter engines
/// with their own DB connections, which drift can't announce to this one, so
/// re-query on a short timer (re-emits only when the data changed).
final uploadQueueProvider = StreamProvider<List<VideoUploadItem>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final timer = Timer.periodic(
    const Duration(seconds: 2),
    (_) => db.notifyUpdates({TableUpdate.onTable(db.uploadQueue)}),
  );
  ref.onDispose(timer.cancel);
  return ref.watch(uploadQueueRepositoryProvider).watchAll();
});

/// When uploads are paused for the YouTube quota (null = not paused). Polled:
/// the pause is written by whichever engine hit the quota error.
final quotaPausedUntilProvider = StreamProvider.autoDispose<DateTime?>((ref) async* {
  final settings = ref.watch(settingsRepositoryProvider);
  while (true) {
    final until = await settings.quotaPausedUntil();
    yield until != null && until.isAfter(DateTime.now()) ? until : null;
    await Future<void>.delayed(const Duration(seconds: 3));
  }
});

/// Restarts the queue as soon as a quota pause ends (while the app is open;
/// the periodic WorkManager job covers the rest).
final resumeAfterQuotaResetProvider = Provider<void>((ref) {
  Timer? timer;
  DateTime? scheduledFor;
  ref.listen<AsyncValue<DateTime?>>(quotaPausedUntilProvider, (_, next) {
    final until = next.value;
    if (until == null || until == scheduledFor) return;
    scheduledFor = until;
    timer?.cancel();
    final wait = until.difference(DateTime.now());
    timer = Timer(wait.isNegative ? Duration.zero : wait, () async {
      if (await ref.read(uploadQueueRepositoryProvider).nextPending() != null) {
        await ref.read(uploadTriggerProvider)();
      }
    });
  }, fireImmediately: true);
  ref.onDispose(() => timer?.cancel());
});
