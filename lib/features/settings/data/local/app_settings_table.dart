import 'package:drift/drift.dart';

/// Single-row table (id is always 1) holding user preferences.
class AppSettingsRows extends Table {
  IntColumn get id => integer()();
  TextColumn get selectedPlaylistId => text().nullable()();
  TextColumn get selectedPlaylistTitle => text().nullable()();
  BoolColumn get autoUpload => boolean().withDefault(const Constant(false))();
  BoolColumn get wifiOnly => boolean().withDefault(const Constant(true))();
  BoolColumn get chargingOnly => boolean().withDefault(const Constant(false))();
  BoolColumn get keepOriginal => boolean().withDefault(const Constant(true))();

  /// First time scanning was used; only videos added after (baseline - 24h)
  /// are eligible, so the existing gallery is never bulk-queued.
  DateTimeColumn get scanBaseline => dateTime().nullable()();

  /// Cross-isolate upload-runner lease (see RunnerLease). Epoch millis.
  TextColumn get runnerId => text().nullable()();
  IntColumn get runnerLeaseUntilMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
