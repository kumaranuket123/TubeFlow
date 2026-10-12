import 'package:dio/dio.dart';

import '../../../../core/constants/youtube_api_constants.dart';
import '../../../../core/error/youtube_error_mapper.dart';
import '../../domain/entities/youtube_playlist.dart';

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
        result.addAll((data['items'] as List? ?? const [])
            .map((e) => YoutubePlaylist.fromJson(e as Map<String, dynamic>)));
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

  /// `playlists.insert` (50 quota units). Always created PRIVATE.
  Future<YoutubePlaylist> createPrivatePlaylist({
    required String accessToken,
    required String title,
    String description = '',
  }) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '${YoutubeApiConstants.apiBaseUrl}/playlists',
        queryParameters: {'part': 'snippet,status,contentDetails'},
        data: {
          'snippet': {'title': title, 'description': description},
          'status': {'privacyStatus': 'private'},
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return YoutubePlaylist.fromJson(r.data!);
    } on DioException catch (e) {
      throw mapYoutubeDioError(e, fallback: 'Failed to create playlist');
    }
  }
}
