import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'background_work.dart';

const _periodicName = 'tubeflow.periodic';
const _periodicTask = 'scanAndUpload';

/// WorkManager entry point (runs in a background isolate, also after a
/// reboot since periodic work is persisted by WorkManager).
@pragma('vm:entry-point')
void workmanagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final container = ProviderContainer();
    try {
      await runBackgroundCycle(
        container,
        scan: true,
        budget: const Duration(minutes: 8),
      );
      return true;
    } catch (_) {
      return false; // WorkManager retries with backoff.
    } finally {
      container.dispose();
    }
  });
}

class BackgroundScheduler {
  BackgroundScheduler._();

  static Future<void> init() => Workmanager().initialize(workmanagerDispatcher);

  /// Registers or cancels the periodic scan+upload job. It exists only while
  /// Auto Upload is on or uploads are waiting. WorkManager itself holds the
  /// job until its constraints are met, so "Wi-Fi only" and "only while
  /// charging" also decide *when* the job may run.
  static Future<void> sync({
    required bool autoUpload,
    required bool hasPending,
    required bool wifiOnly,
    required bool chargingOnly,
  }) async {
    if (!autoUpload && !hasPending) {
      await Workmanager().cancelByUniqueName(_periodicName);
      return;
    }
    await Workmanager().registerPeriodicTask(
      _periodicName,
      _periodicTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        requiresCharging: chargingOnly,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }
}
