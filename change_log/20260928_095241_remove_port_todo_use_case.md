# Remove the unused `PortTodo` use case

Implements plan: `plans/20260928_093828_remove_port_todo_use_case.md`

## Why

`PortTodo` copied a todo to a new day with a new ID. The app no longer used it.
Move, port and every carry-over path use `MoveTodo`, which keeps the same ID,
time segments and history. Leaving `PortTodo` in the code risked someone calling
it by mistake and creating duplicate todos.

## What changed

- Deleted `lib/domain/usecases/port_todo.dart`.
- Deleted `test/domain/usecases/port_todo_test.dart`.
- `lib/application/providers.dart`: removed the import, `portTodoProvider`, and
  the `portTodoUseCase:` argument to `DailyTodoNotifier`.
- `lib/application/daily_todo_notifier.dart`: removed the import and the
  `portTodoUseCase` field. `moveTodoUseCase` and `reopenTodoUseCase` are now
  required, so the old fallback that borrowed `PortTodo`'s time-segment
  repository is gone.
- `test/presentation/undo_snackbar_test.dart`: removed the import and the
  `portTodoProvider` override.
- `docs/architecture.md`: replaced the `PortTodo` row with a `MoveTodo` row
  (notes that it keeps the same ID); replaced `port_todo_test.dart` with
  `move_todo_test.dart` in the test tree.
- `docs/project_structure.md`: replaced `PortTodo` with `MoveTodo` in the
  example use-case list.

## Not changed

- `DailyTodoNotifier.portTodo()` stays. It already calls `moveTodo()`.
- `TodoStatus.ported` and the `ported_to` column stay for old data.
- Historical docs (`docs/implementation_plan.md`, `docs/implementation_progress.md`).

## Checks

- `dart format lib/ test/`: 0 files changed.
- `flutter analyze`: no issues.
- `flutter test`: all 807 tests passed.
