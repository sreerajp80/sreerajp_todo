# Running Todo Ongoing Notification System

**Date:** 2026-08-27
**Plan reference:** [plans/20260827_220500_running_todo_notification.md](plans/20260827_220500_running_todo_notification.md)

---

## 1. Summary of Changes

Implemented an ongoing Android status bar and drawer notification with a live ticking chronometer for running tasks. When a task's timer is started in the app, Android displays an ongoing notification showing the task title and a live counting stopwatch powered directly by the operating system's native chronometer.

---

## 2. Key Architecture Details

1. **100% Offline Operational Guarantee:**
   - No external push or notification packages were added.
   - Built through a dedicated native platform channel (`in.sreerajp.todo/running_notification`) implemented in `MainActivity.kt`.
2. **Zero Battery Overhead:**
   - Uses Android OS `NotificationCompat.Builder.setUsesChronometer(true)` with `setWhen(startTimeMillis)` and `setOngoing(true)` on notification channel `running_todo_timer_channel` (`IMPORTANCE_LOW`).
   - The Android system service handles the ticking stopwatch rendering directly in the notification shade without waking Flutter or draining battery.
3. **Lifecycle Synchronization:**
   - `TimerLifecycleWatcher` automatically listens to timer activity ticks and time tracking settings.
   - Shows or updates the ongoing notification on timer start/resume.
   - Dismisses the notification on timer stop, pause, auto-stop, or task completion.
4. **User Preference & Localization:**
   - Added `showRunningNotification` setting in `TimeTrackingSettings` (enabled by default).
   - Configurable via a toggle in **Settings → Time tracking → Timer behaviour**.
   - Fully localized in English and Malayalam (`app_en.arb` and `app_ml.arb`).

---

## 3. Files Modified and Added

- `android/app/src/main/AndroidManifest.xml`: Added `android.permission.POST_NOTIFICATIONS`.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`: Added `in.sreerajp.todo/running_notification` platform method channel handler, notification channel setup, chronometer builder, and permission handler.
- `lib/core/platform/running_notification_channel.dart` (NEW): Platform channel abstraction for showing/hiding notifications and checking permissions.
- `lib/application/time_tracking_settings_notifier.dart`: Added `showRunningNotification` preference, default `true`, and persistence to `SharedPreferences`.
- `lib/application/providers.dart`: Added `runningNotificationChannelProvider`.
- `lib/presentation/shared/widgets/timer_lifecycle_watcher.dart`: Integrated `_syncRunningNotification()` on lifecycle and timer state changes.
- `lib/presentation/screens/settings/time_tracking/timer_behaviour_screen.dart`: Added toggle for `showRunningNotification`.
- `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`: Added localized strings for running task notification settings.
- `docs/dependencies.md`: Documented `in.sreerajp.todo/running_notification` in the native platform channel inventory table.
- `test/application/time_tracking_settings_notifier_test.dart`: Updated unit tests for `showRunningNotification`.
- `test/core/running_notification_channel_test.dart` (NEW): Added unit tests for `RunningNotificationChannel`.

---

## 4. Verification

- `flutter test`: 611 unit and widget tests passing (including new channel and settings tests).
- `flutter analyze`: 0 warnings, 0 errors.
- `flutter build apk --flavor dev`: Built successfully with exit code 0.
