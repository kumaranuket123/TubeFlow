import '../../domain/entities/youtube_playlist.dart';
import '../../domain/entities/youtube_playlist_video.dart';
import '../../domain/repositories/youtube_auth_repository.dart';
import '../../domain/services/youtube_playlist_service.dart';
import '../datasources/youtube_playlist_remote_datasource.dart';

class YoutubePlaylistServiceImpl implements YoutubePlaylistService {
  YoutubePlaylistServiceImpl(this._auth, this._remote);

  final YoutubeAuthRepository _auth;
  final YoutubePlaylistRemoteDataSource _remote;

  @override
  Future<List<YoutubePlaylist>> getMyPlaylists() async {
    final token = await _auth.getValidAccessToken();
    return _remote.fetchMyPlaylists(token);
  }

  @override
  Future<YoutubePlaylist> createPlaylist(
    String title, {
    String privacyStatus = 'private',
  }) async {
    final token = await _auth.getValidAccessToken();
    return _remote.createPlaylist(
      accessToken: token,
      title: title,
      privacyStatus: privacyStatus,
    );
  }

  @override
  Future<List<YoutubePlaylistVideo>> getPlaylistVideos(
    String playlistId,
  ) async {
    final token = await _auth.getValidAccessToken();
    return _remote.fetchPlaylistVideos(token, playlistId);
  }

  @override
  Future<void> setVideoPrivacy(String videoId, String privacyStatus) async {
    final token = await _auth.getValidAccessToken();
    return _remote.setVideoPrivacy(
      accessToken: token,
      videoId: videoId,
      privacyStatus: privacyStatus,
    );
  }

  @override
  Future<void> deleteVideo(String videoId) async =>
      _remote.deleteVideo(await _auth.getValidAccessToken(), videoId);

  @override
  Future<void> deletePlaylist(String playlistId) async =>
      _remote.deletePlaylist(await _auth.getValidAccessToken(), playlistId);
}
