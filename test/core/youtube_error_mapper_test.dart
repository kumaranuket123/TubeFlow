import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/error/exceptions.dart';
import 'package:tube_flow/core/error/youtube_error_mapper.dart';

DioException _err(int? status, {Object? body}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    response: status == null
        ? null
        : Response(requestOptions: req, statusCode: status, data: body),
  );
}

Map<String, dynamic> _reason(String r) => {
      'error': {
        'errors': [
          {'reason': r}
        ]
      }
    };

void main() {
  test('network loss and 5xx are transient (retried, not failed)', () {
    expect(mapYoutubeDioError(_err(null)), isA<TransientUploadException>());
    expect(mapYoutubeDioError(_err(503)), isA<TransientUploadException>());
  });

  test('401 asks the user to reconnect', () {
    final e = mapYoutubeDioError(_err(401));
    expect(e, isA<ReauthRequiredException>());
    expect(e.toString(), 'Please reconnect your YouTube account');
  });

  test('quota reasons map to the quota message', () {
    for (final r in ['quotaExceeded', 'uploadLimitExceeded', 'dailyLimitExceeded']) {
      final e = mapYoutubeDioError(_err(403, body: _reason(r)));
      expect((e as YoutubeApiException).message,
          'YouTube upload quota reached. Try again later.');
    }
  });

  test('missing playlist maps to the playlist message', () {
    final byReason = mapYoutubeDioError(_err(404, body: _reason('playlistNotFound')));
    expect((byReason as YoutubeApiException).message,
        'Selected playlist is no longer available.');
    final byContext = mapYoutubeDioError(_err(404), notFoundIsPlaylist: true);
    expect((byContext as YoutubeApiException).message,
        'Selected playlist is no longer available.');
  });

  test('unknown 4xx keeps the fallback and status code', () {
    final e = mapYoutubeDioError(_err(400), fallback: 'nope') as YoutubeApiException;
    expect(e.message, 'nope');
    expect(e.statusCode, 400);
  });
}
