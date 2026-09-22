import '../repositories/youtube_auth_repository.dart';

class DisconnectAccount {
  const DisconnectAccount(this._repository);

  final YoutubeAuthRepository _repository;

  Future<void> call() => _repository.disconnect();
}
