# Automatic Carry-Over of Incomplete Tasks to Next Day

**Plan Reference:** [plans/20260829_230500_auto_carry_over_incomplete_todos.md](plans/20260829_230500_auto_carry_over_incomplete_todos.md)
**Status:** Completed

---

## What Changed

### 1. Core Layer (`lib/core/utils/task_default_rules.dart`)
- Added look-back limits and defaults:
  - `kMinCarryOverLookBackDays = 1`
  - `kMaxCarryOverLookBackDays = 45`
  - `kDefaultCarryOverLookBackDays = 7`
- Added `sanitizeCarryOverLookBackDays(int? days)` to clamp lookback days safely within 1..45 days.
- Expanded `CarryOverLookBack` presets enum to include 1d (`previousDay`), 3d (`threeDays`), 7d (`lastSevenDays`), 14d (`fourteenDays`), 30d (`thirtyDays`), and 45d (`fortyFiveDays`).

### 2. Application Layer (`lib/application/task_defaults_notifier.dart`)
- Added `kAutoCarryOverEnabledKey` and `kCarryOverLookBackDaysKey` preference keys.
- Added `autoCarryOverEnabled` (boolean, default: `true`) and `carryOverLookBackDays` (integer, default: `7`, clamped: 1..45) to `TaskDefaults`.
- Added `setAutoCarryOverEnabled(bool value)` and `setCarryOverLookBackDays(int days)` to `TaskDefaultsNotifier`.
- Updated `_loadInitialState` and `copyWith` to handle auto carry-over settings.

### 3. Presentation Layer
- **Settings (`lib/presentation/screens/settings/task_defaults/defaults_task_actions_screen.dart`):**
  - Added "Auto carry-over incomplete tasks" toggle switch (default: ON).
  - When auto carry-over is disabled, offers the optional manual carry-over prompt toggle.
  - Added look-back window card featuring an interactive Slider (1..45 days), current duration badge, and quick-preset choice chips (1d, 3d, 7d, 14d, 30d, 45d).
- **Daily List (`lib/presentation/screens/daily_list/daily_list_screen.dart` & `lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart`):**
  - Added `CarryOverSheet.findAllUnfinishedCandidates` to gather all unfinished tasks across the configurable lookback window, deduplicating against existing tasks on today.
  - Updated `_maybeOfferCarryOver()` to automatically copy unfinished tasks to today on app open when auto carry-over is enabled, invalidating today's tasks and statistics providers and showing a notification SnackBar without popping up manual selection dialogs.
- **Pending Alert Watcher (`lib/presentation/shared/widgets/pending_alert_watcher.dart`):**
  - Ensures auto carry-over executes on day-start / interval triggers so that `pendingAlertPayloadProvider` cleanly reports tasks as today's tasks rather than outdated past-day items.

### 4. Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`)
- Added `defaultsAutoCarryOver`, `defaultsAutoCarryOverDetail`, and `autoCarryOverDone` keys in both English and Malayalam.

### 5. Tests
- Updated `test/application/task_defaults_notifier_test.dart` and `test/core/task_default_rules_test.dart` to verify default states, loading, clamping, and preference persistence.
- Verified that all 626 automated tests pass with 0 errors and static analysis passes with 0 warnings.
