/// Which connections may be used for uploads.
enum UploadNetwork {
  wifiOnly('Wi-Fi only', 'Never use mobile data.'),
  wifiOr5g('Wi-Fi or 5G',
      'Mobile data only on 5G. Pauses on 4G and below, resumes on Wi-Fi or 5G.'),
  any('Any network', 'Wi-Fi or any mobile data.');

  const UploadNetwork(this.label, this.description);
  final String label;
  final String description;
}

/// User preferences. Visibility is intentionally not configurable: every
/// upload is PRIVATE so a video can never be published by accident.
class AppSettings {
  const AppSettings({
    this.selectedPlaylistId,
    this.selectedPlaylistTitle,
    this.autoUpload = false,
    this.wifiOnly = true,
    this.allow5g = false,
    this.chargingOnly = false,
    this.keepOriginal = true,
    this.scanBaseline,
  });

  final String? selectedPlaylistId;
  final String? selectedPlaylistTitle;
  final bool autoUpload;
  final bool wifiOnly;

  /// Only meaningful with [wifiOnly]: Wi-Fi, or mobile data on 5G.
  final bool allow5g;
  final bool chargingOnly;
  final bool keepOriginal;
  final DateTime? scanBaseline;

  /// The single user-facing choice, stored as [wifiOnly] + [allow5g].
  UploadNetwork get uploadNetwork => !wifiOnly
      ? UploadNetwork.any
      : (allow5g ? UploadNetwork.wifiOr5g : UploadNetwork.wifiOnly);

  static const String visibility = 'private';

  AppSettings copyWith({
    bool? autoUpload,
    bool? wifiOnly,
    bool? allow5g,
    bool? chargingOnly,
    bool? keepOriginal,
  }) {
    return AppSettings(
      selectedPlaylistId: selectedPlaylistId,
      selectedPlaylistTitle: selectedPlaylistTitle,
      autoUpload: autoUpload ?? this.autoUpload,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      allow5g: allow5g ?? this.allow5g,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      keepOriginal: keepOriginal ?? this.keepOriginal,
      scanBaseline: scanBaseline,
    );
  }
}
