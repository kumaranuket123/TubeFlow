import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tube_flow/features/upload/data/repositories/drift_runner_lease.dart';
import 'package:tube_flow/features/upload/data/repositories/upload_queue_repository_impl.dart';
import 'package:tube_flow/features/upload/domain/entities/upload_status.dart';
import 'package:tube_flow/features/upload/domain/entities/video_upload_item.dart';
import 'package:tube_flow/features/upload/domain/upload_manager.dart';

import 'upload_queue_test.dart' show FakeUploader;

void main() {
  late AppDatabase db;
  var now = 1000000;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    now = 1000000;
  });
  tearDown(() => db.close());

  DriftRunnerLease lease() => DriftRunnerLease(db, nowMs: () => now);
  const ttl = Duration(seconds: 45);

  test('only one owner holds the lease at a time', () async {
    final l = lease();
    expect(await l.acquire('a', ttl), isTrue);
    expect(await l.acquire('b', ttl), isFalse);
    expect(await l.renew('a', ttl), isTrue);
    await l.release('a');
    expect(await l.acquire('b', ttl), isTrue);
  });

  test('an expired lease (killed runner) can be taken over', () async {
    final l = lease();
    expect(await l.acquire('a', ttl), isTrue);
    now += 46000;
    expect(await l.acquire('b', ttl), isTrue);
    expect(await l.renew('a', ttl), isFalse, reason: 'a lost its lease');
  });

  test('lease does not disturb settings values', () async {
    final settings = SettingsRepositoryImpl(db);
    await settings.setPlaylist('PL', 'T');
    await lease().acquire('a', ttl);
    await settings.setWifiOnly(false);
    final s = await settings.get();
    expect(s.selectedPlaylistId, 'PL');
    expect(await lease().acquire('b', ttl), isFalse);
  });

  test('a second manager does not upload while another holds the lease',
      () async {
    final repo = UploadQueueRepositoryImpl(db);
    final settings = SettingsRepositoryImpl(db);
    await settings.setPlaylist('PL', 'T');
    final tmp = Directory.systemTemp.createTempSync('tf_lease');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final f = File('${tmp.path}/a.mp4')..writeAsBytesSync([1, 2, 3]);

    final up1 = FakeUploader();
    final up2 = FakeUploader();
    final m1 = UploadManager(
        queue: repo, settings: settings, uploader: up1,
        lease: lease(), owner: 'one');
    final m2 = UploadManager(
        queue: repo, settings: settings, uploader: up2,
        lease: lease(), owner: 'two');

    final item = (await m1.enqueue(NewVideo(
      contentUri: f.uri.toString(),
      localPath: f.path,
      fileName: 'a.mp4',
      fileSize: 3,
    )))!;

    expect(await lease().acquire('one', ttl), isTrue); // runner one is active
    await m2.start();
    expect(up2.uploads, 0);
    expect((await repo.get(item.id))!.status, UploadStatus.waiting);

    await lease().release('one');
    await m2.start();
    expect(up2.uploads, 1);
    expect((await repo.get(item.id))!.status, UploadStatus.completed);
  });
}
