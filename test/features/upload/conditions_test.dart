import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:tube_flow/core/battery/battery_service.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/core/network/network_service.dart';
import 'package:tube_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tube_flow/features/upload/data/repositories/upload_queue_repository_impl.dart';
import 'package:tube_flow/features/upload/domain/entities/upload_status.dart';
import 'package:tube_flow/features/upload/domain/entities/video_upload_item.dart';
import 'package:tube_flow/features/upload/domain/upload_conditions.dart';
import 'package:tube_flow/features/upload/domain/upload_manager.dart';

import 'upload_queue_test.dart' show FakeUploader;

class _Net implements NetworkService {
  _Net(this.kind);
  NetworkKind kind;
  @override
  Future<NetworkKind> current() async => kind;
  @override
  Stream<NetworkKind> watch() => const Stream.empty();
}

class _Bat implements BatteryService {
  bool charging = false;
  @override
  Future<bool> isCharging() async => charging;
  @override
  Stream<bool> watch() => const Stream.empty();
}

void main() {
  group('evaluateConditions', () {
    BlockReason? e(NetworkKind? n, {bool wifi = false, bool chg = false, bool? c}) =>
        evaluateConditions(wifiOnly: wifi, chargingOnly: chg, network: n, charging: c);

    test('no network always blocks', () {
      expect(e(NetworkKind.none), BlockReason.noNetwork);
    });
    test('Wi-Fi only blocks mobile data, allows Wi-Fi', () {
      expect(e(NetworkKind.mobile, wifi: true), BlockReason.needsWifi);
      expect(e(NetworkKind.wifi, wifi: true), isNull);
      expect(e(NetworkKind.mobile), isNull);
    });
    test('Wi-Fi or 5G: allows Wi-Fi and 5G, pauses on 4G and below', () {
      BlockReason? r(NetworkKind n) => evaluateConditions(
          wifiOnly: true, allow5g: true, chargingOnly: false, network: n, charging: null);
      expect(r(NetworkKind.wifi), isNull);
      expect(r(NetworkKind.mobile5g), isNull);
      expect(r(NetworkKind.mobile), BlockReason.needsWifiOr5g);
      expect(r(NetworkKind.none), BlockReason.noNetwork);
    });
    test('5G is still blocked when only Wi-Fi is allowed', () {
      expect(e(NetworkKind.mobile5g, wifi: true), BlockReason.needsWifi);
      expect(e(NetworkKind.mobile5g), isNull); // any network
    });
    test('charging only blocks on battery, allows on power', () {
      expect(e(NetworkKind.wifi, chg: true, c: false), BlockReason.needsCharger);
      expect(e(NetworkKind.wifi, chg: true, c: true), isNull);
    });
    test('unknown state does not block', () {
      expect(e(null, wifi: true), isNull);
    });
  });

  test('connectivity results are classified, VPN-only counts as metered', () {
    final c = ConnectivityNetworkService.classify;
    expect(c([ConnectivityResult.none]), NetworkKind.none);
    expect(c([ConnectivityResult.wifi, ConnectivityResult.vpn]), NetworkKind.wifi);
    expect(c([ConnectivityResult.ethernet]), NetworkKind.wifi);
    expect(c([ConnectivityResult.mobile]), NetworkKind.mobile);
    expect(c([ConnectivityResult.vpn]), NetworkKind.mobile);
  });

  test('battery states count as on power except discharging/unknown', () {
    expect(BatteryPlusService.onPower(BatteryState.charging), isTrue);
    expect(BatteryPlusService.onPower(BatteryState.full), isTrue);
    expect(BatteryPlusService.onPower(BatteryState.connectedNotCharging), isTrue);
    expect(BatteryPlusService.onPower(BatteryState.discharging), isFalse);
    expect(BatteryPlusService.onPower(BatteryState.unknown), isFalse);
  });

  group('UploadManager rules', () {
    late AppDatabase db;
    late UploadQueueRepositoryImpl repo;
    late SettingsRepositoryImpl settings;
    late FakeUploader uploader;
    late _Net net;
    late _Bat bat;
    late UploadManager manager;
    late Directory tmp;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = UploadQueueRepositoryImpl(db);
      settings = SettingsRepositoryImpl(db);
      await settings.setPlaylist('PL', 'T');
      uploader = FakeUploader();
      net = _Net(NetworkKind.wifi);
      bat = _Bat();
      manager = UploadManager(
        queue: repo,
        settings: settings,
        uploader: uploader,
        conditions: UploadConditionChecker(
            settings: settings, network: net, battery: bat),
        conditionPollInterval: const Duration(milliseconds: 10),
      );
      tmp = Directory.systemTemp.createTempSync('tf_rules');
    });
    tearDown(() async {
      await db.close();
      tmp.deleteSync(recursive: true);
    });

    Future<VideoUploadItem> add(String name) async {
      final f = File('${tmp.path}/$name')..writeAsBytesSync([1, 2, 3]);
      return (await manager.enqueue(NewVideo(
        contentUri: f.uri.toString(),
        localPath: f.path,
        fileName: name,
        fileSize: 3,
      )))!;
    }

    test('Wi-Fi only on mobile data: stays WAITING, then uploads on Wi-Fi',
        () async {
      await settings.setWifiOnly(true);
      net.kind = NetworkKind.mobile;
      final item = await add('a.mp4');
      await manager.start();
      expect(uploader.uploadAttempts, 0);
      expect((await repo.get(item.id))!.status, UploadStatus.waiting);

      net.kind = NetworkKind.wifi;
      await manager.start();
      expect((await repo.get(item.id))!.status, UploadStatus.completed);
    });

    test('mobile data is fine when Wi-Fi only is off', () async {
      await settings.setWifiOnly(false);
      net.kind = NetworkKind.mobile;
      final item = await add('a.mp4');
      await manager.start();
      expect((await repo.get(item.id))!.status, UploadStatus.completed);
    });

    test('no network: nothing starts', () async {
      net.kind = NetworkKind.none;
      final item = await add('a.mp4');
      await manager.start();
      expect(uploader.uploadAttempts, 0);
      expect((await repo.get(item.id))!.status, UploadStatus.waiting);
    });

    test('charging only: waits on battery, uploads once plugged in', () async {
      await settings.setChargingOnly(true);
      final item = await add('a.mp4');
      await manager.start();
      expect(uploader.uploadAttempts, 0);

      bat.charging = true;
      await manager.start();
      expect((await repo.get(item.id))!.status, UploadStatus.completed);
    });

    test('unplugging mid-upload does not interrupt it, but blocks the next',
        () async {
      await settings.setChargingOnly(true);
      bat.charging = true;
      final a = await add('a.mp4');
      final b = await add('b.mp4');
      // Unplug as soon as the first upload begins.
      uploader.onUpload = () => bat.charging = false;
      await manager.start();
      expect((await repo.get(a.id))!.status, UploadStatus.completed);
      expect((await repo.get(b.id))!.status, UploadStatus.waiting);
    });

    test('leaving Wi-Fi mid-upload interrupts without counting a retry',
        () async {
      await settings.setWifiOnly(true);
      uploader.holdUntilCancelled = true;
      final item = await add('a.mp4');
      final run = manager.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      net.kind = NetworkKind.mobile; // watchdog notices on its next poll
      await run;

      final row = (await repo.get(item.id))!;
      expect(row.status, UploadStatus.waiting);
      expect(row.errorMessage, 'Waiting for Wi-Fi');
      expect(row.retryCount, 0);

      uploader.holdUntilCancelled = false;
      net.kind = NetworkKind.wifi;
      await manager.start();
      expect((await repo.get(item.id))!.status, UploadStatus.completed);
    });
  });
}
