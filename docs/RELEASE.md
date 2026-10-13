# Production build

## Before the first release
1. **Application ID.** Replace `com.example.tube_flow` in
   `android/app/build.gradle.kts` (`applicationId` and `namespace`), and move
   `MainActivity.kt` to the matching package directory
   (`android/app/src/main/kotlin/<your/package>/`, update its `package` line).
2. Create a new Android OAuth client for the new package + release SHA-1 and
   update the three values listed in `docs/SETUP_GOOGLE_CLOUD.md` §4.
3. Set the consent screen to **In production**.
4. Bump `version:` in `pubspec.yaml` (`1.0.0+1` → name+build number).

## Signing
```bash
keytool -genkeypair -v -keystore ~/tubeflow-release.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias tubeflow
```
Create `android/key.properties` (git-ignored; never commit it or the keystore):
```
storeFile=/home/you/tubeflow-release.jks
storePassword=...
keyAlias=tubeflow
keyPassword=...
```
`build.gradle.kts` uses it automatically. Without the file it falls back to the
debug key, which is fine for local testing but must never be published.
Back up the keystore: losing it means you cannot update the app.

## Build
```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter analyze && fvm flutter test
fvm flutter build appbundle --release     # Play Store  → build/app/outputs/bundle/release/app-release.aab
fvm flutter build apk --release           # sideload    → build/app/outputs/flutter-apk/app-release.apk
```
Verify the signature: `apksigner verify --print-certs app-release.apk` and
check the SHA-1 matches the OAuth client.

## Play Store notes
- **Foreground service (dataSync)**: Play Console asks you to declare the use
  case: "user-initiated upload of recorded videos to the user's YouTube account".
- **READ_MEDIA_VIDEO**: declare it as core functionality (detecting new camera
  videos for upload); TubeFlow requests no image/audio/all-files access.
- **Data safety**: no data is sent to any server owned by the developer. OAuth
  tokens are stored on-device (Android Keystore-backed); videos go only to
  YouTube.
- Sensitive-scope OAuth verification is required for public distribution.

## Release checklist (device)
See `docs/INTEGRATION_TESTING.md` → *Manual release checklist*.

## Signing guard

`assembleRelease` / `bundleRelease` fail when `android/key.properties` is missing, so a debug-signed build can't be shipped by accident. For a local test build only: `flutter build apk --release --android-project-arg=allowDebugSigning=true`.
