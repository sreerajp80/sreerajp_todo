# Change log: task date picker and true "Move"

Implements plan: `plans/20260927_212007_mastery_task_date_and_true_move.md`

## What changed

### "Move" now really moves the task
- `lib/domain/repositories/todo_repository.dart`, `lib/data/repositories/todo_repository_impl.dart`:
  `moveTodo` has a new `detach` option. With `detach: true` the task's
  `sourceDate` is cleared, so it shows only on the new date. With `detach: false`
  (default) carry-over works as before and keeps the task visible on earlier days.
  The "moved" history event is still logged either way.
- `lib/domain/usecases/move_todo.dart`: passes `detach` through; `MoveTodoResult` has a `detached` field.
- `lib/application/daily_todo_state.dart`: `UndoEntry` has a `detached` flag (generated freezed file rebuilt).
- `lib/application/daily_todo_notifier.dart`: `moveTodo(..., detach:)`; undo moves the task back the same way.
- `lib/presentation/screens/daily_list/daily_list_screen.dart`: the "Move" menu action uses `detach: true`.
  Carry-over sheet, pending alert, ritual and port are unchanged.
- A task with timer time recorded on the old date still shows there as history.

### Date picker for new tasks (including Mastery Deck)
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`: new tasks show a
  "Task date" field with a calendar button. Range: today to one year ahead. Changing the
  date re-checks the title for duplicates, reloads prerequisites for that day (and clears
  old picks), and moves a repeat end date forward if it would be before the new date.
  Editing an existing task does not show this field.
- `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart`: refreshes the deck's
  task list and progress after returning from the create screen.

### Localization
- New keys `taskDateLabel` and `tooltipChangeTaskDate` in English, Malayalam and Sanskrit ARB
  files, with descriptions. `flutter gen-l10n` run.

### Tests
- `test/data/multi_day_continuous_todo_test.dart`: explicit move removes the task from the old and in-between dates.
- `test/domain/usecases/move_todo_test.dart`: `detach` is passed through and the move is logged.
- `test/presentation/create_edit_todo_screen_test.dart`: date field shows for new tasks, opens the picker, and is hidden when editing.
- Test fakes of `TodoRepository.moveTodo` updated for the new named parameter.

## Checks
- `flutter analyze`: no issues.
- `flutter test`: all 794 tests passed.
