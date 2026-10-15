# Public launch checklist (Play Store + Google OAuth verification)

Application ID: `com.crn.tubeflow` (already applied in `build.gradle.kts`,
`MainActivity.kt`, manifest label).

## 1. Privacy policy (free hosting)
1. Fill in `[DATE]` and `[CONTACT EMAIL]` in `docs/privacy.html`.
2. Push the repo to GitHub → Settings → Pages → Source: `main` / `/docs`.
3. URL becomes `https://<user>.github.io/<repo>/privacy.html`. Use it in the OAuth
   consent screen AND the Play Console.
   (Google verification also wants a homepage on the same domain: add a short
   `docs/index.html` describing the app.)

## 2. Release signing
Create the keystore and `android/key.properties` (see `docs/RELEASE.md`). Back up
the keystore. Builds fail without it.

## 3. Google Cloud (OAuth)
1. Consent screen: app name TubeFlow, support email, logo, homepage and privacy
   policy URLs, authorized domain (`github.io` is not accepted as an authorized
   domain; use your own domain if verification asks for one).
2. Scope: `https://www.googleapis.com/auth/youtube` (sensitive).
3. **Publishing status → In production**, then **Submit for verification**.
4. New Android OAuth client: package `com.crn.tubeflow` + SHA-1.
   - Before Play: SHA-1 of your release keystore.
   - After Play App Signing is on: ALSO create a client with the **app signing
     key** SHA-1 from Play Console → App integrity.
5. Put the new client ID into `lib/core/config/env.dart` (`kGoogleOAuthClientId`,
   `kOAuthRedirectScheme`) and the same scheme into
   `android/app/build.gradle.kts` (`appAuthRedirectScheme`). Without this, sign-in
   will fail: the old client belonged to the old package name.

### Verification form: scope justification (paste/adapt)
> TubeFlow uploads videos recorded on the user's phone to the user's own YouTube
> channel as private videos and adds them to a playlist the user selects. The
> `youtube` scope is required because `videos.insert`, `playlists.insert`,
> `playlists.list` and `playlistItems.insert` all need it; no narrower scope
> covers uploading together with playlist management. Data is used only for
> these features, stays on the user's device, and is never sent to any server
> of ours.

### Demo video (required): show, in one unlisted YouTube video
1. The consent screen, with the client ID visible in the URL.
2. Sign in and grant access.
3. Pick a playlist / create a new one.
4. Upload a video, then show it private on YouTube Studio and in the playlist.
5. Disconnect in the app.

## 4. YouTube API quota
10,000 units/day per project ≈ 6 uploads/day (about 1,600 units each) across
ALL users. Submit the **YouTube API Services audit / quota extension** form
before inviting many users.

## 5. Play Console
- Store listing: name, short + full description, 512px icon, 1024×500 feature
  graphic, at least 2 phone screenshots.
- App content: privacy policy URL; Data safety: collects no data to developer
  servers; tokens stored on device; Ads: none; Target audience: 13+.
- Foreground service (`dataSync`): "user-initiated upload of recorded videos to
  the user's YouTube account"; attach a short screen recording.
- `READ_MEDIA_VIDEO`: core functionality (detect new camera videos for upload).
- New personal developer accounts must run a closed test with 12+ testers for 14
  days before production access.
- Upload `fvm flutter build appbundle --release` output.

## 6. Pre-submit
```bash
fvm flutter analyze && fvm flutter test
fvm flutter build appbundle --release
```
