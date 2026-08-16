# Change Log — Features Doc Rewritten to Match the Code

Implements plan: `plans/20260816_205747_features-doc-implemented-only-pass.md`
(Option A — remove wrong claims and add the missing implemented features).

## Files changed

- `docs/features.md` (rewritten; no code files touched)

## Wrong or outdated claims removed

1. **Live database encryption.** The doc said the live database was plain and that
   device-key encryption was "planned". It is implemented: `DatabaseService` opens the
   database with a key from `DatabaseKeyService` (Android Keystore through a platform
   method channel, Windows DPAPI), and re-encrypts an existing plain database once.
   Corrected in the technical profile, the guarantees section, the restore section, and the
   summary matrix.
2. **Language switching.** The doc said there was no in-app language switch. Settings has a
   System / English / Malayalam selector backed by `locale_notifier.dart` and
   `shared_preferences`.
3. **Migrations.** The doc listed only v1 and v2. Now lists v1 to v7 with what each adds.
4. **Search.** Described as substring matching; it is now an FTS5 index (`todos_fts`) over
   title and description, with a `LIKE` fallback.
5. **"Zero network access".** Restated precisely: no internet, no cloud, no telemetry, but
   the optional Wi-Fi Sync screen opens local-network TCP sockets while it is open.
6. **Permissions.** The doc claimed no explicit permission was needed. `CAMERA` is declared
   for the AirQR scanner, and the doc now says so.
7. **Package list.** Added `shared_preferences`, `qr_flutter`, `mobile_scanner`, and the
   `archive` usage for backup ZIPs.
8. **Not documented on purpose.** `BackupService.runScheduledBackupIfNeeded()` exists but
   has no caller, so automatic scheduled backup is not described as a feature.

## Implemented features added

- Sub-task checklists (section 3.3) and task dependencies with the "Blocked by N" badge
  (section 3.4).
- Spaced repetition Mastery Deck with ease factor, interval, next review date, the
  Hard/Revision/Easy recall dialog, daily generation, and the `#mastery` tag (section 7).
- Morning intention card and evening reflection modal (section 8).
- Device-to-device transfer (section 12): AirQR optical frame streaming with parity frames
  and CRC32, encrypted peer-to-peer Wi-Fi sync with PIN pairing and add-only merge, and
  JSON / Markdown data handoff.
- Backup logs and the Backup Health Dashboard (section 14.3).
- Screen map updated with `/mastery-deck`, `/air-qr-scan`, `/wifi-sync`, `/data-handoff`,
  and a note that the bottom bar / rail holds Daily List, Mastery, and Statistics while
  Settings and the sync/export actions live in the app-bar overflow menu.
- Summary matrix rows rewritten to match the new body.

## Verification

Each statement in the rewritten doc was checked against `lib/`, `pubspec.yaml`,
`assets/config/app_config.json`, the Android manifest, and `MainActivity.kt`. No Dart code
changed, so `flutter analyze` and `flutter test` results are unaffected.
