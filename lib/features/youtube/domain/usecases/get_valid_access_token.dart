import '../repositories/youtube_auth_repository.dart';

/// Used by every later feature (playlists, uploads) that needs to call a
/// YouTube API endpoint — never call the repository directly from outside
/// the youtube feature.
class GetValidAccessToken {
  const GetValidAccessToken(this._repository);

  final YoutubeAuthRepository _repository;

  Future<String> call() => _repository.getValidAccessToken();
}
