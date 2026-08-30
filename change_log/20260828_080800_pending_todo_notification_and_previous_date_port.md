# Change Log: Pending Todo Android System Notifications & Previous Date Task Porting

**Date:** 2026-08-28  
**Plan Reference:** [plans/20260828_080500_pending_todo_notification_and_previous_date_port.md](plans/20260828_080500_pending_todo_notification_and_previous_date_port.md)

---

## Summary of Changes

1. **Native Android Status Bar Notifications (`android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`, `lib/core/platform/pending_notification_channel.dart`)**:
   - Added notification channel `pending_todo_reminder_channel` and method channel `in.sreerajp.todo/pending_notification`.
   - Posts system notifications on Android when day-start or interval reminders trigger, displaying task counts and breakdown.
   - Handled Android 13+ `POST_NOTIFICATIONS` runtime permissions.

2. **Previous Date Unfinished Tasks Query (`lib/application/pending_alert_notifier.dart`, `lib/application/providers.dart`)**:
   - Implemented `PendingAlertPayload` model and `pendingAlertPayloadProvider`.
   - Queries both today's pending/working tasks and previous days' unfinished tasks (looking back up to 7 days).

3. **Interactive Port to Today Action (`lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart`)**:
   - Organized alert sheet into "Today's Tasks" and "From Previous Days".
   - Added a one-tap **"Port to Today"** button for each previous unfinished task that copies it to today using `CopyTodos` and updates state in real time.

4. **Reliable Navigator Context (`lib/app.dart`, `lib/presentation/shared/widgets/pending_alert_watcher.dart`)**:
   - Configured `rootNavigatorKey` in `GoRouter` and passed to `PendingAlertWatcher` to ensure modal alerts present seamlessly across any route.

5. **Localization & Quality**:
   - Bilingual strings in English and Malayalam for headers, port actions, and system notification content.
   - All 613 tests passing, 0 analysis warnings.
