# Fix the 738 analyzer problems after the package upgrade

**Status:** completed

## What the issue is

`flutter analyze` reports 738 problems (728 errors, 10 warnings). They all come from the
major package upgrades in `pubspec.yaml` that are not yet committed:

| Package | Old | New | What broke |
|---------|-----|-----|------------|
| `flutter_riverpod` | 2.6 | 3.4 | `StateNotifier`, `StateNotifierProvider` and `StateProvider` moved out of the main import into `package:flutter_riverpod/legacy.dart`. `AsyncValue.valueOrNull` was removed (`value` is now nullable and does the same job). The `Override` type moved to `package:flutter_riverpod/misc.dart`. |
| `file_picker` | 8 | 13 | `FilePicker.platform` is gone; all methods are now static (`FilePicker.pickFile()`, `FilePicker.pickFiles()`, ...). `FilePickerResult` was removed. `pickFiles()` returns a list, `pickFile()` returns one file or `null`. `saveFile()` now needs the file bytes, writes the file itself, and returns a `Uri?`. `withData` / `allowMultiple` parameters were removed. |

About 95% of the errors are one root cause: the 18 notifier files cannot find
`StateNotifier`, so every `state` use in them (and in their tests and in the widgets that
read their state) fails. The other upgrades (`go_router` 18, `fl_chart` 1.2, `freezed` 4)
cause no analyzer errors.

## Plan for the fix

Keep the upgraded packages and update the code to the new APIs. No behavior change is
intended.

### Step 1 — Riverpod legacy import (main fix)

Add `import 'package:flutter_riverpod/legacy.dart';` to every file that uses
`StateNotifier`, `StateNotifierProvider` or `StateProvider`. This keeps the existing
`StateNotifierProvider` pattern that CLAUDE.md requires. No rewrite to the new `Notifier`
API.

### Step 2 — Riverpod small API changes

- Replace `.valueOrNull` with `.value` (same meaning in Riverpod 3).
- Import `package:flutter_riverpod/misc.dart` where tests use the `Override` type.

### Step 3 — file_picker 13 migration

- `backup_screen.dart`: use `FilePicker.getDirectoryPath()` and
  `FilePicker.pickFile(type: ..., allowedExtensions: ...)`; read `picked?.path`.
- `ocr_scan_screen.dart`: use `FilePicker.pickFile(type: FileType.image)`.
- `data_handoff_service.dart`:
  - import: `FilePicker.pickFile(...)`, read `file?.path`.
  - export: call `FilePicker.saveFile(bytes: utf8.encode(content), ...)`. The plugin now
    writes the file itself. If it returns a `Uri`, return its file path. If it returns
    `null` or throws, keep the current fallback (write to the app documents folder).
- `backup_screen_test.dart`: the old `FakeFilePicker extends FilePicker` no longer works
  (the class is now `abstract final`). Replace it with a fake that extends
  `FilePickerPlatform` and set `FilePickerPlatform.instance` in tests. This needs
  `MockPlatformInterfaceMixin`, so add `plugin_platform_interface` as a
  **dev dependency only**. It is the official Flutter-team package for faking plugins, is
  already in `pubspec.lock` as a transitive dependency, and has no network code. It will
  be added to `docs/dependencies.md`.

### Step 4 — Clean up what is left

Re-run `flutter analyze` and fix any errors that were hidden behind the first ones (for
example test fakes such as `_FakeTimeTrackingNotifier`, which need the legacy import).
Do not edit generated `*.freezed.dart` / `*.g.dart` files.

### Step 5 — Verify

- `dart format lib/ test/ integration_test/`
- `flutter analyze` → must report 0 issues.
- `flutter test` → all tests pass. Riverpod 3 also changes some runtime behavior (for
  example a failed provider now retries automatically, and errors read via `.future` are
  wrapped in `ProviderException`). If a test fails because of that, I will fix it in the
  smallest way and report it in the change log.
- Run the offline dependency audit command from CLAUDE.md to confirm no network packages
  came in with the upgrade.

## Files to be changed

Riverpod legacy import (Step 1):

- `lib/application/providers.dart`
- `lib/application/app_lock_notifier.dart`
- `lib/application/appearance_notifier.dart`
- `lib/application/daily_todo_notifier.dart`
- `lib/application/date_time_settings_notifier.dart`
- `lib/application/focus_pulse_notifier.dart`
- `lib/application/locale_notifier.dart`
- `lib/application/pending_alert_notifier.dart`
- `lib/application/pomodoro_notifier.dart`
- `lib/application/recurrence_rules_notifier.dart`
- `lib/application/ritual_notifier.dart`
- `lib/application/security_settings_notifier.dart`
- `lib/application/statistics_notifier.dart`
- `lib/application/task_defaults_notifier.dart`
- `lib/application/time_tracking_notifier.dart`
- `lib/application/time_tracking_settings_notifier.dart`
- `lib/application/timer_paused_store.dart`
- `lib/application/voice_capture_notifier.dart`
- `test/application/battery_power_optimization_test.dart` (and any other test file the
  analyzer still flags after Step 1)

`valueOrNull` → `value` (Step 2):

- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`
- `lib/presentation/screens/focus/focus_screen.dart`
- `lib/presentation/screens/time_segments/time_segments_screen.dart`
- `lib/presentation/shared/widgets/pomodoro_banner.dart`
- `test/presentation/screens/mastery_deck/mastery_deck_test.dart` (`Override` import)

file_picker (Step 3):

- `lib/presentation/screens/backup/backup_screen.dart`
- `lib/presentation/screens/ocr/ocr_scan_screen.dart`
- `lib/data/services/data_handoff_service.dart`
- `test/presentation/screens/backup/backup_screen_test.dart`
- `pubspec.yaml` (dev dependency `plugin_platform_interface`)
- `docs/dependencies.md`

Workflow:

- `change_log/<timestamp>_fix_package_upgrade_breakage.md` (new)

## Alternative (not chosen)

Revert `pubspec.yaml` to the old package versions. This removes the errors with no code
change, but throws away the upgrade. Tell me if you prefer this instead.
