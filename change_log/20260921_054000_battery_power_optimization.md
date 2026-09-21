# Android Battery and Power Usage Optimization

## Summary
Optimized application power usage on Android by eliminating background timer and polling leaks, introducing automatic disposal and background suspension of UI countdown streams, clearing window keep-awake flags when leaving foreground, stopping idle Wi-Fi P2P server sockets, and switching to battery-friendly batched Android alarms.

## Reference
Plan: [plans/20260921_054000_battery_power_optimization.md](plans/20260921_054000_battery_power_optimization.md)

## Changes Made

1. **Application Layer**:
   - `lib/application/providers.dart`:
     - Added `appLifecycleStateProvider` to track lifecycle transitions (`resumed`, `paused`, `hidden`).
     - Converted `pomodoroCountdownProvider` and `focusPulseCountdownProvider` to `StreamProvider.autoDispose<int>`, suspending 1-second ticks while the app is in the background.
     - Converted `liveTimerProvider` to `StreamProvider.autoDispose.family<int, String>`, immediately yielding the current elapsed time on subscription and suspending 1-second ticks while the app is in the background.

2. **Presentation Layer**:
   - `lib/presentation/shared/widgets/timer_lifecycle_watcher.dart`:
     - Synchronized `appLifecycleStateProvider` with `didChangeAppLifecycleState`.
     - Explicitly released `FLAG_KEEP_SCREEN_ON` via `ScreenWakeChannel` in `_onLeftForeground()` to allow device screen sleep when backgrounded, restoring it upon returning.
   - `lib/presentation/shared/widgets/pending_alert_watcher.dart`:
     - Cancelled and nulled the 1-minute `_checkTimer` on `paused` / `hidden` states, halting background SQLite polling while invisible.
     - Restarted periodic evaluations when entering `resumed`.
   - `lib/presentation/screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart`:
     - Added `WidgetsBindingObserver` to shut down the host TCP server socket when the screen is dismissed or the app is sent to the background.

3. **Android Host Platform**:
   - `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/AlarmReceiver.kt`:
     - Optimized scheduled reminder alarms to use `setAndAllowWhileIdle`, allowing Android OS to batch reminders during maintenance windows without aggressive deep-sleep hardware interrupts.

4. **Test Suite**:
   - `test/presentation/battery_power_optimization_test.dart`:
     - Added tests verifying `appLifecycleStateProvider` defaults to `resumed`.
     - Verified `liveTimerProvider`, `pomodoroCountdownProvider`, and `focusPulseCountdownProvider` suspend active ticking when paused or hidden.
     - Verified `BreathingOrb` disposes cleanly without ticker or timer leaks.
     - Verified `PendingAlertWatcher` safely transitions between foreground and background lifecycle states.

## Verification
- `flutter test test/presentation/battery_power_optimization_test.dart`: All 6 tests passed.
- `flutter test`: All 791 unit, widget, and DAO tests passed.
- `flutter analyze`: 0 issues found.
- `dart format`: All Dart files formatted.
