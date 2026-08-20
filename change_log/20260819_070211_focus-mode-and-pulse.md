# Change log — Focus mode and the focus nudge (feature 4.6)

Implements: `plans/20260819_064900_focus-mode-and-pulse.md`

## What was added

Feature 4.6 from `docs/unique_features_and_improvements.md`, in two parts.

### 1. Full-screen Focus view (`/focus/:id`)

A dark, distraction-free page for one task. It shows the elapsed time in large
type, the task title and description, a slow ambient ring, the task's step
checklist (tickable), and pause / stop controls.

- Reached by tapping the time chip on a task tile in the day list, or the new
  focus button in the Time Segments app bar (shown only while a timer runs).
- The ring fills up to the task target when the task has one; with no target it
  draws a slow moving arc instead, so the screen never looks frozen. It holds
  still when the timer is not running.
- Always dark, whatever the app theme is set to, but keeps the user's own accent
  colour and font.
- Hides the system bars while open when "Immersive full screen" is on, and puts
  them back on the way out.
- Stopping the timer takes the user back to where they came from.
- Timer actions go through the existing `TimerActions`, so the undo for a short
  segment and the "stopped another timer" message behave exactly as they do on
  the day list.
- Step ticks go through `DailyTodoNotifier.toggleSubTask`, so day-lock and every
  other repository rule still applies. A past day or a finished task is
  read-only: no controls and no tickable steps.

### 2. Haptic and audio nudge while a timer runs

An optional vibration and/or short chime every few minutes, so the user notices
time passing.

- Off by default. Modes: off, vibration only, sound only, both.
- Gap: 5 to 120 minutes in steps of 5, default 30.
- No new package. The nudge uses `HapticFeedback` and `SystemSound` from the
  Flutter engine, exactly like the existing Pomodoro alert, so the audited
  dependency list and the offline guarantee are untouched.
- Nudges are counted from the start of the running segment, so "every 30
  minutes" means 30 minutes of tracked work. The next moment is worked out from
  the clock every time, so the schedule cannot drift.
- The nudge stays quiet while Pomodoro is on, because Pomodoro already sounds
  its own alert at the end of every block.
- Known limit, shown as a note on the settings page: in-app only. Nothing sounds
  while the app is closed or in the background, and a nudge that fell due while
  the app was away is dropped rather than replayed. Tracked time is unaffected.

### 3. New settings page

`Settings -> Time tracking -> Focus mode` (`/settings/time-tracking/focus`) with
the nudge mode, the gap stepper, the immersive full-screen switch, and the
offline-limit note.

## New files

| File | Purpose |
|---|---|
| `lib/core/utils/focus_pulse_rules.dart` | `FocusPulseMode` enum, the allowed range for the gap, and the pure next-pulse helper. No Flutter imports. |
| `lib/application/focus_pulse_notifier.dart` | Owns the nudge schedule. Mode, gap, clock and the nudge itself are injected. |
| `lib/presentation/screens/focus/focus_screen.dart` | The full-screen Focus view. |
| `lib/presentation/screens/focus/widgets/focus_pulse_ring.dart` | The ambient ring animation. |
| `lib/presentation/screens/focus/widgets/focus_sub_task_list.dart` | The tickable step list. |
| `lib/presentation/screens/settings/time_tracking/focus_mode_screen.dart` | The Focus mode settings page. |
| `test/core/focus_pulse_rules_test.dart` | 8 tests for the mode flags and the next-pulse maths. |
| `test/application/focus_pulse_notifier_test.dart` | 10 tests: arming, off, quiet during Pomodoro, real firing, dropped nudges, restart on a new timer. |
| `test/presentation/focus_screen_test.dart` | 7 widget tests: content, steps, ticking through the repository, controls, past-day read-only, missing task. |

## Changed files

| File | Change |
|---|---|
| `lib/core/constants/app_routes.dart` | Added `focus`, `focusMode`, and `focusPath(id)`. |
| `lib/app.dart` | Registered the Focus route and the Focus mode settings route. |
| `lib/application/time_tracking_settings_notifier.dart` | Added `focusPulseMode`, `focusPulseIntervalMinutes` and `focusImmersive`: fields, defaults, `copyWith`, loading with range guards, and setters. |
| `lib/application/providers.dart` | Added `focusPulseProvider`, `focusPulseCountdownProvider`, and a shared `todoByIdProvider`. |
| `lib/presentation/shared/widgets/timer_lifecycle_watcher.dart` | Points the nudge at the timer that has been running longest; clears it when the app leaves the foreground and rebuilds it from the clock on return; reacts to timer activity and to the settings changing. |
| `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` | The time chip is now tappable and opens the Focus view (not in multi-select mode). |
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | Uses the shared `todoByIdProvider` (its private copy was removed) and gained the focus app-bar action while a timer runs. |
| `lib/presentation/screens/settings/time_tracking_screen.dart` | Added the Focus mode card. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | 23 new strings each, in English and Malayalam. Localisations regenerated. |
| `test/application/time_tracking_settings_notifier_test.dart` | Covers the three new settings: defaults, saving, clamping, and the fallback for a bad stored gap. |
| `docs/features.md` | New "Focus mode" section and rows for `/focus/:id` and the settings page. |
| `docs/architecture.md` | New rows for `FocusPulseNotifier`, `focus_pulse_rules.dart`, both routes, and the extra job on `TimerLifecycleWatcher`. |
| `docs/unique_features_and_improvements.md` | 4.6 marked Implemented and rewritten as "Current Implementation". |

## Checks

- `dart format lib/ test/` — clean.
- `flutter analyze` — no issues in any file touched by this change.
- `flutter test` — 492 tests, all passing (25 of them new).

## Note on unrelated pre-existing errors

`flutter analyze` reports 7 errors about `securitySettingsProvider` and
`appLockProvider` in `lib/presentation/screens/settings/security_screen.dart`
and `.../security/app_lock_screen.dart`. These files are untracked work in
progress that was already in the working tree before this change, and the
providers they use do not exist yet. They were left untouched.
