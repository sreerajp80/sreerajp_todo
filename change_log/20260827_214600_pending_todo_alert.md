# Change Log: Pending Todo Alert (Day-Start and Periodic Intervals with Pending Task List)

**Date:** 2026-08-27  
**Plan Reference:** [plans/20260827_213500_pending_todo_alert.md](plans/20260827_213500_pending_todo_alert.md)

---

## Summary of Changes

Added a pending todo alert system that reminds the user at day-start and at customizable periodic intervals about active pending and in-progress tasks, presenting an interactive list of pending todos:

1. **State & Preferences (`lib/application/pending_alert_notifier.dart`, `lib/application/providers.dart`)**:
   - Implemented `PendingAlertSettings` model and `PendingAlertNotifier` with local storage in `SharedPreferences`.
   - Supports master enable switch, morning/day-start alert enable & time picker, periodic reminder intervals (Off, 30m, 1h, 2h, 3h, 4h), haptic feedback, and snooze/dismiss tracking.
   - Added `pendingAlertSettingsProvider` and `pendingTodosForTodayProvider`.

2. **Interactive Pending Tasks Modal (`lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart`)**:
   - Created a modal bottom sheet displaying the list of pending tasks for today with priority indicators and target duration badges.
   - Provided quick actions to directly start a timer on any task, open today's daily list, snooze reminders for 1 hour, or dismiss.

3. **Lifecycle Trigger Engine (`lib/presentation/shared/widgets/pending_alert_watcher.dart`)**:
   - Monitors clock ticks and lifecycle resumed events without polling the database when quiescent.
   - Triggers pending task alerts seamlessly while respecting 100% offline boundaries.

4. **Settings UI & Navigation (`lib/presentation/screens/settings/pending_alerts_screen.dart`, `lib/presentation/screens/settings/settings_screen.dart`, `lib/app.dart`, `lib/core/constants/app_routes.dart`)**:
   - Created "Pending Task Alerts" screen under Settings with real-time test preview button.
   - Added route `/settings/pending-alerts`.

5. **Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`)**:
   - Added English and Malayalam translations for all new strings and choices.

6. **Tests**:
   - Added unit tests in `test/application/pending_alert_notifier_test.dart`.
   - Added widget tests in `test/presentation/pending_todos_alert_sheet_test.dart`.
   - Updated `test/presentation/settings_screen_test.dart`.
   - Verified 609/609 tests passing and 0 static analysis issues.
