import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../constants/youtube_api_constants.dart';
import '../database/app_database.dart';

/// YouTube gives no API to read the remaining quota, so units are counted
/// locally from the requests the app makes. It is an estimate: it only sees
/// this device, while the real quota belongs to the whole Google Cloud
/// project.
class QuotaTracker {
  QuotaTracker(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Documented cost of the calls the app makes. `videos.insert` is charged
  /// when the resumable session is created; chunk uploads and status queries
  /// on the session URL are free.
  static int costOf(String method, Uri uri) {
    final path = uri.path;
    final m = method.toUpperCase();
    if (!uri.host.endsWith('googleapis.com') || !path.contains('/youtube/v3/')) {
      return 0;
    }
    if (path.contains('/upload/')) {
      return m == 'POST' && !uri.queryParameters.containsKey('upload_id')
          ? YoutubeApiConstants.insertVideoCost
          : 0;
    }
    return m == 'GET' ? 1 : YoutubeApiConstants.writeCost;
  }

  Future<void> record(int units) async {
    if (units <= 0) return;
    await _db.into(_db.quotaUsage).insert(
          QuotaUsageCompanion.insert(dayKey: dayKey(_clock()), units: Value(units)),
          onConflict: DoUpdate(
            (old) => QuotaUsageCompanion.custom(units: old.units + Constant(units)),
          ),
        );
  }

  Future<int> usedToday() async {
    final row = await (_db.select(_db.quotaUsage)
          ..where((t) => t.dayKey.equals(dayKey(_clock()))))
        .getSingleOrNull();
    return row?.units ?? 0;
  }

  /// Pacific-time day the quota window belongs to.
  static String dayKey(DateTime now) {
    final pt = now.toUtc().add(pacificOffset(now));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${pt.year}-${two(pt.month)}-${two(pt.day)}';
  }

  /// When the quota next resets (midnight Pacific), in local time.
  static DateTime nextReset(DateTime now) {
    final off = pacificOffset(now);
    final pt = now.toUtc().add(off);
    final midnightPt = DateTime.utc(pt.year, pt.month, pt.day + 1);
    return midnightPt.subtract(off).toLocal();
  }

  /// US Pacific offset: PDT (-7) from the second Sunday of March 02:00 to the
  /// first Sunday of November 02:00, otherwise PST (-8).
  static Duration pacificOffset(DateTime now) {
    final utc = now.toUtc();
    DateTime nthSunday(int month, int n) {
      final first = DateTime.utc(utc.year, month);
      final shift = (DateTime.sunday - first.weekday) % 7;
      return DateTime.utc(utc.year, month, 1 + shift + 7 * (n - 1));
    }

    final start = nthSunday(3, 2).add(const Duration(hours: 10)); // 02:00 PST
    final end = nthSunday(11, 1).add(const Duration(hours: 9)); // 02:00 PDT
    final dst = !utc.isBefore(start) && utc.isBefore(end);
    return Duration(hours: dst ? -7 : -8);
  }
}

/// Counts quota units for every successful YouTube API response.
class QuotaInterceptor extends Interceptor {
  QuotaInterceptor(this._tracker);

  final QuotaTracker _tracker;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 400) {
      // Never let bookkeeping break a request.
      _tracker.record(QuotaTracker.costOf(req.method, req.uri)).catchError((_) {});
    }
    handler.next(response);
  }
}
