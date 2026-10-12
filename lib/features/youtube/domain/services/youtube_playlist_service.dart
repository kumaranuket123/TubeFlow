import '../entities/youtube_playlist.dart';

abstract class YoutubePlaylistService {
  Future<List<YoutubePlaylist>> getMyPlaylists();

  Future<YoutubePlaylist> createPrivatePlaylist(String title);
}
