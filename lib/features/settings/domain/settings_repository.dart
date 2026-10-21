import 'entities/app_settings.dart';

abstract class SettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();
  Future<void> setPlaylist(String? id, String? title);
  Future<void> setAutoUpload(bool value);
  Future<void> setWifiOnly(bool value);
  Future<void> setAllow5g(bool value);
  Future<void> setUploadNetwork(UploadNetwork value);
  Future<void> setChargingOnly(bool value);
  Future<void> setKeepOriginal(bool value);
  Future<void> setVisibility(UploadVisibility value);

  /// While set and in the future, no new upload starts (quota exhausted).
  Future<DateTime?> quotaPausedUntil();
  Future<void> setQuotaPausedUntil(DateTime? until);

  /// Stores the baseline if none exists and returns the effective one.
  Future<DateTime> ensureScanBaseline();
}
