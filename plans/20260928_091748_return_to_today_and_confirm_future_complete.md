# Return to today on a new day, and confirm before finishing a future task

**Status:** completed

## What happened

Checked on the phone through the app's Task History screens:

- Sep 27, 9:12 PM — a repeating "Meditation" was created for Sep 28. The repeat
  rule also made copies for Sep 29, Sep 30 and later days.
- Sep 27, 9:56 PM — "Learn the second Name" was moved from Sep 27 to Sep 30.
- Sep 28, 4:19 AM — a timer started on the **Sep 30** Meditation copy.
- Sep 28, 4:48 AM — that timer stopped (29:25) and the **Sep 30** copy was
  marked completed. Today's Meditation was never touched.

The day list was most likely still showing Sep 30 when the app was reopened.
Both days have a "Meditation" row, so the wrong one was used.

The timer part is already fixed (plan `20260928_085906_block_timer_on_future_tasks`).
Two gaps remain.

## Issue 1 — the app stays on an old day after the date changes

- Opening the app from the background keeps whatever day the list was on.
- Nothing brings the user back to today when a new day has begun. Only a cold
  start goes to today (`/` redirects to today in `lib/app.dart`).
- After a "Move", the list stays on the current day, but the user may have
  opened the target day to check it and left the app there.

## Issue 2 — Complete and Drop work on a future task with no warning

- `MarkTodoCompleted` and `markDropped` accept a task of any future day.
- Finishing a task early can be valid, so we will **ask first** rather than block.

## Plan for the fix

### A. Return to today when a new day has begun (Issue 1)
1. New widget `lib/presentation/shared/widgets/day_rollover_watcher.dart`
   (Presentation layer, like `TimerLifecycleWatcher`). It remembers today's
   date (`todayAsIso()`) when the app goes to the background.
2. When the app comes back and the date has changed since then:
   - if the screen on top is a day list (route `/day/:date`) for a day that is
     not today, go to today's list with `router.go(AppRoutes.dailyListPath(today))`;
   - show a short message: "New day — showing today's tasks".
   - Other screens (edit form, settings, etc.) are left alone, so no unsaved
     work is lost.
3. Wire it in `lib/app.dart` next to `TimerLifecycleWatcher`.
4. If the date has not changed, nothing happens, so looking at a future day on
   purpose still works during the same day.

### B. Ask before completing or dropping a future task (Issue 2)
1. `lib/presentation/screens/daily_list/daily_list_screen.dart` — in `onComplete`
   and `onDrop`, if the task starts on a later day
   (`startsInFuture(todo.date, todo.sourceDate)`), show the existing
   `showConfirmDialog`: "This task is for Wed, Sep 30. Mark it done now?"
   (and a matching text for drop). Only continue on "Yes".
2. Tasks of today and carried-over tasks are not affected.

### C. Localization
New keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb` with `@key` descriptions,
then `flutter gen-l10n`:
- `newDayShowingToday` — "New day — showing today's tasks"
- `confirmCompleteFutureTitle` — "Task for a later day"
- `confirmCompleteFutureBody(date)` — "This task is for {date}. Mark it done now?"
- `confirmDropFutureBody(date)` — "This task is for {date}. Drop it now?"

### D. Tests
- `test/presentation/day_rollover_watcher_test.dart` — with a fake clock/date
  source: resume on a new day on a future day list → goes to today; resume on
  the same day → stays; resume on a new day on a non-list screen → stays.
  (The watcher takes an injectable "today" function so tests can change the day.)
- Daily list widget test — tapping Complete on a future task shows the dialog;
  "Cancel" leaves it pending; "Yes" completes it. A today task completes with
  no dialog.

### E. Checks
`dart format lib/ test/`, `flutter analyze` (0 issues), `flutter test`.

## Files to change
- `lib/presentation/shared/widgets/day_rollover_watcher.dart` (new)
- `lib/app.dart`
- `lib/presentation/screens/daily_list/daily_list_screen.dart`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ generated files)
- `test/presentation/day_rollover_watcher_test.dart` (new)
- a daily list widget test file (existing or new)
- `change_log/<timestamp>_return_to_today_and_confirm_future_complete.md`

## Not in this plan
No change to the data on the phone. The user will move the 29:25 minutes by hand
(see the reply), or ask Claude to do those steps on the phone.
