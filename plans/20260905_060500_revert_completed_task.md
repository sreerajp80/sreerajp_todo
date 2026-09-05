# Revert Completed Task Back for Today

**Status:** completed

## The ask

Users should be able to revert a completed task back (reopen it to pending or working) if the task belongs to today, while maintaining day-lock immutability for past days.

## The issue today

1. When a task is marked as completed on the daily list, its quick actions (complete, drop, timer play/stop) are hidden because `_canShowQuickActions` returns true only for pending and working statuses.
2. The 3-dots popup menu on `TodoListTile` contains "History", "Time Segments", "Edit", "Copy", and "Delete", but has no "Reopen" or "Revert" action.
3. In multi-select mode on `DailyListScreen`, completed tasks cannot be bulk-reopened; only "Complete All" and "Mark Dropped" are provided.
4. While `CreateEditTodoScreen` allows manually editing status, navigating into edit just to uncomplete a task is cumbersome and unintuitive.
5. There is no dedicated domain use case `ReopenTodo` to coordinate reopening completed or dropped tasks, validating day-lock constraints, determining the correct target status (`working` if it has recorded time segments, `pending` otherwise), and recording undo entries.

## Decisions

* **Day Lock Enforced:** As mandated by Hard Rule 3, past-dated tasks remain strictly locked and read-only. Reverting is only allowed when `!isPastDate(todo.date)`. If attempted programmatically on a past date, `DayLockedException` is thrown.
* **Target Status Logic:**
  - If a completed task has recorded time segments with duration > 0, reopening it transitions its status to `TodoStatus.working`.
  - If a completed task has no recorded time segments, reopening it transitions its status to `TodoStatus.pending`.
* **One-Tap Quick Action:** In `TodoListTile`, when a task is completed (or dropped) and it is today (`!isPast`), show a compact quick-action button (`Icons.replay_rounded` with tooltip "Reopen") in row 1 alongside the 3-dots menu button, so users can revert with a single tap.
* **Popup Menu Option:** In `TodoListTile`'s 3-dots menu, include a "Reopen" menu item when `!isPast && (displayStatus == TodoStatus.completed || displayStatus == TodoStatus.dropped)`.
* **Multi-Select Support:** In `DailyListScreen`, if the selection contains completed or dropped tasks, display a "Reopen" action in the selection app bar.
* **Undo UX:** Reverting displays a 5-second SnackBar with an "Undo" action that restores the task back to `completed` (or previous status).
* **Relative paths and privacy:** All plans and change logs use relative repository paths only and contain no sensitive or private information.

## The plan

### 1. Domain Layer: Reopen Todo Use Case

#### `lib/domain/usecases/reopen_todo.dart` (NEW)
- Define `class ReopenTodo`:
  - Injects `TodoRepository` and `TimeSegmentRepository`.
  - `Future<TodoStatus> call(String todoId)`:
    - Fetches the todo by `todoId`. Throws `TodoNotFoundException` if not found.
    - Enforces day-lock: `if (isPastDate(todo.date)) throw const DayLockedException();`.
    - Checks segments via `_timeSegmentRepository.getSegments(todoId)`.
    - Determines `newStatus`: `segments.any((s) => (s.durationSeconds ?? 0) > 0) ? TodoStatus.working : TodoStatus.pending`.
    - Updates status via `_todoRepository.updateStatus(todoId, newStatus)`.
    - Returns previous `TodoStatus` for undo support.

### 2. Application Layer: Providers and DailyTodoNotifier

#### `lib/application/providers.dart`
- Register `reopenTodoProvider = Provider<ReopenTodo>((ref) => ReopenTodo(ref.read(todoRepositoryProvider), ref.read(timeSegmentRepositoryProvider)));`.
- Pass `reopenTodo: ref.read(reopenTodoProvider)` into `DailyTodoNotifier`.

#### `lib/application/daily_todo_notifier.dart`
- Add parameter `reopenTodoUseCase` to `DailyTodoNotifier`.
- Add `Future<void> reopenTodo(String todoId)`:
  - Invokes `reopenTodoUseCase(todoId)`.
  - Pushes `UndoEntry` with `oldStatus` and `newStatus`.
  - Calls `await loadTodos()`.
- Add `Future<void> bulkReopen(Set<String> ids)`:
  - Iterates over selected IDs, calling `reopenTodoUseCase(id)` and pushing undo entries.
  - Clears selection and refreshes todos.

### 3. Presentation Layer: UI and Localization

#### `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`
- Add localization key:
  - `reopenAction`: "Reopen" (English) / "വീണ്ടും തുറക്കുക" (Malayalam).
- Run `flutter gen-l10n` to generate Dart localization files.

#### `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`
- Add `final VoidCallback? onReopen;` to `TodoListTile`.
- In row 1:
  - If `!isMultiSelectMode && !isPast && (displayStatus == TodoStatus.completed || displayStatus == TodoStatus.dropped)`:
    - Display compact action button with icon `Icons.replay_rounded`, tooltip `context.l10n.reopenAction`, and callback `onReopen`.
- In `_buildPopupMenu`:
  - If `!isPast && (displayStatus == TodoStatus.completed || displayStatus == TodoStatus.dropped)`:
    - Add `PopupMenuItem` with value `'reopen'`, icon `Icons.replay_rounded`, and label `context.l10n.reopenAction`.

#### `lib/presentation/screens/daily_list/daily_list_screen.dart`
- Pass `onReopen: () async { await notifier.reopenTodo(todo.id); showUndoSnackBar(...); }` to `TodoListTile`.
- In multi-select app bar:
  - Check if any selected item is completed or dropped (`canReopen`).
  - If true, display a "Reopen" `TextButton.icon` with `Icons.replay_rounded` calling `notifier.bulkReopen(selectedIds)`.

### 4. Verification & Testing

#### `test/domain/usecases/reopen_todo_test.dart` (NEW)
- Test reopening completed task with no segments sets status to `pending`.
- Test reopening completed task with segments sets status to `working`.
- Test reopening completed task on a past date throws `DayLockedException`.
- Test reopening non-existent task throws `TodoNotFoundException`.

#### Static Analysis & Tests
- Run `flutter analyze` (must be 0 issues).
- Run `flutter test` (all tests passing).

## Verification plan

### Automated Tests
- Run `flutter test test/domain/usecases/reopen_todo_test.dart`
- Run `flutter test test/presentation/undo_snackbar_test.dart`
- Run `flutter test`
- Run `flutter analyze`
