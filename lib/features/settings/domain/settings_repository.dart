import 'entities/app_settings.dart';

abstract class SettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();
  Future<void> setPlaylist(String? id, String? title);
  Future<void> setAutoUpload(bool value);
  Future<void> setWifiOnly(bool value);
  Future<void> setChargingOnly(bool value);
  Future<void> setKeepOriginal(bool value);

  /// Stores the baseline if none exists and returns the effective one.
  Future<DateTime> ensureScanBaseline();
}
