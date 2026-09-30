# Change log: return to today on a new day, confirm before finishing a future task

Implements plan: `plans/20260928_091748_return_to_today_and_confirm_future_complete.md`

## Why
A day list left open on a future day overnight was still showing that day the
next morning. The user started and completed the future copy of a repeating task
instead of today's copy.

## What changed

### Return to today on a new day
- New `lib/presentation/shared/widgets/day_rollover_watcher.dart`. It notes the
  date when the app leaves the foreground. When the app comes back on a new day
  and the top screen is a day list for another day, it goes to today's list and
  shows "New day — showing today's tasks".
- Pushed screens (edit form, time records, etc.) are never moved, so unsaved
  work is safe. On the same day nothing happens.
- The day is noted only once per trip away, because Android passes through
  `hidden` again on the way back. A test caught this.
- `lib/app.dart`: the watcher is wired in next to `TimerLifecycleWatcher`.

### Ask before finishing a future task
- `lib/presentation/screens/daily_list/daily_list_screen.dart`: Complete and Drop
  on a task that starts on a later day always ask first
  ("This task is for <date>. Mark it done now?"), even when the normal
  confirmation setting is off. Today's and carried-over tasks are unchanged.

### Localization
- New keys `newDayShowingToday`, `confirmFutureTaskTitle`,
  `confirmCompleteFutureBody`, `confirmDropFutureBody` in English, Malayalam and
  Sanskrit, with descriptions. `flutter gen-l10n` run.

### Tests
- New `test/presentation/day_rollover_watcher_test.dart`: decision rules, plus
  widget tests for new day, same day and pushed screen.
- `test/presentation/undo_snackbar_test.dart`: future-day Complete asks (cancel
  keeps it, confirm completes), future-day Drop asks, today's task does not ask.

## Data
No data changed by this work. The user fixed the misplaced time record by hand.

## Checks
- `flutter analyze`: no issues.
- `flutter test`: all 815 tests passed.
