# Change Log: Task History, Move to Today Fix, and Clean Move Semantics

**Plan reference:** `plans/20260829_191500_task_history_and_move_improvements.md`  
**Date:** 2026-08-29  

---

## Changes Implemented

### 1. Database & Schema Migration V10
- Added SQLite schema migration `MigrationV10` to create `todo_history` table (`id`, `todo_id`, `event_type`, `event_time`, `description`, `metadata`, `created_at`) with index `idx_todo_history_todo_id`.
- Incremented `kDatabaseVersion` from 9 to 10 in `lib/core/constants/app_constants.dart`.
- Registered `MigrationV10` in `lib/data/database/migrations/migration_runner.dart`.

### 2. Data Models & DAO
- Created `@freezed` entity `TodoHistoryEntity` and enum `TodoHistoryEventType` in `lib/data/models/todo_history_entity.dart`.
- Created `TodoHistoryDao` in `lib/data/dao/todo_history_dao.dart` for SQLite CRUD operations.

### 3. Repository & Domain Use Cases
- Updated `TodoRepository` domain interface with `moveTodo`, `getHistoryForTodo`, and `logHistoryEvent`.
- Implemented `moveTodo` in `TodoRepositoryImpl` to update task date to target date, assign proper sort order, and log a history event.
- Implemented `getHistoryForTodo` in `TodoRepositoryImpl` with fallback synthesis for legacy data (synthesizing creation and completed time segments).
- Integrated history event logging hooks into `TodoRepositoryImpl` (creations, title/description/priority edits, subtask toggles) and `TimeSegmentRepositoryImpl` (timer starts, timer stops/pauses with durations, manual segments).
- Created domain use cases `MoveTodo` in `lib/domain/usecases/move_todo.dart` and `GetTodoHistory` in `lib/domain/usecases/get_todo_history.dart`.

### 4. Application State & Provider Layer
- Added `todoHistoryDaoProvider`, `moveTodoProvider`, `getTodoHistoryProvider`, and `todoHistoryProvider` in `lib/application/providers.dart`.
- Updated `DailyTodoNotifier` in `lib/application/daily_todo_notifier.dart` with `moveTodo(todoId, targetDate)` and undo support across dates.
- Updated `UndoEntry` model in `lib/application/daily_todo_state.dart` to support source and target dates.

### 5. Presentation & UI
- Updated `PendingTodosAlertSheet` in `lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart` to use `moveTodoProvider`, transferring tasks to today and removing them from previous days.
- Created `TaskHistoryScreen` in `lib/presentation/screens/task_history/task_history_screen.dart` with vertical visual timeline, status/priority/duration badges, and metadata chips.
- Registered `/todo/:id/history` route in `lib/core/constants/app_routes.dart` and `lib/app.dart`.
- Added Task History action entry points in `TodoListTile` popup menu, `TimeSegmentsScreen` AppBar, and `CreateEditTodoScreen` AppBar.
- Added English and Malayalam localization strings for all task history and move actions in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.

### 6. Quality & Testing
- Added unit tests in `test/data/migration_v10_test.dart` and `test/data/todo_history_dao_test.dart`.
- Added use case tests in `test/domain/usecases/move_todo_test.dart` and `test/domain/usecases/get_todo_history_test.dart`.
- Added widget tests in `test/presentation/task_history_screen_test.dart`.
- Updated mock classes and verified that all 623 tests pass cleanly and static analysis has 0 issues.
