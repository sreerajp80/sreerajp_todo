# Fix move undo, move day-lock, recurring template, and midnight rollover

Implements plan: [plans/20260928_095838_fix_move_undo_day_lock_recurring_template_rollover.md](../plans/20260928_095838_fix_move_undo_day_lock_recurring_template_rollover.md)

## 1. Undo of a move now restores the task exactly

Before, undo just moved the task back and lost its start date (`sourceDate`).
A multi-day task that was moved and then un-moved stopped showing on its
earlier days.

- `MoveTodoResult` now carries `previousSourceDate`.
- `UndoEntry` has `isMove` and `previousSourceDate` in place of `detached`.
- New use case `lib/domain/usecases/undo_move_todo.dart` stops any running
  timer, then calls the new repository method `restoreMove`.
- `TodoRepository.restoreMove` / `TodoRepositoryImpl.restoreMove` put back the
  old `date` and `sourceDate`. They keep the duplicate-title check and do not
  write an extra "moved" history event.
- `DailyTodoNotifier.undoLastStatusChange` uses `UndoMoveTodo` for move
  entries. It is wired through the new `undoMoveTodoProvider`.

## 2. Moves to a past day are refused

- `MoveTodo` and `TodoRepositoryImpl.moveTodo` throw `DayLockedException` when
  the target date is before today. Moving *from* a past day (carry-over) still
  works.
- Undo uses `restoreMove`, which is the only path allowed to go back to a past
  day.

## 3. Repeating tasks take their values from the rule

Before, new occurrences copied priority, target time and sub-tasks from the
latest occurrence, so a "this instance only" edit leaked into every later
occurrence.

- New migration `lib/data/database/migrations/migration_v12.dart` adds
  `priority`, `target_seconds` and `sub_task_titles` (JSON) to
  `recurrence_rules`. All three are nullable and added only when missing.
  `kDatabaseVersion` is now 12.
- `RecurrenceRuleEntity` has the three new fields, `hasSeriesValues`,
  `withSeriesValues(...)` and `withSeriesValuesFrom(todo)`. `fromMap` reads the
  new fields as optional, so older backups and payloads still load.
- `RecurrenceRuleRepositoryImpl` NFC-normalizes sub-task titles on write.
- `GenerateRecurringTasks` uses the rule's values. Rules saved before v12 fall
  back to copying the latest occurrence, as before.
- `UpdateRecurringTodos` saves the values on the rule for "this and future" and
  "all" edits. "This instance only" leaves the rule alone.
- `create_edit_todo_screen.dart` saves the values when a repeat is created.

## 4. The day list moves to today at midnight while the app is open

- `DayRolloverWatcher` now starts a timer that fires one second after local
  midnight. It runs the same check as on resume, then schedules the next one.
- The timer is cancelled when the app goes to the background and in
  `dispose()`, and is restarted on resume.
- A `now` clock can be injected for tests.

## Tests

- New: `test/domain/usecases/undo_move_todo_test.dart`,
  `test/application/undo_move_test.dart`, `test/data/migration_v12_test.dart`.
- Added cases to `move_todo_test.dart`, `multi_day_continuous_todo_test.dart`
  (`restoreMove` and the past-day refusal), `generate_recurring_tasks_test.dart`,
  `update_recurring_todos_test.dart` and `day_rollover_watcher_test.dart`.
- `multi_day_continuous_todo_test.dart` now uses dates relative to today. Its
  fixed September dates had become past days, which moves now refuse.
- `migration_v11_test.dart` checks the fresh database against
  `kDatabaseVersion` instead of a hard-coded 11.
- Test fakes of `TodoRepository` gained `restoreMove`.

## Docs

- `docs/architecture.md`: schema v12 and the `MoveTodo` / `UndoMoveTodo` flows.

## Checks

- `dart run build_runner build --delete-conflicting-outputs`: done.
- `dart format lib/ test/`: done.
- `flutter analyze`: no issues.
- `flutter test`: all 833 tests pass.
