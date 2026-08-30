# Pending Todo System Notification & Previous Date Task Porting

**Status:** Implemented

## Problem
1. Reminders were not showing system notifications on the Android device, and the in-app bottom sheet needed a solid Navigator context to present across the app.
2. The user needs the alert to also find and show pending/unfinished tasks from previous dates (e.g. yesterday) and provide a one-tap action to port them to today.

## Proposed Fix
1. **Android Native Notification Channel (`android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`)**:
   - Add notification channel `pending_todo_reminder_channel` and method channel `in.sreerajp.todo/pending_notification`.
   - Post Android status bar notifications showing pending task counts and titles.
   - Request `POST_NOTIFICATIONS` permission when enabled.

2. **Platform Channel (`lib/core/platform/pending_notification_channel.dart`)**:
   - Expose `showPendingReminder(title, body, count)` and permission checks.

3. **Pending Tasks & Previous Date Query (`lib/application/pending_alert_notifier.dart`, `lib/application/providers.dart`)**:
   - Fetch today's pending/working tasks as well as previous days' unfinished tasks.
   - Include `portToToday` action leveraging `CopyTodos`.

4. **Alert Watcher & Navigator Key (`lib/presentation/shared/widgets/pending_alert_watcher.dart`, `lib/app.dart`)**:
   - Uses `rootNavigatorKey` to present `PendingTodosAlertSheet` over any current screen.
   - Posts system notification whenever day-start or interval triggers.

5. **Alert Sheet UI (`lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart`)**:
   - Displays two clear sections: "Today's Tasks" (with Start Timer) and "From Previous Days" (with one-tap "Port to Today" button).

6. **Localization**:
   - English and Malayalam strings for today/previous sections and port action.

## Files to Modify / Create
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` (Modify)
- `lib/core/platform/pending_notification_channel.dart` (New)
- `lib/application/pending_alert_notifier.dart` (Modify)
- `lib/application/providers.dart` (Modify)
- `lib/presentation/shared/widgets/pending_alert_watcher.dart` (Modify)
- `lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart` (Modify)
- `lib/app.dart` (Modify)
- `lib/l10n/app_en.arb` (Modify)
- `lib/l10n/app_ml.arb` (Modify)
- `test/application/pending_alert_notifier_test.dart` (Modify)
- `test/presentation/pending_todos_alert_sheet_test.dart` (Modify)

## Verification
- Run `flutter test`
- Run `flutter analyze`
