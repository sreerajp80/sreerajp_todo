# Android permissions: document the real list and remove unused ones

Implements plan: `plans/20261011_201633_android_permissions_cleanup.md` (Parts A, B and C,
all approved).

## Why

The merged release manifest had permissions that the docs did not list. Two of them
(storage) came from the camera plugin and are not used by this app. One
(`SCHEDULE_EXACT_ALARM`) was declared but never used, because reminders use inexact alarms.
`docs/security.md` also wrongly said the app does not request notifications.

## What changed

### `android/app/src/main/AndroidManifest.xml`

- Removed `SCHEDULE_EXACT_ALARM`. `AlarmReceiver.kt` uses `setAndAllowWhileIdle` / `set`
  (inexact alarms), which need no permission. Reminder timing does not change.
- Rewrote the comment above `RECEIVE_BOOT_COMPLETED` to say what it is for (scheduling
  reminders again after a restart).
- Added `tools:node="remove"` entries for `WRITE_EXTERNAL_STORAGE` and
  `READ_EXTERNAL_STORAGE`, with a comment. The camera plugin saves photos in the app's
  private cache folder, and backup and image picking use the system file picker, so
  neither permission is needed.
- The comments avoid writing the banned permission names. The manifest merger copies
  comments into the final manifest, so a name in a comment made the manifest check report a
  false match. (Found during the first rebuild and fixed in this change.)

### `docs/security.md` §10 Permissions

- `CAMERA` row now covers OCR scanning as well as AirQR.
- Added rows for `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED`.
- The file access row now says the system file picker is used and no storage permission is
  needed.
- Added a note that reminder alarms are inexact and need no alarm permission.
- "Does NOT request" list: removed the wrong `NOTIFICATIONS` entry; added
  `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `SCHEDULE_EXACT_ALARM` and
  `USE_EXACT_ALARM`.

### `docs/release_process.md`

- §10.4: replaced the three-permission list with the full list of permissions the app uses,
  including the internal AndroidX `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. Notes that the
  storage permissions are removed and exact-alarm permissions must not be declared.
- Both manifest check commands (release checklist and step 7) now also ban
  `EXTERNAL_STORAGE` and `EXACT_ALARM`. Step 7 now also includes `CHANGE_WIFI`, so both
  commands use the same pattern.

## Checks

- `flutter analyze`: no issues.
- `flutter test`: all 864 tests passed.
- `flutter build apk --flavor prod --release ...`: built. The first attempt failed only
  because `flutter test` was run at the same time and rewrote the generated plugin
  registrant with test-only plugins. Building again on its own worked.
- Manifest check on the new release manifest: zero banned matches. Final permissions:
  `CAMERA`, `RECORD_AUDIO`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `INTERNET`, and
  the internal AndroidX permission. This matches the documented list.

## Still to do (manual, on a device)

- OCR: take a photo, crop, recognise text; also pick an image from the gallery.
- AirQR scan.
- Backup export and import.
- A reminder alarm fires, also after a phone restart.
- If possible, repeat OCR and backup on an Android 9 (or older) phone.
