# Play Console copy (paste/adapt)

**App name:** TubeFlow
**Short description (80 max):** Auto-upload your camera videos to YouTube as private videos.

**Full description:**
TubeFlow turns your phone's camera into a private YouTube backup.

Record videos with your normal Camera app. TubeFlow detects them and uploads them to your own YouTube channel as private (or unlisted) videos, then adds them to the playlist you choose. Nothing is ever made public.

- Automatic detection of new camera videos
- Resumable uploads that continue in the background
- Upload rules: Wi-Fi only, Wi-Fi or 5G, charging only
- Choose or create playlists, and switch videos between private and unlisted
- Upload queue with retry, pause and bulk actions
- Share videos to TubeFlow from any app
- No ads, no analytics, no server: your videos go only to your YouTube channel

TubeFlow is not affiliated with YouTube or Google. YouTube is a trademark of Google LLC.

**Category:** Video Players & Editors (or Tools) · **Ads:** No · **Audience:** 13+

## Data safety
- Data collected/shared with developer: none. No data leaves the device except uploads to YouTube, initiated by the user.
- Sign-in tokens stored on-device (Android Keystore-backed). Data encrypted in transit. Users can disconnect in-app, which deletes the tokens.

## Permission declarations
- Foreground service `dataSync`: user-initiated upload of recorded videos to the user's YouTube account.
- `READ_MEDIA_VIDEO`: core functionality, detecting new camera videos for upload. No image/audio/all-files access.
- `READ_PHONE_STATE`: optional, requested only when the user enables "Also allow 5G"; used solely to read the cellular generation. Not collected or shared.
