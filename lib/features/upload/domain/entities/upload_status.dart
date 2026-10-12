enum UploadStatus {
  waiting,
  preparing,
  uploading,
  processing,
  addingToPlaylist,
  completed,
  failed,
  cancelled;

  /// States in which the manager is actively working on the item.
  bool get isInFlight =>
      this == preparing ||
      this == uploading ||
      this == processing ||
      this == addingToPlaylist;

  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}
