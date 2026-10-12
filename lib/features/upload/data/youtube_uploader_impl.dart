import 'dart:io';

import 'package:dio/dio.dart';

import '../../youtube/data/datasources/youtube_playlist_remote_datasource.dart';
import '../../youtube/domain/repositories/youtube_auth_repository.dart';
import '../domain/youtube_uploader.dart';
import 'youtube_upload_remote_datasource.dart';

class YoutubeUploaderImpl implements YoutubeUploader {
  YoutubeUploaderImpl(this._auth, this._upload, this._playlists);

  final YoutubeAuthRepository _auth;
  final YoutubeUploadRemoteDataSource _upload;
  final YoutubePlaylistRemoteDataSource _playlists;

  @override
  Future<String> uploadVideo({
    required File file,
    required String title,
    required String description,
    String? sessionUri,
    required Future<void> Function(String sessionUri) onSessionStarted,
    required void Function(double) onProgress,
    required CancelToken cancelToken,
  }) async =>
      _upload.uploadVideo(
        accessToken: await _auth.getValidAccessToken(),
        file: file,
        title: title,
        description: description,
        sessionUri: sessionUri,
        onSessionStarted: onSessionStarted,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

  @override
  Future<bool> isPrivate(String videoId) async =>
      _upload.isPrivate(await _auth.getValidAccessToken(), videoId);

  @override
  Future<void> addToPlaylist(String playlistId, String videoId) async =>
      _playlists.addVideoToPlaylist(
        accessToken: await _auth.getValidAccessToken(),
        playlistId: playlistId,
        videoId: videoId,
      );
}
