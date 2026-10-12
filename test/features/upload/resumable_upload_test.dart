import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/error/exceptions.dart';
import 'package:tube_flow/features/upload/data/youtube_upload_remote_datasource.dart';

class _Req {
  _Req(this.method, this.url, this.headers, this.bodyLength);
  final String method;
  final String url;
  final Map<String, dynamic> headers;
  final int bodyLength;
  String? get range => headers['Content-Range'] as String?;
}

typedef _Responder = ResponseBody Function(_Req req, int index);

/// HTTP-boundary fake: records every request and answers from a script.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);
  final _Responder responder;
  final requests = <_Req>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    var length = 0;
    if (requestStream != null) {
      await for (final c in requestStream) {
        length += c.length;
      }
    }
    final req = _Req(options.method, options.uri.toString(),
        Map.of(options.headers), length);
    requests.add(req);
    return responder(req, requests.length - 1);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _res(int status,
    {Map<String, List<String>> headers = const {}, Object? json}) {
  return ResponseBody.fromString(
    json == null ? '' : jsonEncode(json),
    status,
    headers: {
      if (json != null) Headers.contentTypeHeader: ['application/json'],
      ...headers,
    },
  );
}

ResponseBody _created(String id) => _res(200, json: {'id': id});
ResponseBody _session([String uri = 'https://upload.example/s1']) =>
    _res(200, headers: {'location': [uri]});
ResponseBody _more(int lastByte) => _res(308, headers: {
      'range': ['bytes=0-$lastByte']
    });

void main() {
  late Directory tmp;
  late File file;
  const total = 10;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('tf_resumable');
    file = File('${tmp.path}/v.mp4')..writeAsBytesSync(List.filled(total, 7));
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  YoutubeUploadRemoteDataSource ds(_FakeAdapter a, {int retries = 5}) {
    final dio = Dio()..httpClientAdapter = a;
    return YoutubeUploadRemoteDataSource(dio,
        chunkSize: 4, maxChunkRetries: retries, delay: (_) async {});
  }

  test('uploads in chunks with Content-Range and reports progress', () async {
    final a = _FakeAdapter((r, i) => switch (i) {
          0 => _session(),
          1 => _more(3),
          2 => _more(7),
          _ => _created('vid1'),
        });
    final sessions = <String>[];
    final progress = <double>[];
    final id = await ds(a).uploadVideo(
      accessToken: 't',
      file: file,
      title: 'x',
      onSessionStarted: (s) async => sessions.add(s),
      onProgress: progress.add,
    );
    expect(id, 'vid1');
    expect(sessions, ['https://upload.example/s1']);
    expect(a.requests.skip(1).map((r) => r.range),
        ['bytes 0-3/10', 'bytes 4-7/10', 'bytes 8-9/10']);
    expect(a.requests.skip(1).map((r) => r.bodyLength), [4, 4, 2]);
    expect(progress.last, 1);
    // Session init is private.
    expect(a.requests.first.url, contains('uploadType=resumable'));
  });

  test('resumes a stored session from the server-reported offset', () async {
    final a = _FakeAdapter((r, i) => switch (i) {
          0 => _more(4), // status query: server has bytes 0-4
          1 => _more(8),
          _ => _created('vid2'),
        });
    final id = await ds(a).uploadVideo(
      accessToken: 't',
      file: file,
      title: 'x',
      sessionUri: 'https://upload.example/old',
      onSessionStarted: (_) async => fail('must not start a new session'),
      onProgress: (_) {},
    );
    expect(id, 'vid2');
    expect(a.requests[0].range, 'bytes */10');
    expect(a.requests[1].range, 'bytes 5-8/10');
    expect(a.requests[2].range, 'bytes 9-9/10');
    expect(a.requests.every((r) => r.url.startsWith('https://upload.example/old')),
        isTrue);
  });

  test('stored session already complete returns the video id', () async {
    final a = _FakeAdapter((r, i) => _created('done'));
    final id = await ds(a).uploadVideo(
      accessToken: 't', file: file, title: 'x',
      sessionUri: 'https://upload.example/old',
      onSessionStarted: (_) async {}, onProgress: (_) {},
    );
    expect(id, 'done');
    expect(a.requests, hasLength(1));
  });

  test('expired session (404) starts a new one from byte 0', () async {
    final a = _FakeAdapter((r, i) => switch (i) {
          0 => _res(404),
          1 => _session('https://upload.example/new'),
          2 => _more(3),
          3 => _more(7),
          _ => _created('vid3'),
        });
    final sessions = <String>[];
    final id = await ds(a).uploadVideo(
      accessToken: 't', file: file, title: 'x',
      sessionUri: 'https://upload.example/old',
      onSessionStarted: (s) async => sessions.add(s),
      onProgress: (_) {},
    );
    expect(id, 'vid3');
    expect(sessions, ['https://upload.example/new']);
    expect(a.requests[2].range, 'bytes 0-3/10');
  });

  test('5xx mid-upload: backs off, asks the server, resends from its offset',
      () async {
    final a = _FakeAdapter((r, i) => switch (i) {
          0 => _session(),
          1 => _more(3),
          2 => _res(503), // chunk 2 fails
          3 => _more(3), // status query: still only 0-3
          4 => _more(7),
          _ => _created('vid4'),
        });
    final id = await ds(a).uploadVideo(
      accessToken: 't', file: file, title: 'x',
      onSessionStarted: (_) async {}, onProgress: (_) {},
    );
    expect(id, 'vid4');
    expect(a.requests[3].range, 'bytes */10');
    expect(a.requests[4].range, 'bytes 4-7/10');
  });

  test('network that never recovers ends in TransientUploadException',
      () async {
    final a = _FakeAdapter((r, i) => i == 0 ? _session() : _res(503));
    await expectLater(
      ds(a, retries: 2).uploadVideo(
        accessToken: 't', file: file, title: 'x',
        onSessionStarted: (_) async {}, onProgress: (_) {},
      ),
      throwsA(isA<TransientUploadException>()),
    );
  });

  test('quota error is fatal with a clear message', () async {
    final a = _FakeAdapter((r, i) => i == 0
        ? _res(403, json: {
            'error': {'errors': [{'reason': 'quotaExceeded'}]}
          })
        : _created('x'));
    await expectLater(
      ds(a).uploadVideo(
        accessToken: 't', file: file, title: 'x',
        onSessionStarted: (_) async {}, onProgress: (_) {},
      ),
      throwsA(isA<YoutubeApiException>().having((e) => e.message, 'message',
          'YouTube upload quota reached. Try again later.')),
    );
  });
}
