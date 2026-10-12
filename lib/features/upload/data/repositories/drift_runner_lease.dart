import 'package:drift/drift.dart' show Variable;

import '../../../../core/database/app_database.dart';
import '../../domain/runner_lease.dart';

/// Lease stored on the settings row; each operation is one atomic UPDATE.
class DriftRunnerLease implements RunnerLease {
  DriftRunnerLease(this._db, {int Function()? nowMs})
      : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final int Function() _nowMs;

  Future<void> _ensureRow() => _db.customStatement(
      'INSERT OR IGNORE INTO app_settings_rows (id) VALUES (1)');

  Future<bool> _claim(String owner, Duration ttl) async {
    await _ensureRow();
    final now = _nowMs();
    final changed = await _db.customUpdate(
      'UPDATE app_settings_rows SET runner_id = ?, runner_lease_until_ms = ? '
      'WHERE id = 1 AND (runner_id IS NULL OR runner_id = ? '
      'OR runner_lease_until_ms IS NULL OR runner_lease_until_ms < ?)',
      variables: [
        Variable.withString(owner),
        Variable.withInt(now + ttl.inMilliseconds),
        Variable.withString(owner),
        Variable.withInt(now),
      ],
    );
    return changed > 0;
  }

  @override
  Future<bool> acquire(String owner, Duration ttl) => _claim(owner, ttl);

  @override
  Future<bool> renew(String owner, Duration ttl) => _claim(owner, ttl);

  @override
  Future<void> release(String owner) => _db.customUpdate(
        'UPDATE app_settings_rows SET runner_id = NULL, '
        'runner_lease_until_ms = NULL WHERE id = 1 AND runner_id = ?',
        variables: [Variable.withString(owner)],
      );
}
