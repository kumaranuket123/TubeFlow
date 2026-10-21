class YoutubePlaylistVideo {
  const YoutubePlaylistVideo({
    required this.videoId,
    required this.title,
    this.thumbnailUrl,
    this.privacyStatus,
  });

  final String videoId;
  final String title;
  final String? thumbnailUrl;
  final String? privacyStatus;

  factory YoutubePlaylistVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>?;
    final thumbs = snippet?['thumbnails'] as Map<String, dynamic>?;
    final thumb =
        (thumbs?['default'] ?? thumbs?['medium']) as Map<String, dynamic>?;
    return YoutubePlaylistVideo(
      videoId:
          (json['contentDetails']?['videoId'] ??
                  snippet?['resourceId']?['videoId'])
              as String,
      title: (snippet?['title'] as String?) ?? '(untitled)',
      thumbnailUrl: thumb?['url'] as String?,
      privacyStatus: json['status']?['privacyStatus'] as String?,
    );
  }
}
