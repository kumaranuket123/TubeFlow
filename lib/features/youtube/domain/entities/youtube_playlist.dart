class YoutubePlaylist {
  const YoutubePlaylist({
    required this.id,
    required this.title,
    this.itemCount,
    this.privacyStatus,
  });

  final String id;
  final String title;
  final int? itemCount;
  final String? privacyStatus;

  factory YoutubePlaylist.fromJson(Map<String, dynamic> json) {
    return YoutubePlaylist(
      id: json['id'] as String,
      title: (json['snippet']?['title'] as String?) ?? '(untitled)',
      itemCount: json['contentDetails']?['itemCount'] as int?,
      privacyStatus: json['status']?['privacyStatus'] as String?,
    );
  }
}
