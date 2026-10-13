import '../entities/youtube_playlist.dart';

abstract class YoutubePlaylistService {
  Future<List<YoutubePlaylist>> getMyPlaylists();

  /// [privacyStatus]: `private` (default), `unlisted` or `public`.
  Future<YoutubePlaylist> createPlaylist(String title, {String privacyStatus = 'private'});
}
