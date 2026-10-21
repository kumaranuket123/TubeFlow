# TubeFlow

Personal video automation for Android (Flutter). Record with your normal Camera
app; TubeFlow detects the new video and uploads it **directly to your YouTube
channel as a private (or unlisted) video**, then adds it to a playlist you choose. There is no
backend: videos go phone → YouTube only.

```
Camera app → MediaStore → TubeFlow → YouTube Data API (resumable upload)
          → private video → selected playlist
```

## Features
- Google OAuth 2.0 (PKCE, no client secret), tokens in Keystore-backed storage
- Playlist picker; uploads are **private** by default (unlisted optional, never public); multi-select videos in a playlist to switch them between private and unlisted
- MediaStore detection (no hard-coded paths), completed-recording checks, manual scan
- Manual multi-select upload through the same `UploadManager`
- Persistent queue (Drift/SQLite): survives restarts; duplicate protection
- Chunked **resumable** uploads with backoff, session persisted across restarts
- Foreground service + progress notification; WorkManager periodic scan/resume
- Wi-Fi-only and charging-only rules; resumes when conditions return
- Optional deletion of originals (Keep original OFF), always user-confirmed

## Setup
1. Follow [`docs/SETUP_GOOGLE_CLOUD.md`](docs/SETUP_GOOGLE_CLOUD.md) and put your
   OAuth client ID / redirect scheme in `lib/core/config/env.dart` and
   `android/app/build.gradle.kts`.
2. `fvm flutter pub get`
3. `fvm dart run build_runner build --delete-conflicting-outputs`
4. `fvm flutter run`

## Docs
- [`CLAUDE.md`](CLAUDE.md) – architecture notes
- [`docs/PLAN.md`](docs/PLAN.md) – phased plan
- [`docs/INTEGRATION_TESTING.md`](docs/INTEGRATION_TESTING.md) – test strategy + device checklist
- [`docs/RELEASE.md`](docs/RELEASE.md) – signing and production builds

## Tests
`fvm flutter analyze && fvm flutter test`
