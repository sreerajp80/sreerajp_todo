# Features Doc — Keep Only Implemented Features (Accuracy Pass)

**Status:** completed (Option A; change log:
`change_log/20260816_211500_features-doc-implemented-only-pass.md`)

## Files to be changed

- `docs/features.md` (only file changed)

## What the issue is

`docs/features.md` no longer matches the code. I checked the doc line by line against
`lib/`, `pubspec.yaml`, and `android/app/src/main/AndroidManifest.xml`. Two kinds of
problems exist.

### A. Claims in the doc that are NOT true of the current app

1. **"Live database is not encrypted; device-key encryption is planned"**
   (Section 1 Technical Profile, Section 2.2, Section 13 summary row).
   Not true any more. `lib/data/database/database_service.dart` opens the database with a
   password from `lib/data/database/database_key_service.dart`, and there is a one-time
   migration path that re-encrypts an existing plain database. Windows uses DPAPI
   (`lib/core/utils/win32_dpapi.dart`).

2. **"No in-app language switch — language follows the device locale only"**
   (Section 1 Inclusive Design, Section 2.5).
   Not true any more. `lib/presentation/screens/settings/settings_screen.dart` has a
   language selector (System / English / Malayalam) backed by
   `lib/application/locale_notifier.dart`.

3. **"Migrations: v1 baseline, v2 status sync"** (Section 1).
   The app now has migrations v1 through v7 in
   `lib/data/database/migrations/`.

4. **"Cross-day search = substring match"** (Section 9).
   Search now uses an FTS5 full-text index (`todos_fts` MATCH) in
   `lib/data/dao/todo_dao.dart`, with a `LIKE` query only as a fallback.

5. **"Zero network access / zero external network libraries"** (Section 1, Section 2.1).
   Needs a precise rewrite. There is still no internet or cloud use, but
   `lib/data/services/p2p_wifi_sync_service.dart` opens a local `ServerSocket` /
   `Socket` for device-to-device sync on the same local network.

6. **"No explicit permissions are required"** (Section 12, Permissions Info row).
   `AndroidManifest.xml` now declares `android.permission.CAMERA` (QR scanning with
   `mobile_scanner`). The doc row must say this.

7. **Package list** (Section 1) is missing `shared_preferences`, `qr_flutter`, and
   `mobile_scanner`, which are in `pubspec.yaml`.

8. **Restore description** (Section 11.2) still says the restored database is
   "currently unencrypted". Wrong after the encryption change.

### B. Features that ARE implemented but are missing from the doc

These all exist in code with screens, DAOs, migrations, and routes:

- Sub-tasks checklist and task dependencies (`sub_task_dao.dart`,
  `task_dependency_dao.dart`, migration v4).
- Morning intention card and evening reflection modal (`daily_reflection_dao.dart`,
  migration v5, widgets under `presentation/screens/daily_list/widgets/`).
- Spaced repetition "Mastery Deck" (`spaced_repetition_dao.dart`, migration v6,
  `/mastery-deck` screen, `generate_spaced_repetition_tasks.dart`).
- Backup health dashboard and backup logs (`backup_logs_dao.dart`, migration v7,
  `backup_health_dashboard.dart`).
- Air QR offline transfer (`air_qr_service.dart`, `/air-qr-scan`).
- Peer-to-peer Wi-Fi sync (`p2p_wifi_sync_service.dart`, `/wifi-sync`).
- Multi-format data handoff export (`data_handoff_service.dart`, `/data-handoff`).
- Navigation change: the bottom bar / rail destinations are Daily, Mastery, Statistics;
  Settings and the sync/export actions moved into the app-bar overflow ("dotted") menu.

## The plan for the fix

Rewrite `docs/features.md` so that every statement in it is backed by current code.

1. **Remove or correct** every claim listed in part A above, so nothing unimplemented or
   outdated remains. In particular: state the live database as encrypted with a
   device-derived key; state the in-app language selector; list migrations v1–v7; describe
   search as FTS5; restate the offline guarantee precisely as "no internet, no cloud, no
   telemetry — local-network sockets only for opt-in device-to-device sync"; and list the
   camera permission.
2. **Add** short, factual sections for the implemented features listed in part B, in the
   same style as the rest of the doc (sub-tasks and dependencies, intention/reflection,
   mastery deck, backup health, Air QR, Wi-Fi sync, data handoff).
3. **Update the screen map (Section 12)** to include `/mastery-deck`, `/air-qr-scan`,
   `/wifi-sync`, `/data-handoff`, and fix the Permissions Info row.
4. **Update the summary matrix (Section 13)** so its rows match the corrected body.
5. Keep the existing document structure, headings, and plain-English style. No code
   changes; no other file is touched.

## Verification

- Re-read the finished `docs/features.md` against `lib/`, `pubspec.yaml`, and the Android
  manifest, so each remaining line has code behind it.
- No Dart code changes, so `flutter analyze` / `flutter test` are not affected. I can still
  run them if you want.

## Open choice for approval

- **Option A (recommended):** do steps 1–5 — remove wrong claims *and* add the missing
  implemented features, so the doc is a true picture of the app.
- **Option B (narrow):** do only step 1 and 3–4 pruning — remove wrong claims, do not add
  the missing features. The doc would then be correct but incomplete.
