/// User preferences. Visibility is intentionally not configurable: every
/// upload is PRIVATE so a video can never be published by accident.
class AppSettings {
  const AppSettings({
    this.selectedPlaylistId,
    this.selectedPlaylistTitle,
    this.autoUpload = false,
    this.wifiOnly = true,
    this.chargingOnly = false,
    this.keepOriginal = true,
    this.scanBaseline,
  });

  final String? selectedPlaylistId;
  final String? selectedPlaylistTitle;
  final bool autoUpload;
  final bool wifiOnly;
  final bool chargingOnly;
  final bool keepOriginal;
  final DateTime? scanBaseline;

  static const String visibility = 'private';

  AppSettings copyWith({
    bool? autoUpload,
    bool? wifiOnly,
    bool? chargingOnly,
    bool? keepOriginal,
  }) {
    return AppSettings(
      selectedPlaylistId: selectedPlaylistId,
      selectedPlaylistTitle: selectedPlaylistTitle,
      autoUpload: autoUpload ?? this.autoUpload,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      keepOriginal: keepOriginal ?? this.keepOriginal,
      scanBaseline: scanBaseline,
    );
  }
}
