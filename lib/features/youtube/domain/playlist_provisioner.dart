import '../../settings/domain/settings_repository.dart';
import 'entities/youtube_playlist.dart';
import 'services/youtube_playlist_service.dart';

/// Makes sure uploads have somewhere to go. If the channel has NO playlists,
/// creates a private "TubeFlow Private Videos" one and selects it. If the
/// channel has playlists, the user's own choice is never overridden.
class PlaylistProvisioner {
  PlaylistProvisioner({
    required YoutubePlaylistService playlists,
    required SettingsRepository settings,
  })  : _playlists = playlists,
        _settings = settings;

  static const defaultTitle = 'TubeFlow Private Videos';

  final YoutubePlaylistService _playlists;
  final SettingsRepository _settings;

  Future<YoutubePlaylist>? _creating;

  /// Creates and selects the default playlist (guards against concurrent
  /// callers creating two).
  Future<YoutubePlaylist> createDefault() {
    return _creating ??= () async {
      try {
        final created = await _playlists.createPrivatePlaylist(defaultTitle);
        await _settings.setPlaylist(created.id, created.title);
        return created;
      } finally {
        _creating = null;
      }
    }();
  }

  /// The playlist id to upload to, or null when the user has playlists but
  /// has not chosen one yet.
  Future<String?> ensureDefaultPlaylist() async {
    final selected = (await _settings.get()).selectedPlaylistId;
    if (selected != null) return selected;
    final existing = await _playlists.getMyPlaylists();
    if (existing.isNotEmpty) return null;
    return (await createDefault()).id;
  }
}
