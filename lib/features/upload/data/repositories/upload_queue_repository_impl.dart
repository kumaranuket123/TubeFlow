import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/video_upload_item.dart';
import '../../domain/upload_queue_repository.dart';

class UploadQueueRepositoryImpl implements UploadQueueRepository {
  UploadQueueRepositoryImpl(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  $UploadQueueTable get _t => _db.uploadQueue;

  VideoUploadItem _map(UploadQueueRow r) => VideoUploadItem(
        id: r.id,
        mediaStoreId: r.mediaStoreId,
        contentUri: r.contentUri,
        localPath: r.localPath,
        fileName: r.fileName,
        fileSize: r.fileSize,
        dateTaken: r.dateTaken,
        title: r.title,
        description: r.description,
        playlistId: r.playlistId,
        status: UploadStatus.values.byName(r.status),
        progress: r.progress,
        youtubeVideoId: r.youtubeVideoId,
        sessionUri: r.sessionUri,
        privacyStatus: r.privacyStatus,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        retryCount: r.retryCount,
        errorMessage: r.errorMessage,
        originalDeleted: r.originalDeleted,
      );

  @override
  Stream<List<VideoUploadItem>> watchAll() {
    final q = _db.select(_t)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<VideoUploadItem?> get(String id) async {
    final r = await (_db.select(_t)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<VideoUploadItem?> enqueue(NewVideo v, {String? playlistId}) {
    return _db.transaction(() async {
      final cancelled = UploadStatus.cancelled.name;
      final dupe = await (_db.select(_t)
            ..where((t) =>
                t.status.equals(cancelled).not() &
                (t.contentUri.equals(v.contentUri) |
                    (v.mediaStoreId == null
                        ? const Constant(false)
                        : t.mediaStoreId.equals(v.mediaStoreId!)) |
                    (t.fileName.equals(v.fileName) &
                        t.fileSize.equals(v.fileSize) &
                        (v.dateTaken == null
                            ? t.dateTaken.isNull()
                            : t.dateTaken.equals(v.dateTaken!)))))
            ..limit(1))
          .getSingleOrNull();
      if (dupe != null) return null;

      // A cancelled row with the same content URI would violate the unique
      // constraint; reuse the slot by removing it.
      await (_db.delete(_t)..where((t) => t.contentUri.equals(v.contentUri)))
          .go();

      final now = _now();
      final id = _uuid.v4();
      await _db.into(_t).insert(UploadQueueCompanion.insert(
            id: id,
            mediaStoreId: Value(v.mediaStoreId),
            contentUri: v.contentUri,
            localPath: Value(v.localPath),
            fileName: v.fileName,
            fileSize: v.fileSize,
            dateTaken: Value(v.dateTaken),
            title: v.title ?? v.fileName.replaceFirst(RegExp(r'\.[^.]+$'), ''),
            description: Value(v.description),
            playlistId: Value(playlistId),
            status: UploadStatus.waiting.name,
            createdAt: now,
            updatedAt: now,
          ));
      return get(id);
    });
  }

  @override
  Future<VideoUploadItem?> nextPending({Set<String> excluding = const {}}) async {
    final r = await (_db.select(_t)
          ..where((t) => t.status.isIn([
                UploadStatus.waiting.name,
                UploadStatus.addingToPlaylist.name,
              ]) &
              t.id.isNotIn(excluding))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<void> update(
    String id, {
    UploadStatus? status,
    double? progress,
    String? youtubeVideoId,
    String? sessionUri,
    String? privacyStatus,
    String? playlistId,
    int? retryCount,
    String? errorMessage,
    bool clearError = false,
    bool clearSessionUri = false,
  }) async {
    await (_db.update(_t)..where((t) => t.id.equals(id))).write(
      UploadQueueCompanion(
        status: Value.absentIfNull(status?.name),
        progress: Value.absentIfNull(progress),
        youtubeVideoId: Value.absentIfNull(youtubeVideoId),
        sessionUri: clearSessionUri
            ? const Value(null)
            : Value.absentIfNull(sessionUri),
        privacyStatus: clearSessionUri
            ? const Value(null)
            : Value.absentIfNull(privacyStatus),
        playlistId: Value.absentIfNull(playlistId),
        retryCount: Value.absentIfNull(retryCount),
        errorMessage:
            clearError ? const Value(null) : Value.absentIfNull(errorMessage),
        updatedAt: Value(_now()),
      ),
    );
  }

  @override
  Future<void> resetInterrupted() async {
    await _db.transaction(() async {
      final inFlight = [
        UploadStatus.preparing.name,
        UploadStatus.uploading.name,
        UploadStatus.processing.name,
        UploadStatus.addingToPlaylist.name,
      ];
      final rows =
          await (_db.select(_t)..where((t) => t.status.isIn(inFlight))).get();
      for (final r in rows) {
        final next = r.youtubeVideoId != null
            ? UploadStatus.addingToPlaylist
            : UploadStatus.waiting;
        await (_db.update(_t)..where((t) => t.id.equals(r.id))).write(
          UploadQueueCompanion(
            status: Value(next.name),
            updatedAt: Value(_now()),
          ),
        );
      }
    });
  }

  @override
  Future<void> clearPlaylist(String playlistId) async {
    await (_db.update(_t)..where((t) => t.playlistId.equals(playlistId)))
        .write(const UploadQueueCompanion(playlistId: Value(null)));
  }

  @override
  Future<void> delete(String id) =>
      (_db.delete(_t)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> markOriginalsDeleted(Iterable<String> ids) async {
    await (_db.update(_t)..where((t) => t.id.isIn(ids.toList())))
        .write(UploadQueueCompanion(
      originalDeleted: const Value(true),
      updatedAt: Value(_now()),
    ));
  }
}
