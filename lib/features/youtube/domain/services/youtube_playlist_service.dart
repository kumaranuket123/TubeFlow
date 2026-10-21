import '../entities/youtube_playlist.dart';
import '../entities/youtube_playlist_video.dart';

abstract class YoutubePlaylistService {
  Future<List<YoutubePlaylist>> getMyPlaylists();

  /// [privacyStatus]: `private` (default), `unlisted` or `public`.
  Future<YoutubePlaylist> createPlaylist(
    String title, {
    String privacyStatus = 'private',
  });

  Future<List<YoutubePlaylistVideo>> getPlaylistVideos(String playlistId);

  /// Sets [privacyStatus] (`private` or `unlisted`) on one video.
  Future<void> setVideoPrivacy(String videoId, String privacyStatus);

  /// Permanently deletes a video from YouTube (not just from the playlist).
  Future<void> deleteVideo(String videoId);

  /// Deletes the playlist only; its videos stay on the channel.
  Future<void> deletePlaylist(String playlistId);
}
