import 'upload_status.dart';

class VideoUploadItem {
  const VideoUploadItem({
    required this.id,
    this.mediaStoreId,
    required this.contentUri,
    this.localPath,
    required this.fileName,
    required this.fileSize,
    this.dateTaken,
    required this.title,
    this.description = '',
    this.playlistId,
    this.status = UploadStatus.waiting,
    this.progress = 0,
    this.youtubeVideoId,
    this.sessionUri,
    required this.createdAt,
    required this.updatedAt,
    this.retryCount = 0,
    this.errorMessage,
    this.originalDeleted = false,
  });

  final String id;
  final String? mediaStoreId;
  final String contentUri;

  /// Readable filesystem path when available (picker copy). Phase 6 adds
  /// content-URI streaming for MediaStore items.
  final String? localPath;
  final String fileName;
  final int fileSize;
  final DateTime? dateTaken;
  final String title;
  final String description;
  final String? playlistId;
  final UploadStatus status;
  final double progress;
  final String? youtubeVideoId;
  final String? sessionUri;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int retryCount;
  final String? errorMessage;
  final bool originalDeleted;

  /// Uploaded successfully and the MediaStore original still exists.
  bool get originalDeletable =>
      status.name == 'completed' && mediaStoreId != null && !originalDeleted;
}

/// What callers (scanner, picker) hand to `UploadManager.enqueue`.
class NewVideo {
  const NewVideo({
    this.mediaStoreId,
    required this.contentUri,
    this.localPath,
    required this.fileName,
    required this.fileSize,
    this.dateTaken,
    this.title,
    this.description = '',
  });

  final String? mediaStoreId;
  final String contentUri;
  final String? localPath;
  final String fileName;
  final int fileSize;
  final DateTime? dateTaken;
  final String? title;
  final String description;
}
