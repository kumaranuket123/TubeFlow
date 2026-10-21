# Google Cloud / YouTube API setup

TubeFlow talks to YouTube directly from the phone using OAuth 2.0 with an
**Android-type OAuth client**: no client secret exists anywhere in the app
(PKCE protects the flow). You only have to supply three values.

## 1. Create the project and enable the API
1. https://console.cloud.google.com → create (or pick) a project.
2. **APIs & Services → Library → "YouTube Data API v3" → Enable.**

## 2. OAuth consent screen
1. **APIs & Services → OAuth consent screen** (Google Auth platform → Branding/Audience).
2. User type **External**. Fill in app name, support email.
3. **Data access / Scopes**: add `https://www.googleapis.com/auth/youtube`.
   - Why this scope: `youtube.upload` alone cannot list playlists or call
     `playlistItems.insert`; `youtube` is the narrowest single scope covering
     upload + playlist read/write. (Constant: `YoutubeApiConstants.scopes`.)
4. **Publishing status → "In production".** While it is "Testing", refresh
   tokens for this scope expire after **7 days** and TubeFlow would keep asking
   you to reconnect.
   - For personal use you can stay unverified: Google shows an "unverified app"
     warning at sign-in (Advanced → Continue) and caps unverified apps at 100
     users. Public distribution requires Google's OAuth verification.
5. If you stay in Testing temporarily, add your account under **Test users**.

## 3. Android OAuth client
**Credentials → Create credentials → OAuth client ID → Application type: Android**
- **Package name**: the app's `applicationId` (`com.crn.tubeflow`).
- **SHA-1**: certificate fingerprint of the key that signs the build.
  - Debug: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
  - Release: the same command against your release keystore (see `docs/RELEASE.md`).
  - Google Play App Signing: use the *app signing key* SHA-1 from Play Console.
  - You need one OAuth client per (package, SHA-1) pair, so create a debug client
    and a release client.

## 4. Where to put your values (the only 3 places)
| What | File | Value |
|---|---|---|
| Client ID | `lib/core/config/env.dart` → `kGoogleOAuthClientId` | `NNN-xxxx.apps.googleusercontent.com` |
| Redirect scheme | `lib/core/config/env.dart` → `kOAuthRedirectScheme` | `com.googleusercontent.apps.NNN-xxxx` (the client ID reversed) |
| Redirect scheme (Android) | `android/app/build.gradle.kts` → `manifestPlaceholders["appAuthRedirectScheme"]` | the same string as above |

If you change `applicationId` (you must before publishing; `com.example.*` is
not allowed on Google Play), create a new Android OAuth client for the new
package name, then update all three values.

## 5. Quota
Default quota is **10,000 units/day** per project:
| Call | Cost |
|---|---|
| `videos.insert` | 1,600 |
| `playlistItems.insert` | 50 |
| `playlists.list` | 1 |
| `videos.list` (privacy check) | 1 |

That is roughly **6 uploads per day** with the default quota. Hitting it shows
"YouTube upload quota reached. Try again later." and resets at midnight Pacific
time. You can request more via the *YouTube API Services – Audit and Quota
Extension* form.

Note: Google restricts uploads from API projects that have not passed a
compliance audit to **private** visibility. TubeFlow uploads as private by
default; if the user chooses **unlisted** (or changes a video to unlisted), YouTube
may force it back to private until the project passes the audit. TubeFlow
never publishes videos as public.

## 6. Verify
Run the app, tap **Connect YouTube Account**, finish sign-in, and confirm your
channel name appears. Then pick a playlist and upload a short test video.
