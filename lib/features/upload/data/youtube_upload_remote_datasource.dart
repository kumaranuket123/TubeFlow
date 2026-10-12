import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/constants/youtube_api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/youtube_error_mapper.dart';

/// `videos.insert` over YouTube's resumable-upload protocol.
///
/// 1. POST metadata → session URI (persisted by the caller via
///    [uploadVideo]'s `onSessionStarted`).
/// 2. PUT the file in [chunkSize] pieces with `Content-Range`. A 308 means
///    "send more" (its `Range` header says what the server holds); 200/201
///    carries the created video.
/// 3. After a network error/5xx, back off, ask the server what it has
///    (`Content-Range: bytes */total`) and continue from there. A stored
///    session can be resumed days later; 404/410 means it expired and a new
///    session is started.
///
/// The session URI is self-authenticating, so chunks need no access token.
class YoutubeUploadRemoteDataSource {
  YoutubeUploadRemoteDataSource(
    this._dio, {
    this.chunkSize = 8 * 1024 * 1024, // must be a multiple of 256 KiB
    this.maxChunkRetries = 5,
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final Dio _dio;
  final int chunkSize;
  final int maxChunkRetries;
  final Future<void> Function(Duration) _delay;

  /// Always uploads as PRIVATE. Returns the new YouTube video id.
  /// Throws [TransientUploadException] when retries are exhausted (the
  /// session stays valid for a later resume).
  Future<String> uploadVideo({
    required String accessToken,
    required File file,
    required String title,
    String description = '',
    String? sessionUri,
    Future<void> Function(String sessionUri)? onSessionStarted,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final total = await file.length();
    if (total == 0) throw const YoutubeApiException('The video file is empty.');

    var session = sessionUri;
    var offset = 0;
    var needResync = session != null;
    var failures = 0;

    Future<void> startNew() async {
      session = await _startSession(
          accessToken, total, title, description, cancelToken);
      offset = 0;
      needResync = false;
      await onSessionStarted?.call(session!);
    }

    if (session == null) await startNew();

    final raf = await file.open();
    try {
      while (true) {
        try {
          if (needResync) {
            final st = await _queryStatus(session!, total, cancelToken);
            needResync = false;
            if (st is _Done) return st.videoId;
            if (st is _Resume) {
              offset = st.offset;
            } else {
              await startNew();
            }
          }
          if (offset >= total) {
            // Server claims everything but did not confirm completion.
            needResync = true;
            throw _Retry();
          }

          final end = min(offset + chunkSize, total);
          await raf.setPosition(offset);
          final bytes = await raf.read(end - offset);
          final chunkStart = offset;
          final response = await _dio.put<dynamic>(
            session!,
            data: bytes,
            cancelToken: cancelToken,
            options: _chunkOptions({
              'Content-Range': 'bytes $chunkStart-${end - 1}/$total',
              Headers.contentLengthHeader: bytes.length,
            }),
            onSendProgress: (sent, _) =>
                onProgress?.call((chunkStart + sent) / total),
          );
          failures = 0;
          final done = _parseDone(response);
          if (done != null) {
            onProgress?.call(1);
            return done;
          }
          offset = _nextOffset(response.headers.value('range'));
          onProgress?.call(offset / total);
        } on _Retry {
          failures++;
          if (failures > maxChunkRetries) throw const TransientUploadException();
          await _backoff(failures);
        } on DioException catch (e) {
          if (CancelToken.isCancel(e)) rethrow;
          final code = e.response?.statusCode;
          if (code == 404 || code == 410) {
            await startNew(); // session expired
            continue;
          }
          if (code != null && code < 500) throw _fatal(e);
          failures++;
          if (failures > maxChunkRetries) throw const TransientUploadException();
          await _backoff(failures);
          needResync = true;
        }
      }
    } finally {
      await raf.close();
    }
  }

  Future<void> _backoff(int attempt) => _delay(
      Duration(seconds: min(60, 1 << (attempt - 1)))); // 1,2,4,8,16s…

  Options _chunkOptions(Map<String, Object> headers) => Options(
        headers: {...headers, Headers.contentTypeHeader: 'video/*'},
        followRedirects: false,
        validateStatus: (s) => s != null && (s < 300 || s == 308),
      );

  Future<String> _startSession(String accessToken, int length, String title,
      String description, CancelToken? cancelToken) async {
    try {
      final init = await _dio.post<dynamic>(
        '${YoutubeApiConstants.uploadBaseUrl}/videos',
        queryParameters: {'uploadType': 'resumable', 'part': 'snippet,status'},
        data: {
          'snippet': {'title': title, 'description': description},
          'status': {
            'privacyStatus': 'private',
            'selfDeclaredMadeForKids': false,
          },
        },
        cancelToken: cancelToken,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'X-Upload-Content-Length': length,
          'X-Upload-Content-Type': 'video/*',
        }),
      );
      final location = init.headers.value('location');
      if (location == null) {
        throw const YoutubeApiException('YouTube did not return an upload URL');
      }
      return location;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw mapYoutubeDioError(e, fallback: 'Could not start the upload');
    }
  }

  Future<_Status> _queryStatus(
      String session, int total, CancelToken? cancelToken) async {
    try {
      final r = await _dio.put<dynamic>(
        session,
        cancelToken: cancelToken,
        options: _chunkOptions({
          'Content-Range': 'bytes */$total',
          Headers.contentLengthHeader: 0,
        }),
      );
      final done = _parseDone(r);
      if (done != null) return _Done(done);
      return _Resume(_nextOffset(r.headers.value('range')));
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 410) return const _Expired();
      rethrow;
    }
  }

  String? _parseDone(Response<dynamic> r) {
    if (r.statusCode == 200 || r.statusCode == 201) {
      final data = r.data;
      final id = data is Map ? data['id'] as String? : null;
      if (id == null) {
        throw const YoutubeApiException('YouTube did not return a video id');
      }
      return id;
    }
    return null;
  }

  /// `Range: bytes=0-N` → N+1; no header → nothing received yet.
  int _nextOffset(String? range) {
    final m = RegExp(r'bytes=0-(\d+)').firstMatch(range ?? '');
    return m == null ? 0 : int.parse(m.group(1)!) + 1;
  }

  Exception _fatal(DioException e) =>
      mapYoutubeDioError(e, fallback: e.message ?? 'Upload failed');

  /// `videos.list` status check; true only if the video is private.
  Future<bool> isPrivate(String accessToken, String videoId) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '${YoutubeApiConstants.apiBaseUrl}/videos',
        queryParameters: {'part': 'status', 'id': videoId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final items = r.data?['items'] as List? ?? const [];
      return items.isNotEmpty && items.first['status']['privacyStatus'] == 'private';
    } on DioException catch (e) {
      throw mapYoutubeDioError(e, fallback: 'Could not verify visibility');
    }
  }
}

class _Retry implements Exception {}

sealed class _Status {
  const _Status();
}

class _Done extends _Status {
  const _Done(this.videoId);
  final String videoId;
}

class _Resume extends _Status {
  const _Resume(this.offset);
  final int offset;
}

class _Expired extends _Status {
  const _Expired();
}
