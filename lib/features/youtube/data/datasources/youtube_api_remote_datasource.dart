import 'package:dio/dio.dart';

import '../../../../core/constants/youtube_api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/youtube_channel.dart';

/// Direct REST calls against the YouTube Data API v3. Kept free of any
/// OAuth/refresh logic — callers always pass an already-valid access token
/// (see YoutubeAuthRepository.getValidAccessToken).
class YoutubeApiRemoteDataSource {
  YoutubeApiRemoteDataSource(this._dio);

  final Dio _dio;

  Future<YoutubeChannel> getMyChannel(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        YoutubeApiConstants.myChannelUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return YoutubeChannel.fromJson(response.data!);
    } on DioException catch (e) {
      throw YoutubeApiException(
        e.message ?? 'Failed to fetch YouTube channel',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
