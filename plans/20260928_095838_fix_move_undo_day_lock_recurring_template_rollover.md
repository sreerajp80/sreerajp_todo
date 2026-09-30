# Fix move undo, move day-lock, recurring template, and midnight rollover

**Status:** completed

This plan fixes four issues found in a review of the current work. Each one can be
done and tested on its own.

---

## Issue 1 — Undoing a move does not restore the task's start date

### What is wrong

Undo of a move just runs the move again in the other direction
(`DailyTodoNotifier.undoLastStatusChange`). It never restores the old
`sourceDate` (the day a multi-day task started).

- **Explicit move (`detach: true`).** A multi-day task runs Mon → Wed
  (`sourceDate` = Mon, `date` = Wed). The user moves it to Fri. `sourceDate`
  becomes `null`. Undo moves it back to Wed, but `sourceDate` stays `null`, so the
  task no longer shows on Mon and Tue.
- **Carry-over (`detach: false`).** A one-day task on Mon (`sourceDate` = `null`)
  is carried over to Tue, so `sourceDate` becomes Mon. Undo moves it back to Mon,
  but `sourceDate` stays Mon instead of going back to `null`.
- Undoing a carry-over also records an extra "moved" history event.

### Fix

1. `MoveTodoResult` gains `previousSourceDate` (the `sourceDate` before the move).
   `MoveTodo` reads it from the todo it already loads.
2. `UndoEntry` gains `String? previousSourceDate` and `@Default(false) bool isMove`.
   `detached` is no longer needed for undo, so it is removed. `isMove` is needed
   because `previousSourceDate` can be `null`, and a `null` alone cannot tell
   "this was a move" apart from "this was not a move".
3. New repository method `TodoRepository.restoreMove(todoId, originalDate,
   originalSourceDate)`. It puts `date` and `sourceDate` back exactly and keeps the
   duplicate-title check. It does not add a new "moved" history event. It logs an
   "undo move" event instead, if the history types allow it; otherwise it logs
   nothing.
4. `undoLastStatusChange` calls a small new use case, `UndoMoveTodo`, for move
   entries. The use case stops any running timer and then calls `restoreMove`, so
   the notifier keeps going through a use case, as the rules require.

---

## Issue 2 — The repository does not block moving a task to a past date

### What is wrong

Hard rule 3 says every repository change must enforce the day lock.
`MoveTodo` and `TodoRepositoryImpl.moveTodo` never check it. Only the date picker
in the daily list (`firstDate: today`) stops a move to a past day.

Moving a task *from* a past day is correct: carry-over does it on purpose.

### Fix

1. `MoveTodo.call` and `TodoRepositoryImpl.moveTodo` throw `DayLockedException`
   when `targetDate` is before today.
2. Undo still has to put a carried-over task back on its past day. That path goes
   through the new `restoreMove` from Issue 1, which is allowed only for undo.
   The general `moveTodo` stays locked.
3. `DailyTodoNotifier.moveTodo` already passes errors back to the screen, so no UI
   change is needed. The screens only offer today or later anyway.

---

## Issue 3 — A "this one only" edit leaks into future repeats

### What is wrong

`GenerateRecurringTasks` copies priority, target time and sub-tasks from the
**latest existing occurrence**. If the user edited only that occurrence ("this
instance only"), every occurrence created later copies that one-off change.

The rule itself stores only title and description, so there is nowhere else to
read the series values from.

### Fix

Store the series values on the rule, next to title and description.

1. **Database migration v12** (`migration_v12.dart`). Add three nullable columns
   to `recurrence_rules`, each only when missing, so re-running is safe:
   - `priority TEXT`
   - `target_seconds INTEGER`
   - `sub_task_titles TEXT` (a JSON list of sub-task titles, NFC-normalized)

   Bump `kDatabaseVersion` to 12, register it in `migration_runner.dart`, and add
   the columns to the fresh-install schema.
2. `RecurrenceRuleEntity` gains `priority`, `targetSeconds` and `subTaskTitles`.
   `fromMap` reads them as optional, so older backups, hand-offs and sync payloads
   still load.
3. The rule gets these values:
   - when a repeating task is **created** (`create_edit_todo_screen.dart`);
   - when the user edits **"this and future"** or **"all"**
     (`UpdateRecurringTodos`).

   A **"this instance only"** edit does not touch the rule.
4. `GenerateRecurringTasks` reads these values from the rule. When a rule has none
   (older rules made before v12), it falls back to today's behaviour: copy the
   latest occurrence.

The priority/target-time copying added earlier today stays; only where the values
come from changes.

---

## Issue 4 — The day list does not move to the new day if the app stays open overnight

### What is wrong

`DayRolloverWatcher` only checks the date when the app comes back from the
background. On Windows the app is often left open all night and never goes to the
background, so in the morning it still shows yesterday's list.

### Fix

1. In `_DayRolloverWatcherState`, start a one-shot `Timer` that fires just after
   the next local midnight.
2. When it fires, run the same check as on resume (move from the old day's list to
   today's list and show the "new day" message), then schedule the next timer.
3. Cancel the timer when the app goes to the background, restart it on resume, and
   cancel it in `dispose()`.
4. The `today` function is already injectable for tests. Add a matching injectable
   `now` clock so tests can drive the timer with `fakeAsync`.

The same rules as before still apply: only a plain day list is moved, and never a
screen that may hold unsaved work.

---

## Files to change

| File | Issue |
|------|-------|
| `lib/domain/usecases/move_todo.dart` | 1, 2 |
| `lib/domain/usecases/undo_move_todo.dart` (new) | 1 |
| `lib/domain/repositories/todo_repository.dart` | 1, 2 |
| `lib/data/repositories/todo_repository_impl.dart` | 1, 2 |
| `lib/application/daily_todo_state.dart` (+ run `build_runner`) | 1 |
| `lib/application/daily_todo_notifier.dart` | 1 |
| `lib/application/providers.dart` | 1 |
| `lib/core/constants/app_constants.dart` | 3 |
| `lib/data/database/migrations/migration_v12.dart` (new) | 3 |
| `lib/data/database/migrations/migration_runner.dart` | 3 |
| `lib/data/database/migrations/migration_v1.dart` or the fresh-install schema (whichever builds new databases) | 3 |
| `lib/data/models/recurrence_rule_entity.dart` (+ run `build_runner`) | 3 |
| `lib/domain/usecases/generate_recurring_tasks.dart` | 3 |
| `lib/domain/usecases/update_recurring_todos.dart` | 3 |
| `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` | 3 |
| `lib/presentation/shared/widgets/day_rollover_watcher.dart` | 4 |
| `docs/architecture.md` (schema v12, undo of moves) | 1, 3 |

No new user-visible text, so no ARB changes.

## Tests

- `test/domain/usecases/move_todo_test.dart`: a move to a past date throws
  `DayLockedException`; the result carries `previousSourceDate`.
- `test/domain/usecases/undo_move_todo_test.dart` (new): undoing an explicit move
  of a multi-day task restores `sourceDate`; undoing a carry-over restores
  `sourceDate = null` and the past date.
- Repository test for `restoreMove`, including the duplicate-title check.
- `test/presentation/undo_snackbar_test.dart`: undoing a move through the UI
  restores the task on its old days.
- Migration test: v11 → v12 adds the columns; running it twice is safe.
- `RecurrenceRuleEntity.fromMap` works on a map without the new keys.
- `test/domain/usecases/generate_recurring_tasks_test.dart`: new occurrences use
  the rule's values; a "this instance only" edit to the latest occurrence is not
  copied; rules without the new values fall back to the latest occurrence.
- `test/domain/usecases/update_recurring_todos_test.dart` (existing or new):
  "future"/"all" edits save the values on the rule; "this only" does not.
- `test/presentation/day_rollover_watcher_test.dart`: with the app in the
  foreground, crossing midnight moves the day list to today; the timer is
  cancelled on dispose.

## Checks before calling it done

- `dart run build_runner build --delete-conflicting-outputs`
- `dart format lib/ test/`
- `flutter analyze` — 0 issues
- `flutter test` — all pass
- Write a change log in `change_log/`.

## Risks

- **Issue 3 changes the database.** The migration only adds nullable columns, so
  existing data is not touched and older backups still import. A backup made
  after v12 and restored on an older app version would ignore the new columns,
  which is safe.
- **Issue 1 changes `UndoEntry`.** Undo entries live only in memory, so no stored
  data is affected.
