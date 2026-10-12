import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../settings/domain/settings_repository.dart';
import 'entities/upload_status.dart';
import 'entities/video_upload_item.dart';
import 'runner_lease.dart';
import 'upload_conditions.dart';
import 'upload_queue_repository.dart';
import 'youtube_uploader.dart';

/// Central coordinator for every upload (manual, scanned, background).
///
/// Exactly one item is processed at a time ([_maxConcurrent] = 1); raising
/// that limit and tracking a set of active ids is all concurrency needs.
/// Pipeline per item: PREPARING → UPLOADING → PROCESSING (verify private) →
/// ADDING_TO_PLAYLIST → COMPLETED. If the YouTube id is already stored the
/// upload is skipped, so a playlist failure never re-uploads the video.
class UploadManager {
  UploadManager({
    required UploadQueueRepository queue,
    required SettingsRepository settings,
    required YoutubeUploader uploader,
    RunnerLease? lease,
    String owner = 'main',
    this.leaseTtl = const Duration(seconds: 45),
    this.heartbeat = const Duration(seconds: 15),
    UploadConditionChecker? conditions,
    Future<String?> Function()? ensurePlaylist,
    this.conditionPollInterval = const Duration(seconds: 5),
  })  : _queue = queue,
        _settings = settings,
        _uploader = uploader,
        _lease = lease,
        _conditions = conditions,
        _ensurePlaylist = ensurePlaylist,
        _owner = owner;

  static const _maxConcurrent = 1;

  /// Automatic re-attempts after transient failures before giving up.
  static const maxAutoRetries = 5;

  final UploadQueueRepository _queue;
  final SettingsRepository _settings;
  final YoutubeUploader _uploader;
  final RunnerLease? _lease;
  final String _owner;
  final UploadConditionChecker? _conditions;

  /// Resolves a destination when none is selected (creates a private
  /// playlist if the channel has none). Null result = user must choose.
  final Future<String?> Function()? _ensurePlaylist;
  final Duration conditionPollInterval;
  final Duration leaseTtl;
  final Duration heartbeat;

  final Map<String, CancelToken> _active = {};
  bool _running = false;
  bool _paused = false;

  /// Items that hit a transient failure during this run; retried by the next
  /// run (periodic worker, app open, retry button) rather than in a hot loop.
  final Set<String> _deferred = {};

  bool get isPaused => _paused;

  /// Adds a video to the queue. Returns null when it is a duplicate.
  Future<VideoUploadItem?> enqueue(NewVideo video) async {
    final playlistId = (await _settings.get()).selectedPlaylistId;
    return _queue.enqueue(video, playlistId: playlistId);
  }

  /// Processes waiting items until none are left (or paused). Safe to call
  /// repeatedly and from several isolates: a lease guarantees a single runner;
  /// a caller that doesn't get it returns immediately and the active runner
  /// picks up any newly enqueued items.
  Future<void> start() async {
    if (_running) return;
    _running = true;
    _paused = false;
    _deferred.clear();
    _blocked = false;
    try {
      do {
        await _runLeased();
        // An item enqueued just as the lease was released must not wait for
        // the next periodic run.
      } while (!_paused &&
          !_blocked &&
          await _queue.nextPending(excluding: _deferred) != null &&
          _leaseFree);
    } finally {
      _running = false;
    }
  }

  bool _leaseFree = true;

  /// Set when the rules hold back new uploads; ends the run (items stay
  /// WAITING) instead of re-checking in a loop.
  bool _blocked = false;

  Future<void> _runLeased() async {
    Timer? timer;
    var leased = false;
    try {
      final lease = _lease;
      if (lease != null) {
        leased = await lease.acquire(_owner, leaseTtl);
        _leaseFree = leased;
        if (!leased) return;
        timer = Timer.periodic(heartbeat, (_) => _onHeartbeat(lease));
      }
      // We are the only runner, so any in-flight row is stale (a killed run).
      await _queue.resetInterrupted();
      while (!_paused && _active.length < _maxConcurrent) {
        // Rules (network, Wi-Fi only, charging only) gate every new upload;
        // blocked items simply stay WAITING until conditions change.
        if (await _conditions?.check() != null) {
          _blocked = true;
          break;
        }
        final item = await _queue.nextPending(excluding: _deferred);
        if (item == null) break;
        await _process(item);
      }
    } finally {
      timer?.cancel();
      if (leased) await _lease!.release(_owner);
    }
  }

  Future<void> _onHeartbeat(RunnerLease lease) async {
    if (!await lease.renew(_owner, leaseTtl)) {
      // Lease lost: stop touching the queue.
      _paused = true;
      for (final t in _active.values) {
        t.cancel('lease lost');
      }
      return;
    }
    // Cancellations issued from another isolate only reach us via the DB.
    for (final entry in _active.entries.toList()) {
      final item = await _queue.get(entry.key);
      if (item?.status == UploadStatus.cancelled) entry.value.cancel('cancelled');
    }
  }

  /// Stops after the current item finishes its attempt; no new item starts.
  void pause() => _paused = true;

  Future<void> resume() => start();

  Future<void> cancel(String id) async {
    _active[id]?.cancel('cancelled');
    final item = await _queue.get(id);
    if (item == null || item.status == UploadStatus.completed) return;
    await _queue.update(id,
        status: UploadStatus.cancelled, errorMessage: 'Cancelled');
  }

  Future<void> retry(String id, {bool autoStart = true}) async {
    final item = await _queue.get(id);
    if (item == null || item.status == UploadStatus.completed) return;
    if (item.status != UploadStatus.failed &&
        item.status != UploadStatus.cancelled) {
      return;
    }
    await _queue.update(
      id,
      status: item.youtubeVideoId != null
          ? UploadStatus.addingToPlaylist
          : UploadStatus.waiting,
      retryCount: item.retryCount + 1,
      progress: item.youtubeVideoId != null ? 1 : 0,
      clearError: true,
    );
    if (autoStart) await start();
  }

  Future<void> remove(String id) => _queue.delete(id);

  Future<void> _process(VideoUploadItem item) async {
    final token = CancelToken();
    _active[item.id] = token;
    BlockReason? interruptedBy;
    // Leaving Wi-Fi (or losing the network) mid-upload cancels the request;
    // the saved session lets it resume when conditions return.
    final watchdog = _conditions == null
        ? null
        : Timer.periodic(conditionPollInterval, (_) async {
            final block = await _conditions.checkNetwork();
            if (block != null && !token.isCancelled) {
              interruptedBy = block;
              token.cancel(_conditionsCancel);
            }
          });
    try {
      var videoId = item.youtubeVideoId;

      // Fail fast: never spend a whole upload before discovering there is
      // nowhere to put the video.
      final playlistId = item.playlistId ??
          (await _settings.get()).selectedPlaylistId ??
          await _ensurePlaylist?.call();
      if (playlistId == null) {
        throw const _ItemFailure('Choose an upload playlist first.');
      }

      if (videoId == null) {
        await _queue.update(item.id,
            status: UploadStatus.preparing, clearError: true);
        final path = item.localPath;
        if (path == null || !File(path).existsSync()) {
          throw const _ItemFailure('Original video is no longer available.');
        }

        // A stored session is only valid for the same bytes.
        var sessionUri = item.sessionUri;
        if (sessionUri != null && File(path).lengthSync() != item.fileSize) {
          sessionUri = null;
          await _queue.update(item.id, clearSessionUri: true);
        }

        await _queue.update(item.id, status: UploadStatus.uploading);
        var lastWritten = -1;
        videoId = await _uploader.uploadVideo(
          file: File(path),
          title: item.title,
          description: item.description,
          sessionUri: sessionUri,
          onSessionStarted: (uri) => _queue.update(item.id, sessionUri: uri),
          cancelToken: token,
          onProgress: (p) {
            final pct = (p * 100).floor();
            if (pct != lastWritten) {
              lastWritten = pct;
              unawaited(_queue.update(item.id, progress: p));
            }
          },
        );
        // Persist the id immediately: from here on, retries must not upload.
        await _queue.update(item.id,
            youtubeVideoId: videoId, progress: 1);

        await _queue.update(item.id, status: UploadStatus.processing);
        if (!await _uploader.isPrivate(videoId)) {
          throw const _ItemFailure(
              'Video is not private on YouTube; not adding to playlist.');
        }
      }

      await _queue.update(item.id,
          status: UploadStatus.addingToPlaylist, playlistId: playlistId);
      await _uploader.addToPlaylist(playlistId, videoId);

      await _queue.update(item.id,
          status: UploadStatus.completed, progress: 1, clearError: true);
    } on TransientUploadException catch (e) {
      await _defer(item, e.message);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) && e.error == _conditionsCancel) {
        await _waitForConditions(item, interruptedBy ?? BlockReason.noNetwork);
      } else if (CancelToken.isCancel(e)) {
        // cancel() already wrote CANCELLED.
      } else {
        await _defer(item, 'Upload interrupted. Retrying...');
      }
    } on ReauthRequiredException catch (e) {
      await _fail(item, e.message);
    } on YoutubeApiException catch (e) {
      await _fail(item, e.message);
    } on _ItemFailure catch (e) {
      await _fail(item, e.message);
    } on FileSystemException {
      await _fail(item, 'Original video is no longer available.');
    } catch (e) {
      await _fail(item, 'Upload failed: $e');
    } finally {
      watchdog?.cancel();
      _active.remove(item.id);
    }
  }

  /// Interrupted by the rules, not a failure: no retry is counted.
  Future<void> _waitForConditions(VideoUploadItem item, BlockReason why) async {
    final current = await _queue.get(item.id);
    if (current?.status == UploadStatus.cancelled) return;
    _deferred.add(item.id);
    await _queue.update(item.id,
        status: current?.youtubeVideoId != null
            ? UploadStatus.addingToPlaylist
            : UploadStatus.waiting,
        errorMessage: why.message);
  }

  /// Recoverable failure: back to WAITING (keeping the session and any
  /// YouTube id) so it resumes later, up to [maxAutoRetries] times.
  Future<void> _defer(VideoUploadItem item, String message) async {
    final current = await _queue.get(item.id);
    if (current?.status == UploadStatus.cancelled) return;
    final attempts = (current?.retryCount ?? item.retryCount) + 1;
    if (attempts > maxAutoRetries) {
      await _queue.update(item.id,
          status: UploadStatus.failed,
          errorMessage: 'Upload failed after several retries. Tap retry.',
          retryCount: attempts);
      return;
    }
    _deferred.add(item.id);
    await _queue.update(item.id,
        status: current?.youtubeVideoId != null
            ? UploadStatus.addingToPlaylist
            : UploadStatus.waiting,
        errorMessage: message,
        retryCount: attempts);
  }

  Future<void> _fail(VideoUploadItem item, String message) async {
    final current = await _queue.get(item.id);
    if (current?.status == UploadStatus.cancelled) return;
    await _queue.update(item.id,
        status: UploadStatus.failed,
        errorMessage: message,
        retryCount: (current?.retryCount ?? item.retryCount) + 1);
  }
}

const _conditionsCancel = 'conditions';

class _ItemFailure implements Exception {
  const _ItemFailure(this.message);
  final String message;
}
