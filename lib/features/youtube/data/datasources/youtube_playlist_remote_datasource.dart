import 'package:dio/dio.dart';

import '../../../../core/constants/youtube_api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/youtube_error_mapper.dart';
import '../../domain/entities/youtube_playlist.dart';
import '../../domain/entities/youtube_playlist_video.dart';

/// `playlists.list` (mine=true), following `nextPageToken` until exhausted.
class YoutubePlaylistRemoteDataSource {
  YoutubePlaylistRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<YoutubePlaylist>> fetchMyPlaylists(String accessToken) async {
    final result = <YoutubePlaylist>[];
    String? pageToken;
    try {
      do {
        final response = await _dio.get<Map<String, dynamic>>(
          '${YoutubeApiConstants.apiBaseUrl}/playlists',
          queryParameters: {
            'part': 'snippet,contentDetails,status',
            'mine': true,
            'maxResults': 50,
            'pageToken': ?pageToken,
          },
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        final data = response.data!;
        result.addAll(
          (data['items'] as List? ?? const []).map(
            (e) => YoutubePlaylist.fromJson(e as Map<String, dynamic>),
          ),
        );
        pageToken = data['nextPageToken'] as String?;
      } while (pageToken != null);
    } on DioException catch (e) {
      throw mapYoutubeDioError(e, fallback: 'Failed to fetch playlists');
    }
    return result;
  }

  /// `playlistItems.insert`. Safe to retry: it never re-uploads the video.
  Future<void> addVideoToPlaylist({
    required String accessToken,
    required String playlistId,
    required String videoId,
  }) async {
    try {
      await _dio.post<dynamic>(
        '${YoutubeApiConstants.apiBaseUrl}/playlistItems',
        queryParameters: {'part': 'snippet'},
        data: {
          'snippet': {
            'playlistId': playlistId,
            'resourceId': {'kind': 'youtube#video', 'videoId': videoId},
          },
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw mapYoutubeDioError(
        e,
        fallback: 'Failed to add video to playlist',
        notFoundIsPlaylist: true,
      );
    }
  }

  /// `playlists.insert` (50 quota units). [privacyStatus] is `private`,
  /// `unlisted` or `public`; defaults to private.
  Future<YoutubePlaylist> createPlaylist({
    required String accessToken,
    required String title,
    String privacyStatus = 'private',
    String description = '',
  }) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '${YoutubeApiConstants.apiBaseUrl}/playlists',
        queryParameters: {'part': 'snippet,status,contentDetails'},
        data: {
          'snippet': {'title': title, 'description': description},
          'status': {'privacyStatus': privacyStatus},
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return YoutubePlaylist.fromJson(r.data!);
    } on DioException catch (e) {
      throw mapYoutubeDioError(e, fallback: 'Failed to create playlist');
    }
  }

  /// `playlistItems.list` (1 unit/page), following `nextPageToken`.
  Future<List<YoutubePlaylistVideo>> fetchPlaylistVideos(
    String accessToken,
    String playlistId,
  ) async {
    final result = <YoutubePlaylistVideo>[];
    String? pageToken;
    try {
      do {
        final response = await _dio.get<Map<String, dynamic>>(
          '${YoutubeApiConstants.apiBaseUrl}/playlistItems',
          queryParameters: {
            'part': 'snippet,contentDetails,status',
            'playlistId': playlistId,
            'maxResults': 50,
            'pageToken': ?pageToken,
          },
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        final data = response.data!;
        for (final e in (data['items'] as List? ?? const [])) {
          final item = e as Map<String, dynamic>;
          if (item['contentDetails']?['videoId'] == null) continue;
          result.add(YoutubePlaylistVideo.fromJson(item));
        }
        pageToken = data['nextPageToken'] as String?;
      } while (pageToken != null);
    } on DioException catch (e) {
      throw mapYoutubeDioError(
        e,
        fallback: 'Failed to load playlist videos',
        notFoundIsPlaylist: true,
      );
    }
    return result;
  }

  /// `videos.list` + `videos.update` (50 units). Reads the full `status`
  /// part first because update resets any status field that is omitted.
  Future<void> setVideoPrivacy({
    required String accessToken,
    required String videoId,
    required String privacyStatus,
  }) async {
    final headers = Options(headers: {'Authorization': 'Bearer $accessToken'});
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '${YoutubeApiConstants.apiBaseUrl}/videos',
        queryParameters: {'part': 'status', 'id': videoId},
        options: headers,
      );
      final items = r.data?['items'] as List? ?? const [];
      if (items.isEmpty) {
        throw const YoutubeApiException(
          'Video not found, or it does not belong to your channel',
        );
      }
      final current = (items.first as Map<String, dynamic>)['status'] as Map;
      if (current['privacyStatus'] == privacyStatus) return;
      // Only writable fields; read-only ones (uploadStatus, ...) are rejected.
      // A scheduled publish only makes sense while the video stays private.
      final status = <String, dynamic>{
        for (final k in const [
          'embeddable',
          'license',
          'publicStatsViewable',
          'selfDeclaredMadeForKids',
          'publishAt',
        ])
          if (current[k] != null &&
              (k != 'publishAt' || privacyStatus == 'private'))
            k: current[k],
        'privacyStatus': privacyStatus,
      };
      await _dio.put<dynamic>(
        '${YoutubeApiConstants.apiBaseUrl}/videos',
        queryParameters: {'part': 'status'},
        data: {'id': videoId, 'status': status},
        options: headers,
      );
    } on DioException catch (e) {
      throw mapYoutubeDioError(e, fallback: 'Failed to change visibility');
    }
  }

  /// `videos.delete` (50 units). Permanently deletes the video from YouTube.
  Future<void> deleteVideo(String accessToken, String videoId) async {
    try {
      await _dio.delete<dynamic>(
        '${YoutubeApiConstants.apiBaseUrl}/videos',
        queryParameters: {'id': videoId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw mapYoutubeDioError(e, fallback: 'Failed to delete video');
    }
  }

  /// `playlists.delete` (50 units). The playlist's videos are not deleted.
  Future<void> deletePlaylist(String accessToken, String playlistId) async {
    try {
      await _dio.delete<dynamic>(
        '${YoutubeApiConstants.apiBaseUrl}/playlists',
        queryParameters: {'id': playlistId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw mapYoutubeDioError(e,
          fallback: 'Failed to delete playlist', notFoundIsPlaylist: true);
    }
  }
}
