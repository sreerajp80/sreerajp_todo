# Fix the 738 analyzer problems after the package upgrade

Implements plan: [plans/20261011_084902_fix_package_upgrade_breakage.md](../plans/20261011_084902_fix_package_upgrade_breakage.md)

## Summary

The package upgrades in `pubspec.yaml` (Riverpod 2 → 3, file_picker 8 → 13) broke the
build: `flutter analyze` showed 738 problems. The code now uses the new APIs. The upgraded
versions are kept. App behavior does not change.

Result:

- `flutter analyze`: **No issues found** (was 738).
- `flutter test`: **864 tests, all passed**.
- `dart format`: no changes needed.

## What changed

### Riverpod 3

- Added `import 'package:flutter_riverpod/legacy.dart';` to every file that uses
  `StateNotifier`, `StateNotifierProvider` or `StateProvider`. In 16 notifier files the
  main `flutter_riverpod.dart` import was no longer used, so it was removed. The
  `StateNotifierProvider` pattern stays as CLAUDE.md requires.
  - `lib/application/providers.dart` (keeps both imports)
  - `lib/application/app_lock_notifier.dart`, `appearance_notifier.dart`,
    `daily_todo_notifier.dart`, `date_time_settings_notifier.dart`,
    `focus_pulse_notifier.dart`, `locale_notifier.dart`, `pending_alert_notifier.dart`,
    `pomodoro_notifier.dart`, `recurrence_rules_notifier.dart` (keeps both imports),
    `ritual_notifier.dart`, `security_settings_notifier.dart`, `statistics_notifier.dart`,
    `task_defaults_notifier.dart`, `time_tracking_notifier.dart`,
    `time_tracking_settings_notifier.dart`, `timer_paused_store.dart`,
    `voice_capture_notifier.dart`
  - `test/application/battery_power_optimization_test.dart`
- Replaced the removed `AsyncValue.valueOrNull` with `.value` (same meaning in Riverpod 3):
  - `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`
  - `lib/presentation/screens/focus/focus_screen.dart`
  - `lib/presentation/screens/time_segments/time_segments_screen.dart`
  - `lib/presentation/shared/widgets/pomodoro_banner.dart`
- `test/presentation/screens/mastery_deck/mastery_deck_test.dart`: imports
  `package:flutter_riverpod/misc.dart` for the `Override` type.

### file_picker 13

- `lib/presentation/screens/backup/backup_screen.dart`: uses the static
  `FilePicker.getDirectoryPath()` and `FilePicker.pickFile()`.
- `lib/presentation/screens/ocr/ocr_scan_screen.dart`: uses
  `FilePicker.pickFile(type: FileType.image)`.
- `lib/data/services/data_handoff_service.dart`:
  - Import uses `FilePicker.pickFile()`.
  - Export passes the text as bytes to `FilePicker.saveFile()`, which now writes the file
    itself and returns a `Uri`. The method returns that path. If the dialog is cancelled
    or not available, it still falls back to the app documents folder, as before.
- `test/presentation/screens/backup/backup_screen_test.dart`: the fake now extends
  `FilePickerPlatform` (with `MockPlatformInterfaceMixin`) and is set through
  `FilePickerPlatform.instance`. A small `FakePlatformFile` replaces the removed
  `FilePickerResult` / `PlatformFile(...)` constructor.
- `pubspec.yaml`: new **dev dependency** `plugin_platform_interface: ^2.1.8` (it was
  already a transitive dependency).
- `docs/dependencies.md`: lists the new dev dependency.

### Test fix for a Riverpod 3 runtime change

`test/application/battery_power_optimization_test.dart`: three tests read an
`autoDispose` stream provider with `container.read(provider.future)` and nothing
listening. Riverpod 3 disposes such a provider before it emits, so the read failed with
"disposed during loading state". The tests now add `container.listen(...)` first to keep
the provider alive. I checked the app code: all its `ref.read(... .future)` calls use
providers that are not `autoDispose`, so the app is not affected.

## Notes

- Offline audit: the non-dev dependency tree contains `http` (and `http_parser`), pulled
  in by `image_cropper_platform_interface`. This was already in `pubspec.lock` before this
  upgrade and was not added by this change. It is listed here so it can be looked at
  separately.
- Generated `*.freezed.dart` / `*.g.dart` files were not edited.
