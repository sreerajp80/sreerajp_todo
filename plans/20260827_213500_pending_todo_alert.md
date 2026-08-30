# Pending Todo Alert (Day-Start and Periodic Intervals with Pending Task List)

**Status:** Implemented

## Problem / Requirement
The user requested an alert system in the ToDo app for pending tasks:
1. Alert the user at each day's beginning (day start) about remaining pending todos.
2. Alert the user at configurable intervals (e.g. 1 hour, 2 hours, 4 hours) set in Settings.
3. Show the **List of pending todos** in the alert with interactive task items and quick actions (such as starting a timer, reviewing tasks, or snoozing).

## Proposed Solution & Architecture

1. **State & Settings (`lib/application/pending_alert_notifier.dart`)**:
   - `PendingAlertSettings`:
     - `enabled`: master toggle for pending task alerts.
     - `dayStartAlertEnabled`: trigger alert when starting a new day.
     - `dayStartHour` & `dayStartMinute`: time of day-start alert (defaults to 9:00 AM or matches day start preferences).
     - `intervalMinutes`: reminder interval (0 = Off, 30, 60, 120, 180, 240 minutes).
     - `hapticFeedback`: gentle haptic vibration pulse when alert triggers.
     - `lastDayAlertDate`: ISO date string when the day-start alert was last triggered (prevents multiple triggers on the same day).
     - `lastIntervalAlertEpoch`: timestamp (milliseconds) of the last interval alert.
   - Stored in `SharedPreferences` (offline, persistent).

2. **Alert Trigger Watcher (`lib/presentation/shared/widgets/pending_alert_watcher.dart`)**:
   - Monitors clock ticks and lifecycle state transitions (app foreground/open).
   - Checks if there are active pending or working tasks for today.
   - Evaluates day-start boundary and interval elapsed conditions.
   - Triggers the interactive modal sheet `PendingTodosAlertSheet`.

3. **Pending Tasks Alert Sheet (`lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart`)**:
   - Displays a clean bottom sheet listing all pending todos for today.
   - Shows task title, priority badge, and target duration.
   - Quick action to start timer on a pending task directly.
   - Actions to "Go to Today's Tasks", "Snooze", and "Dismiss".

4. **Settings Screen (`lib/presentation/screens/settings/pending_alerts_screen.dart`)**:
   - Full configuration UI under Settings:
     - Master switch
     - Day Start Alert toggle & time selector
     - Interval reminder choice list (Off, 30m, 1h, 2h, 3h, 4h)
     - Haptic feedback toggle
     - "Preview Pending Tasks Alert" button for instant testing.
   - Added entry in `SettingsScreen`.

5. **Localization**:
   - Bilingual strings added to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.

## Files to Modify / Create
- `lib/application/pending_alert_notifier.dart` (New)
- `lib/application/providers.dart` (Modify)
- `lib/core/constants/app_routes.dart` (Modify)
- `lib/presentation/shared/widgets/pending_alert_watcher.dart` (New)
- `lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart` (New)
- `lib/presentation/screens/settings/pending_alerts_screen.dart` (New)
- `lib/presentation/screens/settings/settings_screen.dart` (Modify)
- `lib/app.dart` (Modify)
- `lib/l10n/app_en.arb` (Modify)
- `lib/l10n/app_ml.arb` (Modify)
- `test/application/pending_alert_notifier_test.dart` (New)
- `test/presentation/pending_todos_alert_sheet_test.dart` (New)

## Verification
- Run `flutter test`
- Run `flutter analyze`
- Verify alert display and settings in dev environment.
