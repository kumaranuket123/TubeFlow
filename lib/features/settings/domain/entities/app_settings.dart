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

/// Visibility of uploaded videos. Public is intentionally not offered so a
/// video can never be published by accident.
enum UploadVisibility {
  private_('private', 'Private', 'Only you can watch.'),
  unlisted('unlisted', 'Unlisted', 'Anyone with the link can watch.');

  const UploadVisibility(this.apiValue, this.label, this.description);
  final String apiValue;
  final String label;
  final String description;

  static UploadVisibility fromApi(String? v) => UploadVisibility.values
      .firstWhere((e) => e.apiValue == v, orElse: () => UploadVisibility.private_);
}

/// User preferences.
class AppSettings {
  const AppSettings({
    this.selectedPlaylistId,
    this.selectedPlaylistTitle,
    this.autoUpload = false,
    this.wifiOnly = true,
    this.allow5g = false,
    this.chargingOnly = false,
    this.keepOriginal = true,
    this.visibility = UploadVisibility.private_,
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
  final UploadVisibility visibility;
  final DateTime? scanBaseline;

  /// The single user-facing choice, stored as [wifiOnly] + [allow5g].
  UploadNetwork get uploadNetwork => !wifiOnly
      ? UploadNetwork.any
      : (allow5g ? UploadNetwork.wifiOr5g : UploadNetwork.wifiOnly);

  AppSettings copyWith({
    bool? autoUpload,
    bool? wifiOnly,
    bool? allow5g,
    bool? chargingOnly,
    bool? keepOriginal,
    UploadVisibility? visibility,
  }) {
    return AppSettings(
      selectedPlaylistId: selectedPlaylistId,
      selectedPlaylistTitle: selectedPlaylistTitle,
      autoUpload: autoUpload ?? this.autoUpload,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      allow5g: allow5g ?? this.allow5g,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      keepOriginal: keepOriginal ?? this.keepOriginal,
      visibility: visibility ?? this.visibility,
      scanBaseline: scanBaseline,
    );
  }
}
