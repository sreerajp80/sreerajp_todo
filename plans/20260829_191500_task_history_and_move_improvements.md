# Task History, Move to Today Fix, and Hide Moved Tasks on Previous Days

**Status:** Implemented

## Problem
1. **Alert Window Move Issue:** When moving an unfinished task from the pending alert sheet (`PendingTodosAlertSheet`), tasks were copied using `CopyTodos` rather than moved, so they remained pending on the previous day and still showed up as "Move to today".
2. **Missing Task History:** There is no dedicated task history / audit log tracking the complete lifecycle of a todo: when it was created, moved from date to date, when timers were started/paused/stopped, manual time segments added, status changes (completed/dropped/reopened), subtask completion, and edits.
3. **Moved Tasks Dimmed on Previous Days:** When moving a task to another day, previous logic retained a `TodoStatus.ported` record on the old day shown as dimmed. The user requested that moved tasks should NOT show on the previous day at all; their full movement details should be preserved in task history.

---

## Proposed Changes

### 1. Database & Migration (V10)
- **`lib/core/constants/app_constants.dart`**: Bump `kDatabaseVersion` from 9 to 10.
- **`lib/data/database/migrations/migration_v10.dart`**:
  - Create table `todo_history`:
    - `id TEXT PRIMARY KEY`
    - `todo_id TEXT NOT NULL` (Foreign key to `todos(id)` ON DELETE CASCADE)
    - `event_type TEXT NOT NULL` (`created`, `moved`, `timer_started`, `timer_stopped`, `timer_paused`, `manual_segment_added`, `status_changed`, `subtask_toggled`, `edited`)
    - `event_time TEXT NOT NULL` (ISO 8601 UTC)
    - `description TEXT NOT NULL` (Human readable summary)
    - `metadata TEXT` (JSON with contextual details like `from_date`, `to_date`, `duration_seconds`, `notes`, etc.)
    - `created_at TEXT NOT NULL`
  - Create index: `idx_todo_history_todo_id ON todo_history (todo_id, event_time ASC)`.
- **`lib/data/database/migrations/migration_runner.dart`**: Register Migration V10.

### 2. Data Layer (Models, DAO & Repositories)
- **`lib/data/models/todo_history_entity.dart`**: Freezed model for history records and event type enum.
- **`lib/data/dao/todo_history_dao.dart`**: DAO for inserting, querying, and deleting history records.
- **`lib/domain/repositories/todo_repository.dart` & `lib/data/repositories/todo_repository_impl.dart`**:
  - Add `moveTodo(String todoId, String targetDate)`: moves the task to `targetDate` by updating its date and sort order, and logs a `moved` history event.
  - Automatically log history events on `createTodo`, `updateStatus`, `updateTodo`, `toggleSubTask`.
  - Add `getHistoryForTodo(String todoId)` method.
- **`lib/domain/repositories/time_segment_repository.dart` & `lib/data/repositories/time_segment_repository_impl.dart`**:
  - Log `timer_started`, `timer_stopped`, `timer_paused`, and `manual_segment_added` in `todo_history`.

### 3. Domain Use Cases
- **`lib/domain/usecases/move_todo.dart`**:
  - Validates target date, ensures title uniqueness on target date.
  - Stops any running timer on the source task.
  - Updates the task's date to `targetDate`.
  - Records a move history event with source and target dates.
- **`lib/domain/usecases/get_todo_history.dart`**:
  - Retrieves chronological history records for a task, synthesizing base creation and time segments if legacy task had no prior history rows.

### 4. Application Layer & Providers
- **`lib/application/providers.dart`**:
  - Register `todoHistoryDaoProvider`, `moveTodoProvider`, `getTodoHistoryProvider`, and `todoHistoryProvider.family(todoId)`.
- **`lib/application/daily_todo_notifier.dart`**:
  - Update `portTodo` / `moveTodo` to move the task directly to `targetDate` without leaving a duplicate on the previous day.
  - Support undoing a move by returning the task to its original date and logging the reversal in history.

### 5. UI Layer & Screens
- **`lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart`**:
  - Use `moveTodoProvider` when moving a previous day's task to today.
  - Remove the task from `_previousTodos` and add the moved task to `_todayTodos`.
  - For tasks in `_todayTodos`, display timer controls and view action, never "Move to today".
  - Invalidate both previous day and today providers.
- **`lib/presentation/screens/daily_list/day_list_filters.dart` & `daily_list_screen.dart`**:
  - Cleanly hide any legacy `ported` tasks or avoid displaying moved tasks on past dates.
- **`lib/presentation/screens/task_history/task_history_screen.dart`**:
  - Rich, dedicated screen displaying a chronological vertical timeline of all task events (created, moved, timers, status updates, subtasks) with distinct icons, color accents, duration badges, and localized labels.
- **Navigation & Menu Access**:
  - **`lib/core/constants/app_routes.dart` & `lib/app.dart`**: Add route `/todo/:id/history`.
  - **`lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`**: Add "Task History" (`Icons.history`) to the tile popup menu.
  - **`lib/presentation/screens/time_segments/time_segments_screen.dart`**: Add Task History action button in the AppBar.
  - **`lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`**: Add "View Task History" button.

### 6. Localization
- **`lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`**:
  - Add strings for Task History screen title, empty state, event labels (`created`, `moved`, `timerStarted`, `timerStopped`, `timerPaused`, `manualSegment`, `statusChanged`, `subtaskToggled`), and move confirmations.

---

## Verification Plan
1. **Automated Tests:**
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Run `flutter test` to verify all domain, DAO, notifier, and widget tests pass.
   - Run `flutter analyze` ensuring 0 warnings.
2. **Manual Verification:**
   - Test moving a task from the Alert Window: verify the task moves to today, disappears from previous days, and shows timer controls under today's section.
   - Test moving a task from Daily List: verify the task is removed from the source day, appears on the destination day, and has no dimmed remnant on the source day.
   - Open Task History for a task: verify all events (created, moved, timer started/stopped, status changed, subtasks) appear in order with proper details.
