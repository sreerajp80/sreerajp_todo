# Pick a date for new tasks (incl. Mastery Deck) and make "Move" really move

**Status:** completed

## Issues reported

1. **Mastery Deck: cannot pick a date for a new task.** The "Add task to deck"
   button in `mastery_deck_detail_screen.dart` always opens the create screen with
   today's date. The create screen shows the date only as a label; there is no way
   to change it. So a deck task can only start today.
2. **Moving a task leaves it on the old date.** When the user picks "Move" on a task
   and chooses another date, the task shows on the new date **and** still shows on
   the old date.
3. **Set the start date of a Mastery task.** Same need as issue 1: the user wants to
   choose the day the deck task starts, like they can on the normal daily list
   (where they open a date from the calendar and then add a task).

## Root cause

### Issue 1 and 3
- `MasteryDeckDetailScreen._onAddTodo` pushes `createTodoPath(date: todayAsIso(), ...)`.
- `CreateEditTodoScreen` keeps the date in `_effectiveDate` but only shows it as the
  subtitle of the "Details" card. It is never editable.

### Issue 2
- The "continuous multi-day tasks" feature (plan `20260920_201500`) shows a task on
  every day from `source_date` to `date`
  (`todo_dao.dart` → `findByDate`: `t.source_date <= ? AND t.date >= ?`).
- `TodoRepositoryImpl.moveTodo` always sets `sourceDate = todo.sourceDate ?? fromDate`.
  So after a move, the task's range covers the old date too, and it keeps showing there.
- This is correct for **carry-over** (pending task carried to today — carry-over sheet,
  pending alert, morning ritual). It is wrong for the explicit **"Move"** action,
  where the user wants the task to leave the old date.
- Side effect today: moving a task from today to a future date also makes it show on
  every day in between.

## Plan for the fix

### A. Explicit move (Issue 2)
1. `lib/domain/repositories/todo_repository.dart` — add an optional named parameter:
   `moveTodo(String todoId, String targetDate, {bool detach = false})`.
2. `lib/data/repositories/todo_repository_impl.dart` — when `detach` is true, set
   `sourceDate: null` so the task belongs only to the target date. The "moved"
   history event is still logged, so Task History still shows "Moved from X to Y".
   When `detach` is false, keep the current behaviour (carry-over stays continuous).
3. `lib/domain/usecases/move_todo.dart` — pass `detach` through. Add
   `detached` to `MoveTodoResult`.
4. `lib/application/daily_todo_state.dart` (`UndoEntry`) — add a `detached` flag
   (default false) so undo can move the task back the same way.
5. `lib/application/daily_todo_notifier.dart` — `moveTodo(..., {bool detach = false})`;
   store the flag in the undo entry; undo passes it back to the use case.
6. `lib/presentation/screens/daily_list/daily_list_screen.dart` —
   `_showMoveDatePicker` calls `moveTodo(todoId, targetDate, detach: true)` and also
   invalidates the old date's provider so the list refreshes at once.
   Carry-over sheet, pending alert, ritual and "port" keep `detach: false`.

Note: if the task already has **timer time recorded on the old date**, it will still
show on that old date as a history row (the query also shows any task with a time
segment on that day). This keeps past time records visible and is intended.

### B. Date picker for new tasks (Issues 1 and 3)
1. `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` —
   for a **new** task only (not editing, not read-only), show a "Date" row in the
   Details card with a calendar icon. Tapping it opens `showDatePicker`
   (first date = today, because past days are locked; last date = today + 365 days).
   On change:
   - update `_effectiveDate`,
   - re-run the title duplicate check for the new date,
   - reload the prerequisite list for that date and clear any chosen prerequisites
     (they belong to the old date),
   - recurrence start date follows `_effectiveDate` automatically.
   This works for every entry point (daily list, Mastery Deck, etc.). Editing an
   existing task does not get this row — the "Move" action is used for that.
2. `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart` — no route
   change needed; the user picks the date on the create screen. After returning,
   also invalidate the deck providers (already done via create screen) — verify the
   list refreshes; add `ref.invalidate` after `context.push` returns if needed.
3. Localization: add keys to `app_en.arb`, `app_ml.arb`, `app_sa.arb` with `@key`
   descriptions, then run `flutter gen-l10n`:
   - `taskDateLabel` — "Task date" / "ടാസ്ക് തീയതി" / "कार्यदिनाङ्कः"
   - `tooltipChangeTaskDate` — "Change task date" / "ടാസ്ക് തീയതി മാറ്റുക" / "कार्यदिनाङ्कं परिवर्तय"

### C. Tests
- `test/data/multi_day_continuous_todo_test.dart` — add a test: `moveTodo(..., detach: true)`
  → task shows on the new date only, not on the old date. Keep the existing
  carry-over test (still visible on the old date).
- `test/domain/usecases/move_todo_test.dart` — add a test that `detach` is passed
  through and returned in the result.
- `test/presentation/create_edit_todo_screen_test.dart` — add a test that the date row
  shows for a new task and not when editing.
- Update any mocks/fakes of `TodoRepository.moveTodo` that break due to the new
  named parameter.

### D. Checks
- `dart format lib/ test/`
- `flutter analyze` (0 issues)
- `flutter test`

## Files to change
- `lib/domain/repositories/todo_repository.dart`
- `lib/data/repositories/todo_repository_impl.dart`
- `lib/domain/usecases/move_todo.dart`
- `lib/application/daily_todo_state.dart`
- `lib/application/daily_todo_notifier.dart`
- `lib/presentation/screens/daily_list/daily_list_screen.dart`
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
- `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart` (only if refresh is needed)
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb` (+ generated `app_localizations*.dart`)
- `test/data/multi_day_continuous_todo_test.dart`
- `test/domain/usecases/move_todo_test.dart`
- `test/presentation/create_edit_todo_screen_test.dart`
- any test fakes implementing `TodoRepository.moveTodo`
- `change_log/<timestamp>_mastery_task_date_and_true_move.md` (after implementing)
