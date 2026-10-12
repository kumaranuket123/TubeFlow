# Test strategy

## Layers
| Layer | What | Where | Runs |
|---|---|---|---|
| Unit | Queue repository, `UploadManager` (single runner, retries, rules, lease), resumable uploader protocol, scanner stability, error mapping, original cleanup | `test/**` | `fvm flutter test` (CI) |
| Boundary fakes | `YoutubeUploader`, `MediaStoreService`, `NetworkService`, `BatteryService`; the resumable uploader is tested against a fake **HTTP adapter** that asserts exact `Content-Range` headers | `test/features/**` | CI |
| Database | Real Drift schema on in-memory SQLite (migrations' target schema, unique/dupe rules, lease SQL) | `test/features/upload` | CI |
| Widget | Home/connect screens with a fake auth repository | `test/widget_test.dart` | CI |
| On-device smoke | App boots, connect screen renders, DB opens | `integration_test/app_test.dart` | `fvm flutter test integration_test -d <device>` |
| Real-YouTube e2e | Real OAuth, real upload, real playlist | manual checklist below | before each release |

The core YouTube flow is intentionally **not mocked in e2e**: the manual run
below hits the real API with a throwaway channel.

## Manual release checklist (real device, real account)
Use a test Google account/channel with a test playlist; set the OAuth consent
screen to production first.

**Auth**
- [#] Connect → channel name shows. Kill app, relaunch → still connected.
- [ ] Disconnect → UI resets; token revoked (Google Account → Security → Third-party access).
- [ ] Revoke access from the Google account, then upload → "Please reconnect your YouTube account".

**Upload**
- [ ] Pick a ~30 s video → appears in queue → completes → video exists on YouTube as **Private** and inside the chosen playlist.
- [ ] No playlist selected → fails immediately with "Choose an upload playlist first." (nothing uploaded).
- [ ] Pick the same video again → "already in the queue" (no second upload).
- [ ] Large file (>1 GB): lock the phone mid-upload → notification keeps updating, upload finishes.
- [ ] Airplane mode mid-upload → "Upload interrupted. Retrying…"; turn it off → resumes from the saved position (watch progress not restarting at 0%).
- [ ] Force-stop the app mid-upload, reopen → upload resumes, no duplicate video on YouTube.
- [ ] Delete the playlist on YouTube after upload but before insert → "Selected playlist is no longer available."; video id kept.
- [ ] Delete the local file while queued → "Original video is no longer available."

**Camera detection**
- [ ] Record with the stock Camera app; **Scan Camera Videos** queues it once.
- [ ] Auto Upload ON, app open: new recording queued ~20 s after recording stops. Never queued while still recording.
- [ ] Auto Upload ON, app closed: queued within ~15–30 min (WorkManager).
- [ ] First scan does not queue the old gallery (only the last 24 h).

**Rules**
- [ ] Wi-Fi only + mobile data → banner "Waiting for Wi-Fi", nothing uploads; join Wi-Fi → starts by itself.
- [ ] Leave Wi-Fi mid-upload (Wi-Fi only on) → pauses; resumes later.
- [ ] Charging only on battery → waits; plug in → starts. Unplug mid-upload → current video finishes, next waits.

**Keep original**
- [ ] OFF + completed upload → "Delete N original video(s)?" → Android confirmation → file gone, queue row stays (re-selecting it is still rejected).
- [ ] ON (default) → nothing is ever offered for deletion.

**Android versions**: run the checklist on Android 10 (no original deletion), 13 (READ_MEDIA_VIDEO, notification permission) and 14/15 (foreground-service type enforcement).

## Automating more later
- Drive the real flow in CI with a dedicated test channel and a refresh token in
  secure CI secrets (Firebase Test Lab / `integration_test`), uploading a 2 s clip.
- Add an HTTP-level fake of the YouTube endpoints (local `shelf` server via
  `Dio` `baseUrl` override) to run full queue→playlist flows on-device without quota.
