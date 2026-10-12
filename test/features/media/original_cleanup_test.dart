import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/features/media/domain/media_video.dart';
import 'package:tube_flow/features/media/domain/original_cleanup_service.dart';
import 'package:tube_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tube_flow/features/upload/data/repositories/upload_queue_repository_impl.dart';
import 'package:tube_flow/features/upload/domain/entities/upload_status.dart';
import 'package:tube_flow/features/upload/domain/entities/video_upload_item.dart';

class _Store implements MediaStoreService {
  bool confirm = true;
  List<String>? asked;

  @override
  Future<bool> deleteVideos(List<String> uris) async {
    asked = uris;
    return confirm;
  }

  @override
  Future<List<MediaVideo>> queryVideos({DateTime? since}) async => [];
  @override
  Future<int?> currentSize(String uri) async => null;
  @override
  Stream<void> get changes => const Stream.empty();
}

void main() {
  late AppDatabase db;
  late UploadQueueRepositoryImpl repo;
  late SettingsRepositoryImpl settings;
  late _Store store;
  late OriginalCleanupService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UploadQueueRepositoryImpl(db);
    settings = SettingsRepositoryImpl(db);
    store = _Store();
    service = OriginalCleanupService(queue: repo, mediaStore: store, settings: settings);
  });
  tearDown(() => db.close());

  Future<VideoUploadItem> item(String n, UploadStatus st, {String? msId = 'x'}) async {
    final i = (await repo.enqueue(NewVideo(
      mediaStoreId: msId == null ? null : '$msId$n',
      contentUri: 'content://media/$n',
      fileName: '$n.mp4',
      fileSize: 5,
    )))!;
    await repo.update(i.id, status: st);
    return (await repo.get(i.id))!;
  }

  test('Keep original ON (default): never asks to delete', () async {
    final a = await item('a', UploadStatus.completed);
    expect(await service.deleteUploadedOriginals([a]), 0);
    expect(store.asked, isNull);
  });

  test('only completed MediaStore items are offered for deletion', () async {
    await settings.setKeepOriginal(false);
    final done = await item('a', UploadStatus.completed);
    final failed = await item('b', UploadStatus.failed);
    final waiting = await item('c', UploadStatus.waiting);
    final picked = await item('d', UploadStatus.completed, msId: null);
    final n = await service.deleteUploadedOriginals([done, failed, waiting, picked]);
    expect(n, 1);
    expect(store.asked, ['content://media/a']);
  });

  test('refusing the system dialog deletes and marks nothing', () async {
    await settings.setKeepOriginal(false);
    final a = await item('a', UploadStatus.completed);
    store.confirm = false;
    expect(await service.deleteUploadedOriginals([a]), 0);
    expect((await repo.get(a.id))!.originalDeleted, isFalse);
  });

  test('after confirming, rows are kept (dedupe) and marked deleted', () async {
    await settings.setKeepOriginal(false);
    final a = await item('a', UploadStatus.completed);
    expect(await service.deleteUploadedOriginals([a]), 1);
    final row = (await repo.get(a.id))!;
    expect(row.originalDeleted, isTrue);
    expect(row.originalDeletable, isFalse);
    // Still blocks re-upload of the same video.
    expect(await repo.enqueue(NewVideo(
      mediaStoreId: 'xa', contentUri: 'content://media/a', fileName: 'a.mp4', fileSize: 5)), isNull);
  });
}
