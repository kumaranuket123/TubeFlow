import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;

import '../../features/settings/data/local/app_settings_table.dart';
import '../../features/upload/data/local/upload_queue_table.dart';
import '../../features/youtube/data/local/youtube_account_table.dart';

part 'app_database.g.dart';

/// App-wide Drift database. Opened via `drift_flutter` with
/// one connection per engine so background workers can use it too.
@DriftDatabase(tables: [YoutubeAccounts, AppSettingsRows, UploadQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(appSettingsRows);
          if (from < 3) await m.createTable(uploadQueue);
          if (from < 4) {
            await m.addColumn(appSettingsRows, appSettingsRows.scanBaseline);
          }
          if (from < 5) {
            await m.addColumn(appSettingsRows, appSettingsRows.runnerId);
            await m.addColumn(appSettingsRows, appSettingsRows.runnerLeaseUntilMs);
          }
          if (from < 6) {
            await m.addColumn(uploadQueue, uploadQueue.originalDeleted);
          }
          if (from < 7) {
            await m.addColumn(appSettingsRows, appSettingsRows.allow5g);
          }
        },
      );

  /// Every Flutter engine (UI, foreground service, WorkManager worker) opens
  /// its OWN connection to the same SQLite file. drift's `shareAcrossIsolates`
  /// is deliberately not used: it does not work across independent engines,
  /// and the shared server dies with the engine that hosted it, which broke
  /// the UI ("Channel was closed before receiving a response") whenever a
  /// background worker finished. WAL + busy_timeout make concurrent
  /// connections safe; cross-engine writes are picked up by the UI through a
  /// periodic refresh (see uploadQueueProvider).
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tube_flow',
      native: const DriftNativeOptions(setup: _configureSqlite),
    );
  }

  static void _configureSqlite(CommonDatabase db) {
    db.execute('PRAGMA journal_mode = WAL;');
    db.execute('PRAGMA busy_timeout = 5000;');
  }
}
