/// A video row from Android MediaStore.
class MediaVideo {
  const MediaVideo({
    required this.id,
    required this.uri,
    required this.name,
    required this.size,
    required this.dateAdded,
    this.dateTaken,
    this.path,
    this.relativePath,
  });

  final String id;
  final String uri;
  final String name;
  final int size;
  final DateTime dateAdded;
  final DateTime? dateTaken;

  /// Filesystem path reported by MediaStore (readable with READ_MEDIA_VIDEO).
  final String? path;
  final String? relativePath;

  DateTime get createdAt => dateTaken ?? dateAdded;

  factory MediaVideo.fromMap(Map<dynamic, dynamic> m) {
    DateTime? ms(Object? v) =>
        v == null ? null : DateTime.fromMillisecondsSinceEpoch(v as int);
    return MediaVideo(
      id: m['id'] as String,
      uri: m['uri'] as String,
      name: (m['name'] as String?) ?? 'video_${m['id']}.mp4',
      size: (m['size'] as num?)?.toInt() ?? 0,
      dateAdded:
          DateTime.fromMillisecondsSinceEpoch((m['dateAdded'] as int) * 1000),
      dateTaken: ms(m['dateTaken']),
      path: m['path'] as String?,
      relativePath: m['relativePath'] as String?,
    );
  }
}

abstract class MediaStoreService {
  /// Completed (not pending) videos added at or after [since].
  Future<List<MediaVideo>> queryVideos({DateTime? since});

  /// Current size of the content URI, or null if it is gone.
  Future<int?> currentSize(String uri);

  /// Asks Android to delete the videos. The system always shows its own
  /// confirmation dialog; returns true only if the user confirmed.
  /// Throws [UnsupportedError] on Android 10, which has no bulk request.
  Future<bool> deleteVideos(List<String> uris);

  /// Fires when MediaStore video rows change (new recording, delete, ...).
  /// Only delivered while the app process is alive.
  Stream<void> get changes;
}

class MediaPermissionDeniedException implements Exception {
  const MediaPermissionDeniedException();
  @override
  String toString() => 'Video access permission is required to scan.';
}
