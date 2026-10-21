import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/features/settings/domain/entities/app_settings.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/core/error/exceptions.dart';
import 'package:tube_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tube_flow/features/upload/data/repositories/upload_queue_repository_impl.dart';
import 'package:tube_flow/features/upload/domain/entities/upload_status.dart';
import 'package:tube_flow/features/upload/domain/entities/video_upload_item.dart';
import 'package:tube_flow/features/upload/domain/upload_manager.dart';
import 'package:tube_flow/features/upload/domain/youtube_uploader.dart';

class FakeUploader implements YoutubeUploader {
  int uploads = 0;
  int playlistCalls = 0;
  bool playlistFails = false;
  Object? playlistError;
  bool private = true;
  Object? uploadFailure;
  void Function()? onUpload;
  String? lastSessionUri;
  String? lastPrivacy;
  String? statusOverride;
  int uploadAttempts = 0;

  /// Simulates a long upload: blocks until the cancel token fires.
  bool holdUntilCancelled = false;

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
  }) async {
    uploadAttempts++;
    onUpload?.call();
    lastSessionUri = sessionUri;
    lastPrivacy = privacyStatus;
    if (uploadFailure != null) throw uploadFailure!;
    if (holdUntilCancelled) {
      await onSessionStarted('held-session');
      await cancelToken.whenCancel;
      throw DioException.requestCancelled(
        requestOptions: RequestOptions(),
        reason: cancelToken.cancelError?.error,
      );
    }
    uploads++;
    await onSessionStarted('session$uploads');
    onProgress(0.5);
    return 'vid$uploads';
  }

  @override
  Future<String?> privacyStatusOf(String videoId) async =>
      statusOverride ?? (private ? (lastPrivacy ?? 'private') : 'public');

  @override
  Future<void> addToPlaylist(String playlistId, String videoId) async {
    playlistCalls++;
    if (playlistError != null) throw playlistError!;
    if (playlistFails) {
      throw const YoutubeApiException('Selected playlist is no longer available.');
    }
  }
}

void main() {
  late AppDatabase db;
  late UploadQueueRepositoryImpl repo;
  late SettingsRepositoryImpl settings;
  late FakeUploader uploader;
  late UploadManager manager;
  late Directory tmp;

  NewVideo video(String name, {int size = 10, String? msId}) {
    final f = File('${tmp.path}/$name')..writeAsBytesSync(List.filled(size, 1));
    return NewVideo(
      mediaStoreId: msId,
      contentUri: f.uri.toString(),
      localPath: f.path,
      fileName: name,
      fileSize: size,
      dateTaken: DateTime(2026, 1, 1),
    );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UploadQueueRepositoryImpl(db);
    settings = SettingsRepositoryImpl(db);
    await settings.setPlaylist('PL1', 'Mine');
    uploader = FakeUploader();
    manager = UploadManager(queue: repo, settings: settings, uploader: uploader);
    tmp = Directory.systemTemp.createTempSync('tf_test');
  });

  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('happy path ends COMPLETED with video id after playlist insert', () async {
    final item = (await manager.enqueue(video('a.mp4')))!;
    expect(item.status, UploadStatus.waiting);
    await manager.start();
    final done = (await repo.get(item.id))!;
    expect(done.status, UploadStatus.completed);
    expect(done.youtubeVideoId, 'vid1');
    expect(done.playlistId, 'PL1');
  });

  test('duplicates are rejected by media id, uri, and name+size+date', () async {
    expect(await manager.enqueue(video('a.mp4', msId: '7')), isNotNull);
    expect(await manager.enqueue(video('b.mp4', msId: '7')), isNull);
    final a = video('a.mp4', msId: '8');
    expect(await manager.enqueue(a), isNull);
  });

  test('completed videos are never uploaded twice', () async {
    await manager.enqueue(video('a.mp4'));
    await manager.start();
    expect(await manager.enqueue(video('a.mp4')), isNull);
    await manager.start();
    expect(uploader.uploads, 1);
  });

  test('playlist failure keeps video id and retry does not re-upload', () async {
    uploader.playlistFails = true;
    final item = (await manager.enqueue(video('a.mp4')))!;
    await manager.start();
    var row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.failed);
    expect(row.youtubeVideoId, 'vid1');
    expect(row.errorMessage, contains('no longer available'));

    uploader.playlistFails = false;
    await manager.retry(item.id);
    await manager.start();
    row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.completed);
    expect(uploader.uploads, 1);
    expect(row.retryCount, greaterThan(0));
  });

  test('non-private video is not added to playlist', () async {
    uploader.private = false;
    final item = (await manager.enqueue(video('a.mp4')))!;
    await manager.start();
    expect((await repo.get(item.id))!.status, UploadStatus.failed);
    expect(uploader.playlistCalls, 0);
  });

  test('deleted file fails with a clear message', () async {
    final v = video('a.mp4');
    final item = (await manager.enqueue(v))!;
    File(v.localPath!).deleteSync();
    await manager.start();
    final row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.failed);
    expect(row.errorMessage, 'Original video is no longer available.');
  });

  test('resetInterrupted restores in-flight items after restart', () async {
    final a = (await manager.enqueue(video('a.mp4')))!;
    final b = (await manager.enqueue(video('b.mp4')))!;
    await repo.update(a.id, status: UploadStatus.uploading);
    await repo.update(b.id,
        status: UploadStatus.processing, youtubeVideoId: 'x');
    await repo.resetInterrupted();
    expect((await repo.get(a.id))!.status, UploadStatus.waiting);
    expect((await repo.get(b.id))!.status, UploadStatus.addingToPlaylist);
  });

  test('items are processed one at a time, oldest first', () async {
    final a = (await manager.enqueue(video('a.mp4')))!;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final b = (await manager.enqueue(video('b.mp4')))!;
    await Future.wait([manager.start(), manager.start()]);
    expect((await repo.get(a.id))!.youtubeVideoId, 'vid1');
    expect((await repo.get(b.id))!.youtubeVideoId, 'vid2');
  });

  test('cancelled waiting item is skipped and can be re-enqueued', () async {
    final a = (await manager.enqueue(video('a.mp4')))!;
    await manager.cancel(a.id);
    await manager.start();
    expect(uploader.uploads, 0);
    expect(await manager.enqueue(video('a.mp4')), isNotNull);
  });

  test('transient failure defers the item, keeps it WAITING, no hot loop',
      () async {
    uploader.uploadFailure = const TransientUploadException();
    final item = (await manager.enqueue(video('a.mp4')))!;
    await manager.start();
    final row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.waiting);
    expect(row.errorMessage, 'Upload interrupted. Retrying...');
    expect(row.retryCount, 1);
    expect(uploader.uploadAttempts, 1, reason: 'not retried within one run');

    uploader.uploadFailure = null;
    await manager.start();
    expect((await repo.get(item.id))!.status, UploadStatus.completed);
  });

  test('gives up after maxAutoRetries transient failures', () async {
    uploader.uploadFailure = const TransientUploadException();
    final item = (await manager.enqueue(video('a.mp4')))!;
    for (var i = 0; i < UploadManager.maxAutoRetries + 1; i++) {
      await manager.start();
    }
    final row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.failed);
    expect(row.errorMessage, contains('several retries'));
  });

  test('a stored session is passed on resume; discarded if the file changed',
      () async {
    final v = video('a.mp4', size: 10);
    final item = (await manager.enqueue(v))!;
    await repo.update(item.id, sessionUri: 'https://upload/session-1');
    await manager.start();
    expect(uploader.lastSessionUri, 'https://upload/session-1');

    final v2 = video('b.mp4', size: 10);
    final item2 = (await manager.enqueue(v2))!;
    await repo.update(item2.id, sessionUri: 'https://upload/stale');
    File(v2.localPath!).writeAsBytesSync(List.filled(20, 1)); // changed
    await manager.start();
    expect(uploader.lastSessionUri, isNull);
  });

  test('no playlist selected: fails before uploading anything', () async {
    await settings.setPlaylist(null, null);
    final item = (await manager.enqueue(video('a.mp4')))!;
    await manager.start();
    final row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.failed);
    expect(row.errorMessage, 'Choose an upload playlist first.');
    expect(uploader.uploadAttempts, 0);
  });

  test('resumed session keeps its visibility; fresh uploads use the setting',
      () async {
    final item = (await manager.enqueue(video('a.mp4')))!;
    await repo.update(item.id,
        sessionUri: 'https://upload/s', privacyStatus: 'private');
    await settings.setVisibility(UploadVisibility.unlisted);
    await manager.start();
    expect(uploader.lastPrivacy, 'private');
    expect((await repo.get(item.id))!.status, UploadStatus.completed);

    await manager.enqueue(video('b.mp4'));
    await manager.start();
    expect(uploader.lastPrivacy, 'unlisted');
  });

  test('upload whose visibility differs from the requested one is not added',
      () async {
    uploader.statusOverride = 'unlisted'; // requested private (default)
    final item = (await manager.enqueue(video('a.mp4')))!;
    await manager.start();
    final row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.failed);
    expect(row.errorMessage, contains('expected private'));
    expect(uploader.playlistCalls, 0);
  });

  test('quota error pauses the whole queue without failing items; resumes after reset',
      () async {
    var now = DateTime.utc(2026, 7, 10, 12);
    manager = UploadManager(
        queue: repo, settings: settings, uploader: uploader, clock: () => now);
    final a = (await manager.enqueue(video('a.mp4')))!;
    final b = (await manager.enqueue(video('b.mp4')))!;

    uploader.uploadFailure = const QuotaExceededException('quota');
    await manager.start();

    // Only the first item was attempted; both wait, none failed or retried.
    expect(uploader.uploadAttempts, 1);
    for (final id in [a.id, b.id]) {
      final row = (await repo.get(id))!;
      expect(row.status, UploadStatus.waiting);
      expect(row.retryCount, 0);
    }
    expect((await repo.get(a.id))!.errorMessage, contains('Paused'));
    expect(await settings.quotaPausedUntil(), isNotNull);

    // Still the same Pacific day: starting again does nothing.
    uploader.uploadFailure = null;
    await manager.start();
    expect(uploader.uploadAttempts, 1);

    // After the reset (+ margin) everything uploads and the pause clears.
    now = (await settings.quotaPausedUntil())!.add(const Duration(minutes: 1));
    await manager.start();
    expect((await repo.get(a.id))!.status, UploadStatus.completed);
    expect((await repo.get(b.id))!.status, UploadStatus.completed);
    expect(await settings.quotaPausedUntil(), isNull);
  });

  test('quota error while adding to playlist keeps the video id (no re-upload)',
      () async {
    var now = DateTime.utc(2026, 7, 10, 12);
    manager = UploadManager(
        queue: repo, settings: settings, uploader: uploader, clock: () => now);
    final item = (await manager.enqueue(video('a.mp4')))!;
    uploader.playlistError = const QuotaExceededException('quota');
    await manager.start();
    var row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.addingToPlaylist);
    expect(row.youtubeVideoId, 'vid1');

    uploader.playlistError = null;
    now = (await settings.quotaPausedUntil())!.add(const Duration(minutes: 1));
    await manager.start();
    row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.completed);
    expect(uploader.uploads, 1);
  });

  test('cancelAll cancels unfinished items; clearFinished removes finished ones',
      () async {
    await manager.enqueue(video('done.mp4'));
    await manager.start(); // completes
    final a = (await manager.enqueue(video('a.mp4')))!;
    final b = (await manager.enqueue(video('b.mp4')))!;

    expect(await manager.cancelAll(), 2);
    expect((await repo.get(a.id))!.status, UploadStatus.cancelled);
    expect((await repo.get(b.id))!.status, UploadStatus.cancelled);
    await manager.start();
    expect(uploader.uploads, 1); // nothing more was uploaded

    expect(await manager.clearFinished(), 3);
    expect(await repo.watchAll().first, isEmpty);
  });

  test('clearFinished keeps a failed item that is already on YouTube', () async {
    uploader.playlistFails = true;
    final item = (await manager.enqueue(video('a.mp4')))!;
    await manager.start();
    expect((await repo.get(item.id))!.status, UploadStatus.failed);
    expect(await manager.clearFinished(), 0);
    expect(await repo.get(item.id), isNotNull);
  });
}
