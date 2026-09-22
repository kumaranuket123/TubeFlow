/// Display-only metadata for the connected YouTube channel.
class YoutubeChannel {
  const YoutubeChannel({
    required this.channelId,
    required this.title,
    this.thumbnailUrl,
  });

  final String channelId;
  final String title;
  final String? thumbnailUrl;

  factory YoutubeChannel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) {
      throw const FormatException('No channel found for the authenticated user');
    }
    final item = items.first as Map<String, dynamic>;
    final snippet = item['snippet'] as Map<String, dynamic>;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
    final defaultThumb = thumbnails?['default'] as Map<String, dynamic>?;
    return YoutubeChannel(
      channelId: item['id'] as String,
      title: snippet['title'] as String,
      thumbnailUrl: defaultThumb?['url'] as String?,
    );
  }
}
