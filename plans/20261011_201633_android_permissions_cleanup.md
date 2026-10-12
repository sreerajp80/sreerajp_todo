# Android permissions: document the real list and remove unused storage permissions

**Status:** completed

## Files to be changed

- `android/app/src/main/AndroidManifest.xml` — remove the two storage permissions (Part B),
  and `SCHEDULE_EXACT_ALARM` only if Part C is approved.
- `docs/security.md` — §10 Permissions table and the "does NOT request" list.
- `docs/release_process.md` — §10.4 permission list, and the two manifest check commands
  (§4 checklist and §6 step 7).

No Dart code changes.

## What the issue is

The release manifest check passed for network rules. But the merged release manifest has
permissions that the docs do not list or explain:

| Permission | Comes from | Documented? |
|---|---|---|
| `CAMERA` | App manifest | Yes, but `docs/security.md` gives only AirQR, not OCR |
| `RECORD_AUDIO` | App manifest | Yes |
| `INTERNET` | App manifest | Yes |
| `POST_NOTIFICATIONS` | App manifest | **No.** `docs/security.md` even says the app does NOT request `NOTIFICATIONS` |
| `RECEIVE_BOOT_COMPLETED` | App manifest | **No** |
| `SCHEDULE_EXACT_ALARM` | App manifest | **No** |
| `WRITE_EXTERNAL_STORAGE` (max SDK 28) | `camera_android_camerax` plugin | **No** |
| `READ_EXTERNAL_STORAGE` | Added by the manifest merger because of the one above | **No** |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX core (app-internal) | No (internal, safe) |

`docs/release_process.md` §10.4 says every permission must be justified, or removed if not
needed, before a Play release.

### Findings

**Storage permissions are not needed:**
- The camera plugin saves each photo with `File.createTempFile(...)` in the app's private
  cache folder (`getCacheDir()`). That needs no permission. It asks for
  `WRITE_EXTERNAL_STORAGE` only for features this app does not use (saving to shared
  storage on Android 9 and older). Both camera screens set `enableAudio: false` and do not
  record video.
- The cropper and OCR downscaler write to `getTemporaryDirectory()` (app-private).
- Backup export/import and "pick image" use `file_picker`, whose Android code opens the
  system picker (`ACTION_OPEN_DOCUMENT`, `ACTION_GET_CONTENT`, `ACTION_CREATE_DOCUMENT`).
  The system picker gives access to the chosen file only, with no storage permission.

**`SCHEDULE_EXACT_ALARM` looks unused (new finding):**
- `AlarmReceiver.kt` schedules with `setAndAllowWhileIdle(...)` (Android 6+) or `set(...)`.
  These are *inexact* alarms and need no permission. No code calls `setExact...`,
  `setAlarmClock` or `canScheduleExactAlarms()`.
- On Android 14+ this permission is off by default, and Google Play reviews apps that
  declare it. Keeping an unused one is a store risk.

## Plan for the fix

### Part A — Document the permissions the app really uses (docs only)

1. `docs/security.md` §10 table:
   - `CAMERA` row: add OCR scanning next to AirQR. Requested when the user opens the OCR
     scanner or the QR scanner.
   - Add a `POST_NOTIFICATIONS` row: the ongoing timer notification for a running task and
     pending-task alerts. Asked at runtime on Android 13+ (from the timer settings screen
     or when a timer starts). If denied, timers and alerts still work inside the app; only
     the notification is not shown.
   - Add a `RECEIVE_BOOT_COMPLETED` row: re-schedules task reminder alarms after the phone
     restarts. Granted at install (normal permission).
   - `SCHEDULE_EXACT_ALARM`: no row if Part C is approved (it is removed). If Part C is not
     approved, add a row explaining it.
   - "External storage / file access" row: reword to say backup uses the system file
     picker, which needs no storage permission.
   - "Does NOT request" list: remove `NOTIFICATIONS` (wrong). Add `READ_EXTERNAL_STORAGE`
     and `WRITE_EXTERNAL_STORAGE` (removed in Part B), and `SCHEDULE_EXACT_ALARM` if Part C
     is approved.
2. `docs/release_process.md` §10.4: replace the list of three permissions with the full
   list: `CAMERA`, `RECORD_AUDIO`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
   `INTERNET` (plus `SCHEDULE_EXACT_ALARM` only if Part C is not approved). Note that
   AndroidX's `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` is internal and expected.

### Part B — Remove the two storage permissions

1. In `android/app/src/main/AndroidManifest.xml`, add next to the existing
   `ACCESS_NETWORK_STATE` removal, with a short comment saying why (camera saves to the app
   cache; file access uses the system picker):
   ```xml
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" tools:node="remove" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" tools:node="remove" />
   ```
2. Add `EXTERNAL_STORAGE` to the banned-pattern list in both manifest check commands in
   `docs/release_process.md`, so a future plugin cannot add it back unnoticed.

### Part C — Remove `SCHEDULE_EXACT_ALARM` (new; needs your yes separately)

1. Delete the `SCHEDULE_EXACT_ALARM` line from `android/app/src/main/AndroidManifest.xml`
   and update the comment above it. Keep `RECEIVE_BOOT_COMPLETED`.
2. Add `SCHEDULE_EXACT_ALARM|USE_EXACT_ALARM` to the banned-pattern list in the manifest
   check commands.

Reminder timing does not change. The code already uses inexact alarms.

## Checks

- Rebuild the release manifest (`flutter build apk --flavor prod --release ...`) and run the
  manifest check. Expected: zero banned matches, and the permission list equals the
  documented list.
- `flutter analyze` and `flutter test` (no Dart changes, but run as the rules require).
- Manual test on a device (I cannot do this; you would need to):
  - OCR: take a photo, crop it, and recognise text. Also pick an image from the gallery.
  - AirQR scan.
  - Backup export and import.
  - A reminder alarm still fires, also after a phone restart.
  - If you have one, repeat OCR and backup on an Android 9 (or older) phone. That is the
    only version range where the storage permission was used at all.

## Risks

- Low. If an older phone did need the storage permission, the camera or picker would show
  an error there. The fix would be to undo Part B.

## After the change

Write a change log in `change_log/` that references this plan, and set this plan's status
to `completed` (or `partial_completion` if a part is not approved).
