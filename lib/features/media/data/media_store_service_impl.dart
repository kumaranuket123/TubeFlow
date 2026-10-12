import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/media_video.dart';

class MediaStoreServiceImpl implements MediaStoreService {
  MediaStoreServiceImpl() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'mediaChanged') _changes.add(null);
    });
  }

  static const _channel = MethodChannel('tubeflow/mediastore');
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<MediaVideo>> queryVideos({DateTime? since}) async {
    try {
      final rows = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'queryVideos',
        {'sinceSeconds': (since?.millisecondsSinceEpoch ?? 0) ~/ 1000},
      );
      return (rows ?? const []).map(MediaVideo.fromMap).toList();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw const MediaPermissionDeniedException();
      }
      rethrow;
    }
  }

  @override
  Future<bool> deleteVideos(List<String> uris) async {
    try {
      return await _channel.invokeMethod<bool>('deleteVideos', {'uris': uris}) ??
          false;
    } on PlatformException catch (e) {
      if (e.code == 'UNSUPPORTED') {
        throw UnsupportedError('Deleting originals needs Android 11 or newer.');
      }
      rethrow;
    }
  }

  @override
  Future<int?> currentSize(String uri) =>
      _channel.invokeMethod<int>('getSize', {'uri': uri});
}
