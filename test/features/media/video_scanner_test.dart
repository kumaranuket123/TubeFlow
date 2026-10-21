import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/features/media/domain/media_video.dart';
import 'package:tube_flow/features/media/domain/video_scanner_service.dart';
import 'package:tube_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tube_flow/features/upload/data/repositories/upload_queue_repository_impl.dart';
import 'package:tube_flow/features/upload/domain/upload_manager.dart';
import 'package:tube_flow/features/upload/domain/youtube_uploader.dart';

class _NoopUploader implements YoutubeUploader {
  @override
  Future<String> uploadVideo({
    required File file,
    required String title,
    required String description,
    required String privacyStatus,
    String? sessionUri,
    required Future<void> Function(String sessionUri) onSessionStarted,
    required void Function(double) onProgress,
    required CancelToken cancelToken,
  }) async => 'id';
  @override
  Future<String?> privacyStatusOf(String videoId) async => 'private';
  @override
  Future<void> addToPlaylist(String playlistId, String videoId) async {}
}

class _FakeMediaStore implements MediaStoreService {
  List<MediaVideo> videos = [];
  DateTime? lastSince;
  void Function()? onQuery;

  @override
  Future<List<MediaVideo>> queryVideos({DateTime? since}) async {
    lastSince = since;
    return videos;
  }

  @override
  Future<int?> currentSize(String uri) async => null;

  @override
  Future<bool> deleteVideos(List<String> uris) async => false;

  @override
  Stream<void> get changes => const Stream.empty();
}

void main() {
  late AppDatabase db;
  late _FakeMediaStore store;
  late VideoScannerService scanner;
  late UploadQueueRepositoryImpl repo;
  late Directory tmp;

  MediaVideo video(String id, File f, {int? size}) => MediaVideo(
        id: id,
        uri: 'content://media/external/video/media/$id',
        name: f.uri.pathSegments.last,
        size: size ?? f.lengthSync(),
        dateAdded: DateTime(2026, 1, 1),
        path: f.path,
      );

  File file(String name, int bytes) =>
      File('${tmp.path}/$name')..writeAsBytesSync(List.filled(bytes, 1));

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('tf_scan');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UploadQueueRepositoryImpl(db);
    final settings = SettingsRepositoryImpl(db);
    store = _FakeMediaStore();
    scanner = VideoScannerService(
      mediaStore: store,
      manager: UploadManager(
          queue: repo, settings: settings, uploader: _NoopUploader()),
      settings: settings,
      stabilityDelay: const Duration(milliseconds: 20),
    );
  });

  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('queues unseen videos and skips them on the next scan', () async {
    store.videos = [video('1', file('a.mp4', 50)), video('2', file('b.mp4', 60))];
    final first = await scanner.scan();
    expect(first.added, 2);
    final second = await scanner.scan();
    expect(second.added, 0);
    expect(second.duplicates, 2);
    expect((await repo.nextPending()), isNotNull);
  });

  test('a file that grows during the stability window is not queued', () async {
    final f = file('growing.mp4', 50);
    store.videos = [video('1', f)];
    final scan = scanner.scan();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    f.writeAsBytesSync(List.filled(80, 1)); // still being written
    final r = await scan;
    expect(r.added, 0);
    expect(r.unstable, 1);
  });

  test('MediaStore size mismatch (still writing) is not queued', () async {
    final f = file('a.mp4', 50);
    store.videos = [video('1', f, size: 10)];
    expect((await scanner.scan()).unstable, 1);
  });

  test('missing file path counts as unreadable', () async {
    final f = file('a.mp4', 50);
    final v = video('1', f);
    f.deleteSync();
    store.videos = [v];
    final r = await scanner.scan();
    expect(r.unreadable, 1);
    expect(r.added, 0);
  });

  test('first scan only looks back 24h from the baseline', () async {
    await scanner.scan();
    final since = store.lastSince!;
    final expected = DateTime.now().subtract(const Duration(hours: 24));
    expect(since.difference(expected).inSeconds.abs(), lessThan(5));
  });
}
