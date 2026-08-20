# Date & Time, Security, and Backup settings

**Status:** in_progress

Adds three new settings groups to the Settings screen: **Date & time**, **Security &
privacy**, and expanded **Backup** options.

---

## 1. What is missing today

The Settings screen has Appearance, Language, Task defaults, Time tracking, Backup,
About and Permissions. These knobs do not exist yet:

**Date, time and calendar**
1. First day of week — `TableCalendar` in the day list uses its built-in default.
2. 24-hour vs 12-hour clock — every time label follows the device locale only.
3. Date format choice — `date_utils.dart` hard-codes `DateFormat.yMMMEd()`.
4. "Day start" hour — `todayAsIso()` uses raw `DateTime.now()`, so at 1 AM the app
   already treats the new calendar day as today. For a person working past midnight
   the previous day becomes read-only at once because of the Day Lock rule.
5. Working days / week-off days — statistics treat all seven days the same.

**Security and privacy**
6. App lock (PIN / password / device credential) on open.
7. Auto-lock after N minutes in the background.
8. Hide app content in the recent-apps preview (`FLAG_SECURE`).
9. Change / rotate the database key.
10. Hide task titles in notifications.

**Backup**
11. Automatic backup on a schedule (daily / weekly).
12. Backup folder location choice.
13. How many backups to keep (auto-delete old ones).
14. Remember the passphrase in secure storage, or always ask.
15. Backup when the app exits.

---

## 2. Two items that need a decision before coding

**(a) Item 10 — "hide task titles in notifications" cannot be built.**
The app has no notifications at all. There is no notification package and none is
allowed by the offline rules. `pomodoro_notifier.dart` even carries a comment saying
its alert is in-app only, "with no notification support". So there is nothing to
hide. **Plan: skip item 10.** The related real risk — task titles showing in the
recent-apps preview — is covered by item 8 (`FLAG_SECURE`).

**(b) Item 6 — biometric unlock without a new package.**
The approved dependency list has no `local_auth`, and the rules block new packages.
Two ways forward:

- **Chosen: device credential through a method channel.** Android's `KeyguardManager`
  `createConfirmDeviceCredentialIntent()` (API 21+, already in the platform) shows the
  phone's own unlock screen, which uses fingerprint or face where the user set that
  up. No new Dart package and no new Gradle library. It follows the same
  method-channel style the project already uses for the database key and the
  screen-wake flag.
- Alternative, not chosen: add the `androidx.biometric` Gradle library for a proper
  biometric prompt. That is an Android-side library rather than a Dart package, but
  it is still a new dependency and would need a rules and docs update.

The PIN and password modes are built fully in Dart, so they work on Windows too.
Windows has no device-credential option, so that choice is hidden there.

---

## 3. Design

### 3.1 Storage and state

Follow the existing pattern exactly: one `StateNotifier` per settings group, backed by
`SharedPreferences`, one page per sub-topic, all registered in
`lib/application/providers.dart`. Three new notifiers:

- `DateTimeSettingsNotifier` — `datetime_*` preference keys.
- `SecuritySettingsNotifier` — `security_*` preference keys.
- `BackupSettingsNotifier` — `backup_*` preference keys.

### 3.2 Day start hour (the one cross-cutting change)

`lib/core/utils/date_utils.dart` gains a module-level day-start offset:

```dart
int _dayStartHour = 0;
void setDayStartHour(int hour) => _dayStartHour = hour;
DateTime nowInAppDay() => DateTime.now().subtract(Duration(hours: _dayStartHour));
String todayAsIso() => _isoFormat.format(nowInAppDay());
```

`todayAsIso`, `isToday`, `isPastDate` and `isFutureDate` all route through
`nowInAppDay()`, so all 41 call sites across repositories, use-cases and screens pick
the setting up with no edit of their own. `setDayStartHour` is called once at startup
from `main.dart`, and again from the notifier whenever the value changes. `core/`
stays pure Dart with no Flutter import.

### 3.3 Clock and date format

`date_utils.dart` gains `formatTimeOfDay()`, `formatDateTime()` and a configurable
`formatDate()`, driven by the saved date pattern (`yMMMEd`, `yMd`, `dMy`, `Mdy`,
`iso`) and the clock choice (`system` / `12h` / `24h`). Screens that call `DateFormat`
directly switch to these helpers, so one setting reaches every label.

### 3.4 App lock

- PIN and password are hashed with PBKDF2-HMAC-SHA256 through the existing
  `CryptoUtils.deriveKey`, with a fresh random salt. Only the salt and the hash are
  saved. The PIN itself is never stored and never logged.
- A `LockGate` widget wraps the router in `lib/app.dart`, watches the app lifecycle
  (same style as `timer_lifecycle_watcher.dart`), and shows the lock screen on cold
  start and after the auto-lock delay in the background.
- Failed attempts get a growing delay, to slow down guessing.

### 3.5 Database key rotation

`DatabaseService` already runs `PRAGMA rekey` in its migration path, so rotation is
supported. The new flow: finish open work, run `PRAGMA rekey` with a fresh 32-byte
random key, store the new key through `DatabaseKeyService`, then reopen. The screen
forces a fresh backup first and warns that older backup files still need their own
passphrase.

### 3.6 Backup schedule, retention, folder and saved passphrase

`BackupService.runScheduledBackupIfNeeded()` already exists but nothing calls it. It
gains an interval argument (daily / weekly) and a retention step that deletes the
oldest files beyond the keep count, using the existing `listBackups` and
`deleteBackup`. The folder is picked with `file_picker` (already a dependency) and
falls back to `getDefaultBackupDirectory()`.

When the user chooses to save the passphrase, it is encrypted at rest by the
platform: the Android Keystore master key through two new methods on the existing
`in.sreerajp.todo/database_key` channel, and DPAPI on Windows through the existing
`win32_dpapi.dart`. It is never written in plain text and never logged. A saved
passphrase is required for scheduled and on-exit backups; when it is not saved, those
switches stay disabled with a note saying why.

---

## 4. Files to change

### New files

**Application layer**
- `lib/application/date_time_settings_notifier.dart`
- `lib/application/security_settings_notifier.dart`
- `lib/application/backup_settings_notifier.dart`

**Core layer**
- `lib/core/utils/date_format_rules.dart` — the format, clock and week-start enums.
- `lib/core/utils/app_lock_rules.dart` — lock modes, auto-lock delays, PIN checks.
- `lib/core/utils/backup_schedule_rules.dart` — schedule, retention, "is it due".
- `lib/core/security/app_lock_service.dart` — PIN hashing and verification.
- `lib/core/security/secret_store.dart` — platform-encrypted string storage.

**Presentation layer**
- `lib/presentation/screens/settings/date_time_screen.dart` — group page.
- `lib/presentation/screens/settings/date_time/week_start_screen.dart`
- `lib/presentation/screens/settings/date_time/clock_format_screen.dart`
- `lib/presentation/screens/settings/date_time/date_format_screen.dart`
- `lib/presentation/screens/settings/date_time/day_start_screen.dart`
- `lib/presentation/screens/settings/date_time/working_days_screen.dart`
- `lib/presentation/screens/settings/security_screen.dart` — group page.
- `lib/presentation/screens/settings/security/app_lock_screen.dart`
- `lib/presentation/screens/settings/security/auto_lock_screen.dart`
- `lib/presentation/screens/settings/security/database_key_screen.dart`
- `lib/presentation/screens/settings/backup_settings_screen.dart` — group page.
- `lib/presentation/screens/settings/backup/auto_backup_screen.dart`
- `lib/presentation/screens/settings/backup/backup_location_screen.dart`
- `lib/presentation/screens/settings/backup/backup_retention_screen.dart`
- `lib/presentation/screens/settings/backup/backup_passphrase_screen.dart`
- `lib/presentation/shared/widgets/lock_gate.dart`
- `lib/presentation/screens/lock/lock_screen.dart`
- `lib/presentation/screens/lock/widgets/pin_pad.dart`

**Tests**
- `test/core/date_format_rules_test.dart`
- `test/core/app_lock_rules_test.dart`
- `test/core/backup_schedule_rules_test.dart`
- `test/core/date_utils_day_start_test.dart`
- `test/application/date_time_settings_notifier_test.dart`
- `test/application/security_settings_notifier_test.dart`
- `test/application/backup_settings_notifier_test.dart`
- `test/data/backup_retention_test.dart`

### Changed files

- `lib/core/utils/date_utils.dart` — day-start offset and format helpers.
- `lib/core/constants/app_routes.dart` — routes for every new page.
- `lib/core/constants/app_strings.dart` — any non-localized strings.
- `lib/app.dart` — register the routes, wrap the router in `LockGate`.
- `lib/main.dart` — apply the saved day-start hour before the first frame.
- `lib/application/providers.dart` — the three new providers and a secret-store
  provider.
- `lib/presentation/screens/settings/settings_screen.dart` — three new cards.
- `lib/presentation/screens/daily_list/daily_list_screen.dart` — calendar week start
  and working-day shading.
- `lib/presentation/screens/time_segments/time_segments_screen.dart` — clock format.
- `lib/presentation/screens/backup/backup_screen.dart` — use the chosen folder and
  the saved passphrase, and link to the new settings page.
- `lib/presentation/screens/backup/widgets/backup_list_tile.dart` — clock format.
- `lib/presentation/screens/backup/widgets/backup_health_dashboard.dart` — same.
- `lib/presentation/screens/statistics/statistics_screen.dart` and its chart and
  table widgets — date format and working-day averages.
- `lib/data/backup/backup_service.dart` — schedule interval and retention pruning.
- `lib/data/database/database_service.dart` — a key rotation method.
- `lib/data/database/database_key_service.dart` — store a rotated key, encrypt and
  decrypt secrets.
- `lib/core/utils/win32_dpapi.dart` — reuse for the Windows secret store if needed.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` —
  `FLAG_SECURE` channel, device-credential channel, secret encrypt and decrypt.
- `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` — all new user-visible text, then
  regenerate localizations.
- `docs/features.md`, `docs/architecture.md`, `docs/security.md` — document the new
  settings, the day-start rule and the lock design.

---

## 5. Order of work

1. **Date & time group** — enums, notifier, `date_utils` changes, five pages, routes,
   settings card, wire up the calendar, statistics and time labels, tests.
2. **Security group** — lock service, secret store, MainActivity channels, lock
   screen and gate, key rotation, three pages, tests.
3. **Backup group** — schedule rules, retention in `BackupService`, saved passphrase,
   backup on exit, four pages, tests.
4. **Finish** — `dart format`, `flutter analyze` at zero issues, `flutter test`, docs
   update, and a change log in `change_log/`.

Each phase leaves the app building and passing tests on its own.

---

## 6. Rules kept

- No new Dart package. Nothing from the blocked categories. Still fully offline.
- No network permission added to the manifest; `android:allowBackup="false"` stays.
- PINs, passphrases and keys are never logged and never stored in plain text.
- All new user-visible text goes through the `.arb` files.
- Widgets read providers only; no direct DAO or database access.
- Day Lock, terminal-status lock, one-open-segment and title-uniqueness rules are
  unchanged — the day-start hour only moves where the day boundary sits.

---

## 7. Risks

- **Day start hour** touches the whole app through `todayAsIso()`. It is centralized
  on purpose, and a dedicated test covers the boundary.
- **Key rotation** can lose data if it is interrupted. A fresh backup is forced
  first, and the old key is only dropped after the reopen succeeds.
- **App lock** must never lock the user out for good. A forgotten PIN cannot be
  recovered, so the setup screen says this plainly before the PIN is saved.
