import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _rowId = 1;

  AppSettings _map(AppSettingsRow? r) => r == null
      ? const AppSettings()
      : AppSettings(
          selectedPlaylistId: r.selectedPlaylistId,
          selectedPlaylistTitle: r.selectedPlaylistTitle,
          autoUpload: r.autoUpload,
          wifiOnly: r.wifiOnly,
          chargingOnly: r.chargingOnly,
          keepOriginal: r.keepOriginal,
          scanBaseline: r.scanBaseline,
        );

  SimpleSelectStatement<$AppSettingsRowsTable, AppSettingsRow> get _select =>
      _db.select(_db.appSettingsRows)..where((t) => t.id.equals(_rowId));

  @override
  Stream<AppSettings> watch() =>
      _select.watchSingleOrNull().map(_map);

  @override
  Future<AppSettings> get() async => _map(await _select.getSingleOrNull());

  Future<void> _upsert(AppSettingsRowsCompanion changes) {
    return _db.into(_db.appSettingsRows).insert(
          changes.copyWith(id: const Value(_rowId)),
          onConflict: DoUpdate((_) => changes,
              target: [_db.appSettingsRows.id]),
        );
  }

  @override
  Future<void> setPlaylist(String? id, String? title) => _upsert(
        AppSettingsRowsCompanion(
          selectedPlaylistId: Value(id),
          selectedPlaylistTitle: Value(title),
        ),
      );

  @override
  Future<void> setAutoUpload(bool v) =>
      _upsert(AppSettingsRowsCompanion(autoUpload: Value(v)));

  @override
  Future<void> setWifiOnly(bool v) =>
      _upsert(AppSettingsRowsCompanion(wifiOnly: Value(v)));

  @override
  Future<void> setChargingOnly(bool v) =>
      _upsert(AppSettingsRowsCompanion(chargingOnly: Value(v)));

  @override
  Future<void> setKeepOriginal(bool v) =>
      _upsert(AppSettingsRowsCompanion(keepOriginal: Value(v)));

  @override
  Future<DateTime> ensureScanBaseline() async {
    final existing = (await get()).scanBaseline;
    if (existing != null) return existing;
    final now = DateTime.now();
    await _upsert(AppSettingsRowsCompanion(scanBaseline: Value(now)));
    return now;
  }
}
