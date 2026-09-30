# Remove the unused `PortTodo` use case

**Status:** completed

## What the issue is

`lib/domain/usecases/port_todo.dart` has an old `PortTodo` use case. It copies a
todo to a new day with a **new ID** and marks the original as `ported`.

The app no longer uses it:

- Manual move, the "Port" action, automatic carry-over, the carry-over sheet and
  the ritual carry-over step all use `MoveTodo`. `MoveTodo` keeps the **same ID**.
- `DailyTodoNotifier.portTodo()` just calls `moveTodo()`. It does not call `PortTodo`.
- The only live use of `PortTodo` is in `DailyTodoNotifier`. The notifier borrows
  `portTodoUseCase.timeSegmentRepository` to build fallback `MoveTodo` and
  `ReopenTodo` objects. The real provider always passes those two use cases in,
  so the fallback never runs in the app.

This dead code is a risk. Someone could call `PortTodo` by mistake. That would
create a duplicate todo with a new ID and split its time and history.

## Files to be changed

| File | Change |
|------|--------|
| `lib/domain/usecases/port_todo.dart` | Delete the file. |
| `test/domain/usecases/port_todo_test.dart` | Delete the file (it only tests `PortTodo`). |
| `lib/application/providers.dart` | Remove the `port_todo.dart` import, the `portTodoProvider`, and the `portTodoUseCase:` argument passed to `DailyTodoNotifier`. |
| `lib/application/daily_todo_notifier.dart` | Remove the `port_todo.dart` import, the `portTodoUseCase` field and constructor parameter. Make `moveTodoUseCase` and `reopenTodoUseCase` required, so the fallback that used `portTodoUseCase.timeSegmentRepository` is no longer needed. |
| `test/presentation/undo_snackbar_test.dart` | Remove the `port_todo.dart` import and the `portTodoProvider.overrideWithValue(...)` override. |
| `docs/architecture.md` | Remove the `PortTodo` row from the use-case table. Remove `port_todo_test.dart` from the test tree. Add a note that moving and carrying over a todo keep the same ID (via `MoveTodo`). |
| `docs/project_structure.md` | Replace `PortTodo` with `MoveTodo` in the list of example use-cases. |

## What will NOT change

- The `DailyTodoNotifier.portTodo()` method stays. It is the name the two screens
  use for the "Port" action, and it already calls `moveTodo()`. Behaviour stays the same.
- `TodoStatus.ported` and the `ported_to` column stay. Old data may still have them.
  `moveTodo` in the repository already turns `ported` back to `pending`.
- `docs/implementation_plan.md` and `docs/implementation_progress.md` stay as they are.
  They are historical records.
- No database, ARB or UI text changes.

## Plan for the fix

1. Delete `port_todo.dart` and `port_todo_test.dart`.
2. Update `daily_todo_notifier.dart` and `providers.dart` as listed above.
3. Update `undo_snackbar_test.dart` to drop the `PortTodo` override.
4. Update the two docs files.
5. Search again for `PortTodo`, `portTodoProvider` and `port_todo` in `lib/`,
   `test/` and `integration_test/` to make sure nothing is left.
6. Run `dart format lib/ test/`, `flutter analyze` (must be 0 issues) and
   `flutter test` (all must pass).
7. Write a change log in `change_log/`.

## Risk

Low. The removed code is not used by any screen. The notifier change only
removes a fallback path that the app never takes. Tests will confirm this.
