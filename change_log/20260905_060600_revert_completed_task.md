# Change Log: Revert Completed Task Back for Today

**Date:** 2026-09-05
**Plan Reference:** [plans/20260905_060500_revert_completed_task.md](plans/20260905_060500_revert_completed_task.md)

## Summary of Changes

Implemented the ability to revert completed (and dropped) tasks back to active status when dated today, while strictly maintaining day-lock immutability for past days:

1. **Domain Use Case (`ReopenTodo`)**:
   - Reverts a completed or dropped todo back to `working` (if time segments have been recorded) or `pending` (if no time segments exist).
   - Enforces the Hard Rule 3 Day Lock check (`isPastDate(todo.date)`), throwing `DayLockedException` if the task is dated in the past.
   - Throws `TodoNotFoundException` if the todo does not exist.
   - Returns the previous `TodoStatus` to support undo history.

2. **Application Layer (`DailyTodoNotifier` & Providers)**:
   - Registered `reopenTodoProvider` in `providers.dart`.
   - Injected `ReopenTodo` into `DailyTodoNotifier`.
   - Added `reopenTodo(String todoId)` and `bulkReopen(Set<String> ids)` with `UndoEntry` registration.

3. **Presentation & Localization**:
   - Added `reopenAction` localization key in `app_en.arb` ("Reopen") and `app_ml.arb` ("വീണ്ടും തുറക്കുക").
   - Added quick-action replay button (`Icons.replay_rounded`) in row 1 of `TodoListTile` when dated today (`!isPast`).
   - Added "Reopen" action item in `TodoListTile`'s 3-dots popup menu for completed or dropped tasks.
   - Added "Reopen" action button to the multi-select AppBar in `DailyListScreen` when completed or dropped tasks are selected.
   - Displays a 5-second SnackBar with an "Undo" button allowing instant reversal of the reopen action.

4. **Testing & Verification**:
   - Added unit tests in `test/domain/usecases/reopen_todo_test.dart` verifying reopening tasks with zero segments (reverts to `pending`), with recorded segments (reverts to `working`), day-lock prevention on past dates (`DayLockedException`), and non-existent IDs (`TodoNotFoundException`).
   - Passed all static analysis checks (`flutter analyze`) with 0 issues.
   - Passed all 660 test suite tests (`flutter test`).

---

## Files Changed

### Localization
- `lib/l10n/app_en.arb`: Added `reopenAction` string.
- `lib/l10n/app_ml.arb`: Added `reopenAction` Malayalam translation.
- `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`, `lib/l10n/app_localizations_ml.dart`: Generated files updated via `flutter gen-l10n`.

### Domain Layer
- `lib/domain/usecases/reopen_todo.dart` (NEW): Domain use case to validate day lock, compute target status based on recorded segments, update database status, and return old status.

### Application Layer
- `lib/application/daily_todo_notifier.dart`: Added `reopenTodoUseCase` dependency, `reopenTodo` method, and `bulkReopen` method.
- `lib/application/providers.dart`: Registered `reopenTodoProvider` and injected it into `dailyTodoProvider`.

### Presentation Layer
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`: Added `onReopen` callback, `_canReopen` predicate, quick-action button on row 1, and 'reopen' popup menu item.
- `lib/presentation/screens/daily_list/daily_list_screen.dart`: Connected `onReopen` callback to `TodoListTile` with undo SnackBar; added `canReopen` action button to multi-select AppBar.

### Tests
- `test/domain/usecases/reopen_todo_test.dart` (NEW): Unit tests covering all branches of `ReopenTodo`.

---

## Verification

- `flutter gen-l10n`: Completed with code 0.
- `flutter analyze`: Completed with 0 issues found.
- `flutter test test/domain/usecases/reopen_todo_test.dart`: 4/4 tests passed.
- `flutter test`: 660/660 tests passed.
