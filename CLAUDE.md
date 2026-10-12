# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

TubeFlow (`tube_flow`) is an Android-focused Flutter app that detects videos recorded with the normal Camera app (MediaStore) and uploads them directly to the user's YouTube channel as **private** videos, then adds them to a chosen playlist. No backend. All 10 phases of `docs/PLAN.md` are implemented (auth, playlists, upload, queue, MediaStore scan, background, resumable, rules, polish). Flutter is pinned via FVM (`.fvmrc`), so use `fvm flutter ...` / `fvm dart ...`.

## Commands

- `flutter pub get`
- `flutter run`
- `flutter analyze` (lints: `flutter_lints`; platform folders excluded)
- `flutter test` / single test: `flutter test test/widget_test.dart --plain-name "<name>"`
- Code generation (Drift `*.g.dart`, Riverpod generators): `dart run build_runner build --delete-conflicting-outputs`. Re-run after changing any Drift table or `@DriftDatabase` annotation; `app_database.g.dart` is checked in.

## Architecture

Feature-first clean architecture with Riverpod (plain `Provider`/`NotifierProvider`, no codegen providers yet):

- `lib/core/` — cross-cutting: `di/core_providers.dart` (Dio, FlutterAppAuth, secure storage, `AppDatabase` singletons), `database/` (Drift `AppDatabase`, opened with `shareAcrossIsolates: true` so a future background isolate can use it), `security/secure_token_storage.dart`, `error/exceptions.dart`, `config/env.dart`, `constants/`.
- `lib/features/<feature>/{domain,data,presentation}` — `domain` holds entities, abstract repositories, and single-purpose use-case classes; `data` holds datasources, repository impls, and Drift tables (`data/local/`); `presentation` holds screens and the Riverpod providers that wire everything together.

### YouTube auth flow (`features/youtube`)

- `YoutubeAuthRepositoryImpl` owns auth state and exposes it as a broadcast stream; `YoutubeAuthController` (Notifier) mirrors it so widgets depend only on Riverpod. On startup the repository optimistically restores "connected" from the Drift `youtube_accounts` row, then the controller silently calls `getValidAccessToken` to verify.
- Tokens live in `flutter_secure_storage` (via `SecureTokenStorage`); only channel metadata is in Drift (single-row table, replaced on connect).
- `getValidAccessTokenProvider` is the only way other features should obtain an access token. It refreshes ~60s before expiry; if refresh fails or no refresh token exists it clears all state, emits `AuthDisconnected`, and throws `ReauthRequiredException`. Network errors on startup deliberately do not disconnect.
- OAuth uses `flutter_appauth` with an Android-type Google client (no secret, PKCE). Client ID and redirect scheme are in `lib/core/config/env.dart`; the redirect scheme must match `appAuthRedirectScheme` in `android/app/build.gradle.kts` and the applicationId. The Google consent screen must be "In production" or restricted-scope refresh tokens expire after 7 days.

### Upload pipeline (`features/upload`, `features/media`, `core/background`)

- `UploadManager` (domain) is the single coordinator for manual, scanned and background uploads: one item at a time, pipeline PREPARING → UPLOADING → PROCESSING (verify private) → ADDING_TO_PLAYLIST → COMPLETED. The YouTube id is persisted right after upload so a playlist failure never re-uploads. Transient failures defer the item (WAITING, retried next run, max 5); rule interruptions (Wi-Fi lost) don't count as retries.
- `YoutubeUploadRemoteDataSource` is the resumable uploader (8 MiB chunks, session URI persisted in the queue row, status query `bytes */total` after errors). `core/error/youtube_error_mapper.dart` maps API/HTTP errors to user-facing messages.
- **Multiple Flutter engines** (UI, foreground service `core/background/foreground_upload_service.dart`, WorkManager `background_scheduler.dart`) each open their OWN Drift connection (WAL + busy_timeout). Do **not** reintroduce `shareAcrossIsolates`: it dies with the engine that hosts it ("Channel was closed before receiving a response"). A DB lease (`RunnerLease`, columns on the settings row) ensures only one engine runs the queue; the UI refreshes `uploadQueueProvider` on a 2 s timer because cross-engine writes aren't announced.
- Start uploads via `uploadTriggerProvider` (foreground service, falls back to in-process). The service may only be started while the app is visible (Android 12+).
- Rules: `evaluateConditions` in `upload_conditions.dart`. Wi-Fi lost mid-upload interrupts; unplugging lets the current video finish. WorkManager constraints mirror the rules.
- MediaStore access is a Kotlin method channel in `MainActivity.kt` (`tubeflow/mediastore`): query (IS_PENDING=0), ContentObserver, delete request (Android 11+, always user-confirmed). First scan only looks back 24 h.
- Docs: `docs/SETUP_GOOGLE_CLOUD.md`, `docs/RELEASE.md`, `docs/INTEGRATION_TESTING.md`.
