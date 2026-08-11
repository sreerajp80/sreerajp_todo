# Change Log — Hierarchical Sub-task Checklists & Inter-task Dependency Engine

**Date:** 2026-08-10 19:02:30
**Plan:** `plans/20260810_185844_sub_task_checklists_and_dependencies.md`

## Summary of Changes
Implemented Feature 3.7: Hierarchical Sub-task Checklists and Inter-task Dependency Engine.

### Data & Migration
- Bumped `kDatabaseVersion` from 3 to 4 in [app_constants.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_constants.dart).
- Added `SubTaskItem` data model with `@freezed` annotations in [sub_task_item.dart](file:///l:/Android/sreerajp_todo/lib/data/models/sub_task_item.dart).
- Added SQLite schema migration in [migration_v4.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_v4.dart) to create `sub_tasks` and `task_dependencies` tables with `ON DELETE CASCADE` triggers.
- Updated database migration runner in [migration_runner.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_runner.dart).
- Added `SubTaskDao` in [sub_task_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/sub_task_dao.dart) and `TaskDependencyDao` in [task_dependency_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/task_dependency_dao.dart).
- Extended `TodoEntity` in [todo_entity.dart](file:///l:/Android/sreerajp_todo/lib/data/models/todo_entity.dart) to contain `subTasks` and `prerequisiteTodoIds`.
- Updated `TodoDao` in [todo_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/todo_dao.dart) and `TodoRepositoryImpl` in [todo_repository_impl.dart](file:///l:/Android/sreerajp_todo/lib/data/repositories/todo_repository_impl.dart) to read and write sub-tasks and task dependencies while enforcing NFC normalization and day lock.

### Domain & Application
- Added repository methods `toggleSubTask`, `getPendingPrerequisites`, and `isTodoBlocked` to `TodoRepository` in [todo_repository.dart](file:///l:/Android/sreerajp_todo/lib/domain/repositories/todo_repository.dart).
- Added `toggleSubTask` action to `DailyTodoNotifier` in [daily_todo_notifier.dart](file:///l:/Android/sreerajp_todo/lib/application/daily_todo_notifier.dart).
- Added `pendingPrerequisitesProvider` in [providers.dart](file:///l:/Android/sreerajp_todo/lib/application/providers.dart).

### Presentation
- Updated `TodoListTile` in [todo_list_tile.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/widgets/todo_list_tile.dart):
  - Displays a sub-task progress pill (e.g. `2/5`) on the task card.
  - Displays a warning badge ("Blocked by N tasks") when prerequisite tasks remain uncompleted.
  - Displays a warning alert when starting a timer on a blocked task.
- Updated `CreateEditTodoScreen` in [create_edit_todo_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart):
  - Sub-task checklist card for adding, checking off, and deleting checklist items (`[ ] Step 1`, `[x] Step 2`).
  - Prerequisite tasks card for selecting prerequisite tasks on the same date.

### Localization & Documentation
- Added localization strings to [app_en.arb](file:///l:/Android/sreerajp_todo/lib/l10n/app_en.arb) and [app_ml.arb](file:///l:/Android/sreerajp_todo/lib/l10n/app_ml.arb).
- Marked Section 3.7 as implemented with green tick `✅` in [unique_features_and_improvements.md](file:///l:/Android/sreerajp_todo/docs/unique_features_and_improvements.md#L93-L98).

### Testing
- Created unit tests in [sub_task_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/sub_task_dao_test.dart) and [task_dependency_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/task_dependency_dao_test.dart).
- All 247 unit and widget tests passed cleanly (`flutter test`).
- Static analysis verified 0 issues (`flutter analyze`).
