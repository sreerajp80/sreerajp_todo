# Change log: block timers on future tasks, fix "copied from" label

Implements plan: `plans/20260928_085906_block_timer_on_future_tasks.md`

## Why
A task dated two days ahead showed on today's list with a running timer and the
label "copied from <its own future date>". The app let a timer start on a future
task, and any task with time recorded today shows on today. Also, every task
showed "copied from <its own date>".

## What changed

### Timers cannot start on a task that starts on a later day
- `lib/core/errors/exceptions.dart`: new `FutureDayTimerException`.
- `lib/core/utils/date_utils.dart`: new `startsInFuture(date, sourceDate)`. A
  multi-day task counts from its start day, so a task carried from today to a
  later day can still be timed today.
- `lib/domain/usecases/start_time_segment.dart` and
  `lib/data/repositories/time_segment_repository_impl.dart`: refuse to start a
  timer when the task starts in the future.
- `lib/application/time_tracking_notifier.dart`: `StartTimerResult.futureDay` flag.
- `lib/presentation/shared/widgets/timer_controls.dart`: shows a message when a
  start is refused for this reason.
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`,
  `lib/presentation/screens/focus/focus_screen.dart`,
  `lib/presentation/screens/time_segments/time_segments_screen.dart`: the start
  button is hidden for such tasks (Focus and Time Segments show the message
  instead). A timer that is already running can still be stopped.

### "Copied from" label
- `todo_list_tile.dart`: the label shows only when the start day is really
  earlier than the day being shown.

### Localization
- New key `errorTimerFutureTask` in English, Malayalam and Sanskrit, with
  description. `flutter gen-l10n` run.

### Tests
- `test/domain/usecases/start_time_segment_test.dart`: future task refused by the
  use case and by the repository; multi-day task that started today is allowed.
- `test/presentation/todo_list_tile_test.dart`: start button hidden for a future
  task; no label for same-day source; label shown for an earlier start day.

## Existing data
No data was changed. A timer already running on a future task can be stopped,
and its time record can be deleted from the Time Segments screen.

## Checks
- `flutter analyze`: no issues.
- `flutter test`: all 804 tests passed.
