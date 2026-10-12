# TubeFlow: architecture + plan for Phases 2-10

## Context
TubeFlow auto-uploads videos recorded in the normal Camera app to the user's YouTube channel (private, then added to a playlist). Video goes phone → YouTube only, with no backend. **Phase 1 (OAuth) is done** (confirmed by the user). This plan covers the rest. The first implementation step is to save this plan into the repo as `docs/PLAN.md`.

Existing foundation: Riverpod plain providers, Drift `AppDatabase` (`shareAcrossIsolates`, one `YoutubeAccounts` table), Dio, `SecureTokenStorage`, `getValidAccessTokenProvider` (the only way to get a token), `YoutubeApiConstants` (including `uploadBaseUrl`), and `minSdk 29`. Dependencies are already declared: workmanager, flutter_foreground_task, connectivity_plus, battery_plus, permission_handler, device_info_plus, uuid, path_provider, go_router.

## Architecture
```
Camera app → MediaStore → VideoScannerService (MediaStoreService, Kotlin channel)
  → UploadQueueRepository (Drift) → UploadManager (one active upload)
  → gates: NetworkService, BatteryService, SettingsRepository, auth token
  → YouTubeApiService: resumable videos.insert → playlistItems.insert → COMPLETED
```
- Layout: `lib/core/{network,storage,permissions,utils}` plus `lib/features/{youtube,media,upload,settings}/{domain,data,presentation}`.
- DB: Drift/SQLite. Migrations are bumped via `schemaVersion`. Run build_runner after table changes.
- Resumable upload: custom Dio implementation. Start a session with `POST {uploadBaseUrl}/videos?uploadType=resumable&part=snippet,status` (privacyStatus=private) and persist the session URI on the queue row. Send 8 MiB chunks (a multiple of 256 KiB) read from the content URI via a native stream. Resume with `Content-Range: bytes */total` → 308 + Range header. A 404/410 means a fresh session; a 5xx or network error means backoff and retry.
- Idempotency: the queue row stores `youtubeVideoId`. A playlist failure retries only `playlistItems.insert`. A unique index on `mediaStoreId` plus a (size, dateTaken) check gives duplicate protection.
- Background: WorkManager (constraint-based and periodic scan/resume, survives reboot) starts a foreground service (`dataSync` type) with a progress notification. The background isolate builds its own ProviderContainer and shares the Drift DB.
- Native Kotlin (`android/app/src/main/kotlin/...`): MediaStore query (video, `IS_PENDING=0`, `DATE_ADDED`, size), a ContentObserver, and a chunk reader over `ContentResolver.openInputStream`. Only `READ_MEDIA_VIDEO` is requested on API 33+, and `READ_EXTERNAL_STORAGE` is declared with `maxSdkVersion=32` (the app does not use `READ_MEDIA_IMAGES`). The manual picker uses the system picker and needs no permission.
- Scope: keep `https://www.googleapis.com/auth/youtube`, because `youtube.upload` alone cannot list playlists or call `playlistItems.insert`.

## Phases (each must pass `flutter analyze` and `flutter test`, and earlier features must keep working)
2. **Playlists:** `YouTubePlaylistService` (`playlists.list`, paginated), the `Playlist` entity, `SettingsRepository` (Drift `app_settings` single-row table: selectedPlaylistId, autoUpload, wifiOnly, chargingOnly, keepOriginal, visibility=private), playlist picker screen, and a home screen shell (go_router).
3. **Manual upload:** `file_picker` (multi-select) or `image_picker`, `YouTubeApiService.insertVideo` and a basic single-shot path, with a simple progress UI. The code is structured so Phase 8 swaps in resumable upload.
4. **Private + playlist insertion:** `playlistItems.insert` after `videos.insert`, with verification of `status.privacyStatus`. COMPLETED only after the insert succeeds.
5. **Persistent queue:** `upload_queue` table (fields per the spec, status enum with the 8 states), `UploadQueueRepository` and `UploadManager` (enqueue/start/pause/resume/cancel/retry), a queue UI, and unit tests (queue transitions, duplicate rejection, restart recovery of in-flight items → WAITING).
6. **MediaStore detection:** `MediaStoreService` method channel, `VideoScannerService`, the "Scan Camera Videos" button, the permission flow (`core/permissions`), and a stability check (`IS_PENDING=0` plus an unchanged size across 2 reads).
7. **Background:** WorkManager + foreground service + notification, with ContentObserver-triggered scan, and the manifest entries (`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_DATA_SYNC`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, service declaration).
8. **Resumable + retry:** replace the Phase 3 path with the chunked resumable uploader, persisted session URI, exponential backoff, and `retryCount`.
9. **Rules:** `NetworkService` (connectivity_plus, Wi-Fi vs mobile), `BatteryService` (battery_plus charging state), and `UploadManager` gating. Items stay WAITING, and the queue resumes on a network/charging change. Behavior for an in-progress upload when charging stops: finish by default.
10. **Polish:** error mapping to the spec messages (quota, auth expired, playlist missing, file deleted, interrupted), auto-upload settings screen, a full home screen, integration-test strategy doc, `docs/SETUP_GOOGLE_CLOUD.md` (consent screen "In production", Android client with SHA-1, `applicationId` change before release, quota note: 1600 units per insert against the default 10,000 per day), and production build instructions (signing config, `flutter build appbundle`).

## Verification
- After each phase: `fvm flutter analyze`, `fvm flutter test`, and `dart run build_runner build --delete-conflicting-outputs` when Drift tables change.
- Unit tests: queue repository, UploadManager gating, resumable-uploader chunk/resume logic (mock Dio adapter at the HTTP boundary only).
- Manual on a real Android device (the YouTube calls are real and need the user's Google Cloud config): connect, pick a playlist, upload a short video manually, record with the Camera app and scan, lock the phone mid-upload, toggle Wi-Fi/charging rules, and kill and relaunch the app.
