import '../../domain/entities/youtube_playlist.dart';
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
  Future<YoutubePlaylist> createPrivatePlaylist(String title) async {
    final token = await _auth.getValidAccessToken();
    return _remote.createPrivatePlaylist(accessToken: token, title: title);
  }
}
