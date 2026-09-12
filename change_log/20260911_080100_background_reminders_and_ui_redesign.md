# Change Log: Background Scheduled Reminders & Modern UI Redesign

**Date:** 2026-09-11  
**Reference Plan:** `plans/20260911_075100_background_reminders_and_ui_redesign.md`

## Summary of Changes

### 1. Android Background Reminders Engine
- **`android/app/src/main/AndroidManifest.xml`**:
  - Added permissions `RECEIVE_BOOT_COMPLETED` and `SCHEDULE_EXACT_ALARM`.
  - Registered `AlarmReceiver` broadcast receiver for `in.sreerajp.todo.ACTION_PENDING_ALERT` and `android.intent.action.BOOT_COMPLETED`.
- **`android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/AlarmReceiver.kt`**:
  - Added native `BroadcastReceiver` that triggers system notifications with sound and vibration even if the app is killed or device is sleeping.
  - Automatically schedules next alarm via `AlarmManager` and restores alarms upon phone reboot.
- **`android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`**:
  - Added `scheduleAlerts` and `cancelScheduledAlerts` method call handlers to `PENDING_NOTIFICATION_CHANNEL`.
- **`lib/core/platform/pending_notification_channel.dart`**:
  - Added `scheduleAlerts(...)` and `cancelScheduledAlerts()` methods to call the native platform channel.
- **`lib/presentation/shared/widgets/pending_alert_watcher.dart`**:
  - Synchronizes background alarm schedule with Android `AlarmManager` on app startup, when app pauses/hides, and whenever pending alert settings or task payloads change.

### 2. Modern Visual Design & Look-and-Feel Overhaul
- **`lib/presentation/shared/theme/app_theme.dart`**:
  - Upgraded theme to modern Obsidian Slate dark mode (`#0B0F17` background, `#131923` surface, `#161E2C` card, `#283446` outline) and crisp porcelain light mode (`#F8FAFC` background, `#FFFFFF` cards, `#E2E8F0` outline).
  - Modernized primary accent colors (Electric Indigo `#4F46E5`, Sky `#0EA5E9`, Emerald `#10B981`, Violet `#8B5CF6`).
  - Polished semantic status colors (Emerald `#34D399` completed, Sky `#38BDF8` working, Slate `#94A3B8` pending, Rose `#F87171` dropped, Amber `#FBBF24` ported).
  - Streamlined `cardTheme` with rounded 20dp corners and subtle 1px border.
  - Modernized `navigationBarTheme` with 72dp height and clean indicator.
- **`lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`**:
  - Overhauled `_buildCardDecoration` to use clean neutral elevated surfaces instead of full-card saturated gradients.
  - Working tasks feature a prominent active primary border and glowing shadow.
  - Completed tasks feature a calm muted tone with clean line-through and emerald check indicator.
  - Harmonized tile corner radius to 18dp.
- **`lib/presentation/screens/daily_list/widgets/daily_progress_header.dart`**:
  - Added a motivating daily progress summary card at the top of the daily list displaying completion count, remaining count, percentage badge, and smooth animated progress bar.
- **`lib/presentation/screens/daily_list/daily_list_screen.dart`**:
  - Embedded `DailyProgressHeader` cleanly below the app bar.
  - Polished the AppBar date label with bold weight, letter spacing, and tactile rounded chip styling.

### 3. Tests
- **`test/presentation/app_theme_test.dart`**:
  - Updated background color assertions to match the new Obsidian Slate and porcelain palettes.
- **`test/core/pending_notification_channel_test.dart`**:
  - Added unit tests for `scheduleAlerts` and `cancelScheduledAlerts` methods.
- **`test/presentation/daily_progress_header_test.dart`**:
  - Added widget tests for empty state, active progress display, and 100% completion message.

## Verification
- `flutter analyze` completed with 0 errors and 0 warnings.
- `flutter test` ran all 667 unit and widget tests successfully.
- Code formatted with `dart format`.
