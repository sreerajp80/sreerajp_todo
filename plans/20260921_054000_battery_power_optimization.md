# Implementation Plan - Android Battery and Power Usage Optimization

**Status:** Completed

## Issue
Mobile devices rely on efficient background resource management, minimal wakeups from deep sleep (Doze mode), and timely disposal of active timers, animation controllers, and sockets. Several areas currently use more battery power than necessary:
1. `PendingAlertWatcher` keeps a 1-minute periodic timer continuously firing in the background during `AppLifecycleState.paused` and `hidden`. Every minute it queries the SQLite database (`pendingAlertPayloadProvider` and unfinished candidate checks) while the app is invisible, preventing the Dart runtime and device CPU from idling.
2. `liveTimerProvider`, `pomodoroCountdownProvider`, and `focusPulseCountdownProvider` do not use `autoDispose` and do not pause when the app is in the background. Even when screens are closed or the user leaves the app, 1-second Dart periodic streams remain active in memory. (On Android, running task notifications already use native Android chronometer widgets which update in System UI without waking the app).
3. `BreathingOrb` in the mindful ritual screen is missing a `dispose()` method, leaving both its `Timer.periodic(1 second)` and `AnimationController` running if the user navigates away before completing the session.
4. `P2pWifiSyncScreen` does not shut down its listening TCP server socket if the screen is dismissed or the app is put in the background while the host server is active.
5. `TimerLifecycleWatcher` does not explicitly release the window keep-awake flag when the app leaves the foreground, potentially keeping the screen awake unnecessarily.
6. `AlarmReceiver` uses aggressive exact alarms (`setExactAndAllowWhileIdle`) for scheduled task reminders, preventing Android from batching alarm wakeups during low-power Doze windows.

## Proposed Changes

### Application Layer

#### [MODIFY] lib/application/providers.dart
- Define `appLifecycleStateProvider` to track whether the app is in the foreground (`resumed`) or background (`paused` / `hidden`).
- Convert `pomodoroCountdownProvider` and `focusPulseCountdownProvider` to `StreamProvider.autoDispose<int>`. Watch `appLifecycleStateProvider`; when in the background, return a static stream value (`Stream.value(0)`) instead of ticking every second.
- Convert `liveTimerProvider` to `StreamProvider.autoDispose.family<int, String>`. When in the background, return a static stream value with the current elapsed duration (`Stream.value(DateTime.now().difference(startTime).inSeconds)`) instead of running a 1-second `Stream.periodic`. When resumed, it immediately emits the fresh elapsed time with zero drift.

### Presentation Layer

#### [MODIFY] lib/presentation/shared/widgets/timer_lifecycle_watcher.dart
- Update `appLifecycleStateProvider` with each lifecycle transition.
- In `_onLeftForeground()`, explicitly release the keep-awake window flag (`setKeepAwake(false)`) and reset `_keepAwakeRequested` so the screen can sleep if the app is backgrounded. Re-enable it in `_onReturnedToForeground()`.

#### [MODIFY] lib/presentation/shared/widgets/pending_alert_watcher.dart
- In `didChangeAppLifecycleState`, cancel and null out `_checkTimer` when the app is `paused` or `hidden`.
- When the app is `resumed`, re-run `_evaluateAlertConditions()` and restart `_startPeriodicTimer()`.

#### [MODIFY] lib/presentation/screens/ritual/widgets/breathing_orb.dart
- Add `dispose()` to `_BreathingOrbState` to cancel `_tick` and dispose `_controller`.

#### [MODIFY] lib/presentation/screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart
- In `dispose()`, shut down the host server if it is running.
- Add `WidgetsBindingObserver` to stop the host server when the app leaves the foreground.

### Android Host Platform

#### [MODIFY] android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/AlarmReceiver.kt
- Optimize alarm scheduling to prefer batched / inexact power-saving alarms (`setAndAllowWhileIdle`) for reminders, allowing Android to align alarms with system maintenance windows instead of forcing high-power CPU wakeups.

### Test Suite

#### [NEW] test/presentation/battery_power_optimization_test.dart
- Test that `appLifecycleStateProvider` defaults to `resumed`.
- Test that `BreathingOrb` properly disposes its timer and controller.
- Test that `PendingAlertWatcher` stops background periodic evaluation when paused.

## Verification Plan

### Automated Tests
- Run `flutter test test/presentation/battery_power_optimization_test.dart`.
- Run `flutter test` to ensure all 785+ tests pass with zero regressions.
- Run `flutter analyze` to ensure zero warnings or errors.

### Manual Verification
- Start a timer, navigate between screens, and verify timers update seamlessly without drift.
- Send app to background and return; verify live timer resumes smoothly and notification chronometer remains accurate.
- Open Ritual breathing screen and exit; verify no memory or timer leaks occur.
