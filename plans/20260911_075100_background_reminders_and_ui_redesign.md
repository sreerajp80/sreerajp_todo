# Plan: Background Scheduled Reminders & Modern UI Redesign

**Status:** Proposed

## Overview
This plan addresses two critical user concerns:
1. **Reminders only appear when the app is open:** Replace foreground-only timers with Android native `AlarmManager` and `BroadcastReceiver`, so notifications fire even when the app is killed or the phone is locked.
2. **Visual design is not appealing:** Redesign the app with modern, sleek dark and light palettes (inspired by Linear / Things 3), clean neutral task cards, refined completion states, and an animated daily progress header.

---

## Files to Change

### 1. Background Reminders
- `android/app/src/main/AndroidManifest.xml` (add `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, register `AlarmReceiver`)
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/AlarmReceiver.kt` (new native receiver for alarms and device reboot)
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` (add `scheduleAlerts` and `cancelScheduledAlerts` to `PENDING_NOTIFICATION_CHANNEL`)
- `lib/core/platform/pending_notification_channel.dart` (add scheduling calls to Dart channel)
- `lib/presentation/shared/widgets/pending_alert_watcher.dart` (sync alarm schedule on settings changes and task updates)

### 2. Visual Design & Modern Look
- `lib/presentation/shared/theme/app_theme.dart` (modern dark obsidian/slate and crisp light palettes, refined typography and status colors)
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` (clean neutral card surfaces, active glowing borders for working tasks, elegant muted completed tasks)
- `lib/presentation/screens/daily_list/widgets/daily_progress_header.dart` (new animated daily task completion bar/card)
- `lib/presentation/screens/daily_list/daily_list_screen.dart` (integrate daily progress header and refine header date navigation)

---

## Verification Plan
- Run `flutter analyze` (must be 0 errors, 0 warnings).
- Run `flutter test` (all tests passing).
- Manual verification of background alarm triggers and light/dark theme styling.
