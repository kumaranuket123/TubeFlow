import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/database/app_database.dart';
import 'package:tube_flow/core/quota/quota_tracker.dart';

void main() {
  Uri u(String s) => Uri.parse(s);

  test('costs follow the YouTube quota table', () {
    const api = 'https://www.googleapis.com/youtube/v3';
    const up = 'https://www.googleapis.com/upload/youtube/v3/videos';
    expect(QuotaTracker.costOf('GET', u('$api/playlists?mine=true')), 1);
    expect(QuotaTracker.costOf('POST', u('$api/playlistItems')), 50);
    expect(QuotaTracker.costOf('PUT', u('$api/videos?part=status')), 50);
    expect(QuotaTracker.costOf('DELETE', u('$api/videos?id=x')), 50);
    expect(QuotaTracker.costOf('POST', u('$up?uploadType=resumable')), 1600);
    // chunk / status calls on an existing session are free
    expect(
        QuotaTracker.costOf('PUT', u('$up?uploadType=resumable&upload_id=abc')),
        0);
    expect(
        QuotaTracker.costOf('POST', u('$up?uploadType=resumable&upload_id=abc')),
        0);
    expect(
        QuotaTracker.costOf('POST', u('https://oauth2.googleapis.com/token')),
        0);
  });

  test('day key follows Pacific time incl. DST', () {
    // 06:30 UTC in July = 23:30 PDT the previous day
    expect(QuotaTracker.dayKey(DateTime.utc(2026, 7, 10, 6, 30)), '2026-07-09');
    expect(QuotaTracker.dayKey(DateTime.utc(2026, 7, 10, 7, 30)), '2026-07-10');
    // January is PST: 07:30 UTC = 23:30 previous day
    expect(QuotaTracker.dayKey(DateTime.utc(2026, 1, 10, 7, 30)), '2026-01-09');
    expect(QuotaTracker.dayKey(DateTime.utc(2026, 1, 10, 8, 30)), '2026-01-10');
  });

  test('records accumulate per day and reset on a new day', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    var now = DateTime.utc(2026, 7, 10, 12);
    final t = QuotaTracker(db, clock: () => now);
    await t.record(1600);
    await t.record(50);
    expect(await t.usedToday(), 1650);
    now = DateTime.utc(2026, 7, 11, 12);
    expect(await t.usedToday(), 0);
  });
}
