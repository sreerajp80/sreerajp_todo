# Running Todo Ongoing Notification System

**Status:** Proposed — awaiting user approval before implementation

---

## 1. Problem Statement & User Request

The user requested: *"todo app running todo in notification"*.
Currently, when a time tracking timer is started for a todo, there is no ongoing status bar / drawer notification on Android. When the user switches to other apps or locks their device (with `autoPauseOnBackground` disabled or while working), they cannot see the currently running task, elapsed duration, or easily jump back into the app from the notification tray.

---

## 2. Proposed Architecture & Offline Guarantees

In accordance with `AGENTS.md` and `docs/dependencies.md`:
1. **100% Offline Operational Guarantee:** No external notification packages or cloud push notification SDKs are added. Zero network calls or network permissions.
2. **Native Platform Channel:** Implemented via a lightweight native method channel (`in.sreerajp.todo/running_notification`) in `MainActivity.kt` using standard Android `NotificationManager` and `NotificationCompat.Builder`.
3. **Android Native Chronometer Stopwatch:** Uses Android's built-in `NotificationCompat.Builder.setUsesChronometer(true)` with `setWhen(startTimeMillis)` and `setOngoing(true)`. This allows the Android operating system to render the ticking stopwatch in the notification drawer dynamically without waking the CPU, draining battery, or running heavy background Flutter code.
4. **Clean 5-Layer Separation:**
   - **Core Layer:** Pure channel abstraction `RunningNotificationChannel` in `lib/core/platform/running_notification_channel.dart` with safe no-op on non-Android platforms.
   - **Application Layer:** Preferences in `TimeTrackingSettings` (`showRunningNotification`, default `true`), managed by `TimeTrackingSettingsNotifier`. Platform provider in `lib/application/providers.dart`.
   - **Presentation Layer:** Auto-synced in `TimerLifecycleWatcher` on timer start, stop, pause, auto-stop, and resume events. Settings toggle in `TimerBehaviourScreen`.
   - **Android Host:** `MainActivity.kt` handles notification channel creation (`running_todo_channel`, low importance to avoid sound interruptions), showing ongoing chronometer notification with pending intent to open the app, and canceling on timer stop. `AndroidManifest.xml` declares `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />`.

---

## 3. Files to Create & Modify

### Android Host
- `android/app/src/main/AndroidManifest.xml`
  - Add `POST_NOTIFICATIONS` permission.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`
  - Add `RUNNING_NOTIFICATION_CHANNEL` method channel (`in.sreerajp.todo/running_notification`).
  - Create notification channel with `IMPORTANCE_LOW`.
  - Handle `show(todoId, title, startTimeMillis)`, `hide()`, and permission checking/requesting.

### Core & Platform Layer
- `lib/core/platform/running_notification_channel.dart` [NEW]
  - Native platform channel bridge for showing/hiding running task notification.
- `lib/core/utils/time_tracking_rules.dart`
  - Add settings field default definitions if needed.

### Application Layer
- `lib/application/time_tracking_settings_notifier.dart`
  - Add `showRunningNotification` property (default `true`) and `setShowRunningNotification(bool)` method with `SharedPreferences` persistence.
- `lib/application/providers.dart`
  - Provide `runningNotificationChannelProvider`.

### Presentation Layer
- `lib/presentation/shared/widgets/timer_lifecycle_watcher.dart`
  - Listen for timer activity and sync running todo notification state with native channel.
- `lib/presentation/screens/settings/time_tracking/timer_behaviour_screen.dart`
  - Add toggle for "Show running task notification" with subtitle explaining ongoing drawer notification.
- `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`
  - Add localized strings:
    - `trackingRunningNotification`: "Running task notification" / "പ്രവർത്തിക്കുന്ന ടാസ്ക് അറിയിപ്പ്"
    - `trackingRunningNotificationDetail`: "Show an ongoing notification with a live timer while tracking time" / "സമയം ട്രാക്ക് ചെയ്യുമ്പോൾ ലൈവ് ടൈമറുമായി അറിയിപ്പ് കാണിക്കുക"

### Documentation
- `docs/dependencies.md`
  - Document `in.sreerajp.todo/running_notification` in the native platform channel table.
- `docs/features.md` & `docs/unique_features_and_improvements.md`
  - Document the Running Task Ongoing Notification engine.

---

## 4. Verification Plan

1. Run `flutter analyze` to ensure 0 lint errors/warnings.
2. Run `flutter test` to ensure all tests pass.
3. Test settings toggle in Settings -> Time Tracking -> Timer Behaviour.
4. Verify Android native compilation with `flutter build apk --flavor dev`.
