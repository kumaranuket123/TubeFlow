import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/youtube/data/local/youtube_account_table.dart';

part 'app_database.g.dart';

/// App-wide Drift database. Opened via `drift_flutter` with
/// `shareAcrossIsolates: true` so the same database can later be reached
/// from the background/foreground-service isolate that will drive the
/// upload queue (Phase 5+), not just the main UI isolate.
@DriftDatabase(tables: [YoutubeAccounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tube_flow',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  }
}
