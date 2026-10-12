/// Ensures only one isolate (UI, foreground service, WorkManager worker)
/// processes the upload queue at a time. A lease expires on its own if the
/// owner dies without releasing it.
abstract class RunnerLease {
  Future<bool> acquire(String owner, Duration ttl);

  /// False if the lease was lost (expired and taken by someone else).
  Future<bool> renew(String owner, Duration ttl);

  Future<void> release(String owner);
}
