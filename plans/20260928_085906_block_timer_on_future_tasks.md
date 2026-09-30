# Stop future tasks from showing on today (timer on a future task)

**Status:** completed

## What the user saw

On 2026-09-28 the list shows two "Meditation" rows. The second one says
"copied from 2026-09-30", is "In progress" and has a running timer. Also every
normal task says "copied from 2026-09-28" (its own date), which makes no sense.

## Root cause

1. **A timer can be started on a future task.** `StartTimeSegment` and
   `TimeSegmentRepositoryImpl.startSegment` only block past dates
   (`isPastDate`). They do not block future dates. The "Meditation" task that
   belongs to 2026-09-30 got a timer started today.
2. **Any task with time recorded today shows on today.** `TodoDao.findByDate`
   includes every task that has a time segment starting on that day
   (`OR ts.id IS NOT NULL`). This is meant for history rows, but combined with
   point 1 it pulls the 2026-09-30 task into today's list.
3. **Wrong "copied from" label.** `findByDate` fills `sourceDate` with the task's
   own stored date when it is empty (`entity.sourceDate ?? dbDate`). The list tile
   shows "copied from X" whenever `sourceDate` is not null. So every task shows
   "copied from <its own date>", and the future task shows "copied from 2026-09-30".

## Plan for the fix

### A. Block timers on future tasks (all entry points)
- `lib/core/errors/exceptions.dart` — add `FutureDayTimerException`.
- `lib/domain/usecases/start_time_segment.dart` — throw it when `isFutureDate(todo.date)`.
- `lib/data/repositories/time_segment_repository_impl.dart` — same check in
  `startSegment` (defence in depth).
- `lib/application/daily_todo_notifier.dart` (and any other notifier that starts a
  timer) — catch it and show a localized message.
- `lib/presentation/shared/widgets/timer_controls.dart` /
  `todo_list_tile.dart` / `focus_screen.dart` — hide or disable the start button
  when the task's date is in the future.
- Localization: new key `errorTimerFutureTask` ("You can start the timer only on
  the task's own day") in `app_en.arb`, `app_ml.arb`, `app_sa.arb` with `@key`
  descriptions; run `flutter gen-l10n`.

### B. Fix the "copied from" label
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` — show
  "copied from X" only when `sourceDate` is **before** the shown date. The DAO
  fallback stays, because delete/move logic uses it.

### C. Existing bad data on the device
No automatic data change. The user can: stop the timer on the 2026-09-30
Meditation, open its time records and delete that record (and add the time to
today's Meditation as manual time if wanted). After that it leaves today's list.

### D. Tests
- `test/domain/usecases/start_time_segment_test.dart` — future task throws.
- time segment repository test — future task throws.
- `test/presentation/todo_list_tile_test.dart` — no "copied from" label when
  `sourceDate` equals the shown date; start button hidden for a future task.

### E. Checks
`dart format lib/ test/`, `flutter analyze` (0 issues), `flutter test`.

## Files to change
- `lib/core/errors/exceptions.dart`
- `lib/domain/usecases/start_time_segment.dart`
- `lib/data/repositories/time_segment_repository_impl.dart`
- `lib/application/daily_todo_notifier.dart` (+ other timer-start callers found)
- `lib/presentation/shared/widgets/timer_controls.dart`
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`
- `lib/presentation/screens/focus/focus_screen.dart`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ generated files)
- tests listed in D
- `change_log/<timestamp>_block_timer_on_future_tasks.md` (after implementing)
