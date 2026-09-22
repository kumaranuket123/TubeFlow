import '../repositories/youtube_auth_repository.dart';

class ConnectAccount {
  const ConnectAccount(this._repository);

  final YoutubeAuthRepository _repository;

  Future<void> call() => _repository.connect();
}
