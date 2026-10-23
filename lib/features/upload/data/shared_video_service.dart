import 'dart:async';

import 'package:flutter/services.dart';

/// A video another app (Gallery, Files) shared to TubeFlow.
class SharedVideo {
  const SharedVideo({
    required this.name,
    required this.size,
    required this.path,
    required this.uri,
    this.mediaStoreId,
  });

  final String name;
  final int size;
  final String path;
  final String uri;
  final String? mediaStoreId;

  factory SharedVideo.fromMap(Map<dynamic, dynamic> m) => SharedVideo(
        name: m['name'] as String,
        size: (m['size'] as num).toInt(),
        path: m['path'] as String,
        uri: m['uri'] as String,
        mediaStoreId: m['mediaId'] as String?,
      );
}

/// Receives Android share-sheet intents (`tubeflow/share` channel).
class SharedVideoService {
  SharedVideoService() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedVideos') _arrivals.add(null);
    });
  }

  static const _channel = MethodChannel('tubeflow/share');
  final _arrivals = StreamController<void>.broadcast();

  /// Fires when a share arrives while the app is already running.
  Stream<void> get arrivals => _arrivals.stream;

  /// Videos shared since the last call (empty if none).
  Future<List<SharedVideo>> take() async {
    final rows = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'takeSharedVideos',
    );
    return (rows ?? const []).map(SharedVideo.fromMap).toList();
  }
}
