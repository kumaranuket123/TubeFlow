import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tube_flow/features/upload/data/repositories/upload_queue_repository_impl.dart';
import 'package:tube_flow/features/upload/domain/entities/upload_status.dart';
import 'package:tube_flow/features/upload/domain/entities/video_upload_item.dart';
import 'package:tube_flow/features/upload/domain/upload_manager.dart';
import 'package:tube_flow/features/youtube/domain/entities/youtube_playlist.dart';
import 'package:tube_flow/features/youtube/domain/entities/youtube_playlist_video.dart';
import 'package:tube_flow/features/youtube/domain/playlist_provisioner.dart';
import 'package:tube_flow/features/youtube/domain/services/youtube_playlist_service.dart';

import '../upload/upload_queue_test.dart' show FakeUploader;

class _FakePlaylists implements YoutubePlaylistService {
  _FakePlaylists(this.existing);
  List<YoutubePlaylist> existing;
  final created = <String>[];

  @override
  Future<List<YoutubePlaylist>> getMyPlaylists() async => existing;

  @override
  Future<List<YoutubePlaylistVideo>> getPlaylistVideos(String playlistId) async => const [];

  @override
  Future<void> deleteVideo(String videoId) async {}

  @override
  Future<void> deletePlaylist(String playlistId) async {}

  @override
  Future<void> setVideoPrivacy(String videoId, String privacyStatus) async {}

  @override
  Future<YoutubePlaylist> createPlaylist(String title, {String privacyStatus = 'private'}) async {
    created.add(title);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final p = YoutubePlaylist(id: 'NEW${created.length}', title: title, privacyStatus: 'private');
    existing = [p];
    return p;
  }
}

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl settings;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('channel with no playlists: creates a private one and selects it', () async {
    final api = _FakePlaylists([]);
    final id = await PlaylistProvisioner(playlists: api, settings: settings)
        .ensureDefaultPlaylist();
    expect(id, 'NEW1');
    expect(api.created, [PlaylistProvisioner.defaultTitle]);
    final s = await settings.get();
    expect(s.selectedPlaylistId, 'NEW1');
    expect(s.selectedPlaylistTitle, PlaylistProvisioner.defaultTitle);
  });

  test('channel with playlists but none chosen: creates nothing', () async {
    final api = _FakePlaylists([const YoutubePlaylist(id: 'A', title: 'Mine')]);
    final id = await PlaylistProvisioner(playlists: api, settings: settings)
        .ensureDefaultPlaylist();
    expect(id, isNull);
    expect(api.created, isEmpty);
  });

  test('an already selected playlist is returned without any API call', () async {
    await settings.setPlaylist('SEL', 'Chosen');
    final api = _FakePlaylists([]);
    final id = await PlaylistProvisioner(playlists: api, settings: settings)
        .ensureDefaultPlaylist();
    expect(id, 'SEL');
    expect(api.created, isEmpty);
  });

  test('concurrent callers create only one playlist', () async {
    final api = _FakePlaylists([]);
    final p = PlaylistProvisioner(playlists: api, settings: settings);
    final ids = await Future.wait([p.createDefault(), p.createDefault()]);
    expect(ids.map((e) => e.id).toSet(), hasLength(1));
    expect(api.created, hasLength(1));
  });

  test('upload with no playlist anywhere: creates one, uploads into it', () async {
    final api = _FakePlaylists([]);
    final uploader = FakeUploader();
    final repo = UploadQueueRepositoryImpl(db);
    final manager = UploadManager(
      queue: repo,
      settings: settings,
      uploader: uploader,
      ensurePlaylist:
          PlaylistProvisioner(playlists: api, settings: settings).ensureDefaultPlaylist,
    );
    final tmp = Directory.systemTemp.createTempSync('tf_prov');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final f = File('${tmp.path}/a.mp4')..writeAsBytesSync([1, 2, 3]);
    final item = (await manager.enqueue(NewVideo(
      contentUri: f.uri.toString(), localPath: f.path, fileName: 'a.mp4', fileSize: 3)))!;

    await manager.start();
    final row = (await repo.get(item.id))!;
    expect(row.status, UploadStatus.completed);
    expect(row.playlistId, 'NEW1');
    expect(api.created, hasLength(1));
  });
}
