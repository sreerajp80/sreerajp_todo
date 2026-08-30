# Automatic Carry-Over of Incomplete Tasks to Next Day

**Status:** In Progress

## Problem & Feature Goal
Currently, incomplete tasks from previous days require manual selection via the `CarryOverSheet` bottom sheet or manual individual porting from past days / pending alerts.
The user requested:
1. **Auto Carry-Over:** The app should automatically carry over / move all incomplete tasks (`pending` and `working`) from previous days into today on app launch / day start without asking.
2. **Settings Control:** Provide a setting to enable or disable automatic carry-over in Settings -> Task defaults -> Task actions. The default is **Enabled** (`true`).
3. **Configurable Look-back Window:** The user can configure the look-back window from **1 to 45 days** (default: 7 days).
4. **Daily Alarm / Alert Screen Integration:** When auto carry-over is enabled, previous days' tasks are automatically moved into today. Therefore, manual task-porting prompts (such as `CarryOverSheet` and the "Previous Days" porting list on the pending alarm sheet) are skipped or automatically empty because tasks are already carried over.

---

## Proposed Changes

### 1. Core Layer (`lib/core/utils/task_default_rules.dart`)
- Define constants:
  - `kMinCarryOverLookBackDays = 1;`
  - `kMaxCarryOverLookBackDays = 45;`
  - `kDefaultCarryOverLookBackDays = 7;`
- Add helper `sanitizeCarryOverLookBackDays(int? days)`.
- Update `CarryOverLookBack` enum or support configurable integer look-back days up to 45 days.

### 2. Application Layer (`lib/application/task_defaults_notifier.dart`)
- Add `kAutoCarryOverEnabledKey = 'defaults_auto_carry_over_enabled'`.
- Add `kCarryOverLookBackDaysKey = 'defaults_carry_over_look_back_days'`.
- In `TaskDefaults`:
  - Add `autoCarryOverEnabled` boolean property (default: `true`).
  - Add `carryOverLookBackDays` integer property (default: `7`, clamped 1..45).
  - Update `copyWith`.
- In `TaskDefaultsNotifier`:
  - Load `autoCarryOverEnabled` (default `true`) and `carryOverLookBackDays` (default `7`) from `SharedPreferences`.
  - Add `setAutoCarryOverEnabled(bool value)` and `setCarryOverLookBackDays(int days)`.

### 3. Presentation Layer

#### Settings (`lib/presentation/screens/settings/task_defaults/defaults_task_actions_screen.dart`)
- Add `SwitchListTile` for "Auto carry-over incomplete tasks" (`defaults.autoCarryOverEnabled`), enabled by default.
- If auto carry-over is disabled by the user, offer the optional manual carry-over prompt switch (`defaults.carryOverEnabled`).
- Add look-back window selection (presets: 1 day, 3 days, 7 days, 14 days, 30 days, 45 days, plus custom stepper/slider dialog from 1 to 45 days).

#### Daily List & App Launch (`lib/presentation/screens/daily_list/daily_list_screen.dart` & `lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart`)
- In `CarryOverSheet`:
  - Add `findAllUnfinishedCandidates(ref, targetDate: today, lookBackDays: lookBackDays)`.
- Update `DailyListScreen._checkCarryOverPrompt()`:
  - If `defaults.autoCarryOverEnabled` is `true` and today has not yet been processed (`defaults.carryOverLastAsked != today`):
    1. Mark today as processed (`notifier.markCarryOverAsked(today)`).
    2. Search for all uncompleted candidates across look-back days with `CarryOverSheet.findAllUnfinishedCandidates(...)`.
    3. If candidate tasks exist: execute `copyTodosUseCase(candidateIds, today)`.
    4. If tasks were copied:
       - Invalidate `dailyTodoProvider(today)`.
       - Invalidate `pendingAlertPayloadProvider`.
       - Invalidate `statisticsProvider`.
       - Display brief SnackBar: "Automatically carried over X tasks to today".
    5. Skip showing the manual `CarryOverSheet`.
  - Else if `defaults.carryOverEnabled` is `true` (and auto carry-over is off):
    - Proceed with existing manual `CarryOverSheet.show(...)` prompt.

#### Pending Alert Watcher & Alarm (`lib/presentation/shared/widgets/pending_alert_watcher.dart`)
- When the daily alarm / morning reminder triggers, ensure auto-carryover runs or `pendingAlertPayloadProvider` uses the carried-over tasks for today.

### 4. Localization (`lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`)
- Add localized strings:
  - `defaultsAutoCarryOver`: "Auto carry-over incomplete tasks"
  - `defaultsAutoCarryOverDetail`: "Automatically carry over unfinished tasks from earlier days into today."
  - `autoCarryOverDone`: "{count, plural, =1{Automatically carried over 1 task to today} other{Automatically carried over {count} tasks to today}}"
  - `carryOverLookBackDaysLabel`: "{days, plural, =1{1 day (Yesterday)} other{{days} days}}"
  - `carryOverLookBackCustom`: "Custom ({days} days)"

### 5. Tests
- Update `task_defaults_notifier_test.dart` and `task_default_rules_test.dart`.

---

## Verification Plan

### Automated Tests
- `flutter test`
- `flutter analyze`

### Manual Verification
- Verify settings toggle and 1-45 days look-back picker in Settings -> Task defaults -> Task actions.
- Verify auto carry-over on launch with multiple past days' unfinished tasks.
