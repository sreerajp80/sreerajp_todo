# 4.6 Timer Engine Audio & Visual Enhancements (Focus Mode + Haptic/Audio Pulse)

**Status:** completed

## What is being built

Feature 4.6 from `docs/unique_features_and_improvements.md`. Two parts:

1. **Full-Screen Focus Mode** — tapping the running timer chip on a task opens a
   full-screen, dark, distraction-free view for that one task: big elapsed time,
   task title and description, its sub-task checklist (tickable), a slow ambient
   progress animation, and pause/stop controls.
2. **Procedural Haptic & Audio Pulse** — while a timer runs, the app can give a
   soft vibration and/or a short system chime every N minutes (user picks the
   gap) so the user notices time passing.

## The issue / why

Right now a running timer is only a small chip in the day list. There is no
focused work view, and nothing tells the user that time is passing while they
work. Sections 4.1 - 4.5 of the same document are done; 4.6 is still only a
proposal.

## Key decisions

- **No new packages.** The pulse uses `SystemSound.play(SystemSoundType.alert)`
  and `HapticFeedback` from `flutter/services`, exactly like the existing
  Pomodoro alert in `lib/application/pomodoro_notifier.dart`. This keeps the
  offline guarantee and the approved-package list untouched. "Procedural" in the
  doc means "generated, not a bundled sound file" - the platform system sound
  meets that with zero new dependencies.
- **Foreground only.** The app sends no notifications, so a pulse can only fire
  while the app is open. This is the same known limit already written on the
  Pomodoro settings page, and it will be shown as a note on the new settings
  page too.
- **Pulses are anchored to the running segment's start time**, so "every 30
  minutes" means 30 minutes of tracked work, not 30 minutes of app uptime. When
  the app comes back to the foreground, the schedule is recomputed from the
  clock, so it never drifts.
- **No double alerts.** When Pomodoro is switched on, the pulse stays quiet;
  Pomodoro already makes its own sound at block ends.
- **Layering.** The pulse engine lives in `lib/application/` with its callbacks
  injected, so it is testable with a fake clock and no platform channel. The
  Focus screen lives in `lib/presentation/screens/focus/` and only talks to
  Riverpod providers, never to DAOs.

## New settings (saved in SharedPreferences)

| Setting | Key | Default |
|---|---|---|
| Pulse mode: off / vibration / sound / both | `tracking_focus_pulse_mode` | off |
| Pulse gap in minutes (5 - 120, step 5) | `tracking_focus_pulse_interval` | 30 |
| Immersive full screen (hide status bar in Focus view) | `tracking_focus_immersive` | true |

## Files to change

### New files

| File | Purpose |
|---|---|
| `lib/core/utils/focus_pulse_rules.dart` | `FocusPulseMode` enum + pure helper that returns the next pulse instant after a given moment. Pure Dart, easy to unit test. |
| `lib/application/focus_pulse_notifier.dart` | Schedules the pulse while a timer runs. Takes mode, interval, "is Pomodoro on", and the alert callback as injected functions. |
| `lib/presentation/screens/focus/focus_screen.dart` | The full-screen Focus view. |
| `lib/presentation/screens/focus/widgets/focus_pulse_ring.dart` | Ambient breathing / progress ring animation. |
| `lib/presentation/screens/focus/widgets/focus_sub_task_list.dart` | Tickable sub-task checklist for the Focus view. |
| `lib/presentation/screens/settings/time_tracking/focus_mode_screen.dart` | Settings -> Time tracking -> Focus mode. |
| `test/core/focus_pulse_rules_test.dart` | Tests for the next-pulse maths. |
| `test/application/focus_pulse_notifier_test.dart` | Tests: fires on time, silent when off, silent during Pomodoro, stops when the timer stops. |
| `test/presentation/focus_screen_test.dart` | Widget test: shows title and elapsed time, ticks a sub-task, leaves when the timer stops. |

### Changed files

| File | Change |
|---|---|
| `lib/core/constants/app_routes.dart` | Add `focus = '/focus/:id'` and `focusPath(String id)`. |
| `lib/app.dart` | Register the Focus route and the new settings route. |
| `lib/application/time_tracking_settings_notifier.dart` | Add the three settings above: fields, defaults, `copyWith`, load, and setters. |
| `lib/application/providers.dart` | Add `focusPulseProvider`, and a shared `todoByIdProvider` (moved out of `time_segments_screen.dart` so the Focus screen can reuse it). |
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | Use the shared `todoByIdProvider`; add a "Focus" action in the app bar when a timer is running. |
| `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` | Make the running timer chip tappable -> pushes the Focus route. |
| `lib/presentation/shared/widgets/timer_lifecycle_watcher.dart` | Drive the pulse engine: start/stop it on timer activity, settings change, and app foreground/background. |
| `lib/presentation/screens/settings/time_tracking_screen.dart` | Add the "Focus mode" nav card. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | New user strings (Focus view labels, settings labels, the foreground-only note). Then regenerate `lib/l10n/app_localizations*.dart`. |
| `test/application/time_tracking_settings_notifier_test.dart` | Cover the three new settings. |
| `docs/features.md`, `docs/architecture.md` | Document the Focus view, its route, and the pulse engine. |
| `docs/unique_features_and_improvements.md` | Mark 4.6 as Implemented and rewrite it as "Current Implementation", matching 4.1 - 4.5. |

## Plan for the work

1. Add `FocusPulseMode` and the next-pulse helper in `core/`, with tests.
2. Add the three settings to `TimeTrackingSettingsNotifier`, with tests.
3. Build `FocusPulseNotifier` with injected clock and alert, with tests.
4. Wire the engine into `TimerLifecycleWatcher` (foreground only, off during
   Pomodoro).
5. Add the route, the shared `todoByIdProvider`, and build the Focus screen:
   dark theme override, large `HH:MM:SS` from `duration_utils.dart`, title,
   description, sub-tasks, ambient ring, pause/stop through the existing
   `TimerActions` so the undo and "stopped another timer" behaviour stays the
   same. Leave the screen automatically when the timer is no longer running.
6. Make the timer chip on the tile open the Focus view, and add the app-bar
   action on the Time Segments screen.
7. Add the settings page and its nav card.
8. Add all strings to both `.arb` files and regenerate localisations.
9. Update the three docs.
10. Run `dart format`, `flutter analyze` (must be 0 issues), and `flutter test`.
11. Write the change log in `change_log/`.

## Rules kept

- No network, no new dependency, no new Android permission.
- No DAO calls from widgets; the Focus screen uses providers only.
- Sub-task ticks go through `dailyTodoProvider(...).notifier.toggleSubTask`, so
  day-lock and the repository rules still apply.
- Terminal / past-day tasks: the Focus view shows time read-only and hides the
  pause/stop controls, the same as the tile does today.
- All user strings go in the `.arb` files, matching how 4.5 was done.

## Not included

- Background pulses or notifications (the app has no notification support and
  stays fully offline).
- Custom sound files or a synthesised tone engine (would need a new package;
  the system alert sound is used instead).
