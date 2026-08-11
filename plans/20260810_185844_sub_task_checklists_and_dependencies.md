# Implementation Plan — Hierarchical Sub-task Checklists & Inter-task Dependency Engine

**Status:** Awaiting Approval

## Goal Description
Implement Feature 3.7: Hierarchical Sub-task Checklists and Inter-task Dependency Engine.
- **Sub-task Checklists:** Enable embedding lightweight checklist items (`[ ] Step 1`, `[x] Step 2`) inside `TodoEntity`. Render sub-task progress (e.g. `2/5`) as a mini progress pill on the task tile.
- **Task Dependencies:** Allow defining prerequisite task links (e.g. Task B is blocked by Task A). Display a warning badge indicating pending prerequisites when attempting to start a timer or viewing a blocked task on the daily list.

---

## User Review Required
> [!IMPORTANT]
> - Database schema version will be bumped from 3 to 4 (`kDatabaseVersion = 4`). New tables `sub_tasks` and `task_dependencies` will be created with CASCADE deletion triggers when a parent task is deleted.
> - NFC normalization (`unicodeUtils.nfcNormalize`) will be enforced on all sub-task titles before writing to the SQLite database.
> - Day-lock rules apply: past day sub-tasks and task dependencies are read-only.

---

## Open Questions
None.

---

## Proposed Changes

### Data & Migration Layer

#### [MODIFY] [app_constants.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_constants.dart)
- Increment `kDatabaseVersion` from 3 to 4.

#### [NEW] [sub_task_item.dart](file:///l:/Android/sreerajp_todo/lib/data/models/sub_task_item.dart)
- Create `@freezed` class `SubTaskItem` with fields `id`, `todoId`, `title`, `isCompleted`, `sortOrder`, `createdAt`, `updatedAt`, `toMap()`, and `fromMap()`.

#### [NEW] [migration_v4.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_v4.dart)
- SQL migration to create `sub_tasks` table:
  - `id TEXT PRIMARY KEY`, `todo_id TEXT NOT NULL`, `title TEXT NOT NULL`, `is_completed INTEGER`, `sort_order INTEGER`, `created_at TEXT`, `updated_at TEXT`.
- SQL migration to create `task_dependencies` table:
  - `blocked_todo_id TEXT NOT NULL`, `prerequisite_todo_id TEXT NOT NULL`, `PRIMARY KEY (blocked_todo_id, prerequisite_todo_id)`.

#### [MODIFY] [migration_runner.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_runner.dart)
- Add execution step for `migration_v4.dart` when upgrading database to version 4.

#### [NEW] [sub_task_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/sub_task_dao.dart)
- DAO methods for `sub_tasks` table: `getSubTasksForTodo`, `saveSubTasksForTodo`, `toggleSubTask`, `deleteSubTask`.

#### [NEW] [task_dependency_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/task_dependency_dao.dart)
- DAO methods for `task_dependencies` table: `getPrerequisiteIdsForTodo`, `setPrerequisitesForTodo`, `getPendingPrerequisiteCount`.

#### [MODIFY] [todo_entity.dart](file:///l:/Android/sreerajp_todo/lib/data/models/todo_entity.dart)
- Add `subTasks` (`List<SubTaskItem>`) and `prerequisiteTodoIds` (`List<String>`) fields to `TodoEntity`.

#### [MODIFY] [todo_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/todo_dao.dart)
- Integrate loading and saving of sub-tasks and task dependencies during `TodoEntity` fetch, insert, and update operations.

#### [MODIFY] [todo_repository_impl.dart](file:///l:/Android/sreerajp_todo/lib/data/repositories/todo_repository_impl.dart)
- Support sub-task and task dependency persistence while enforcing day-lock checks and NFC normalization.

---

### Domain Layer

#### [MODIFY] [todo_repository.dart](file:///l:/Android/sreerajp_todo/lib/domain/repositories/todo_repository.dart)
- Add repository methods: `toggleSubTask`, `getPendingPrerequisites`, `isTodoBlocked`.

---

### Application Layer

#### [MODIFY] [daily_todo_notifier.dart](file:///l:/Android/sreerajp_todo/lib/application/daily_todo_notifier.dart)
- Add actions `toggleSubTask(String todoId, String subTaskId, bool isCompleted)` to seamlessly toggle sub-task state and reload UI.

---

### Presentation Layer

#### [MODIFY] [todo_list_tile.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/widgets/todo_list_tile.dart)
- Display mini progress pill (e.g. `2/5` completed) when a todo contains sub-tasks.
- Display warning badge ("Blocked by N tasks") when a todo has pending prerequisite tasks.
- If timer start button is tapped on a blocked task, display warning notification/badge indicating pending prerequisites.

#### [MODIFY] [create_edit_todo_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart)
- Add **Sub-task Checklist** editor card: allowing users to add, edit, check off, or remove sub-task checklist items (`[ ] Step 1`, `[x] Step 2`).
- Add **Prerequisite Tasks** selection section: enabling selection of prerequisite tasks from today's list.

---

### Documentation & Verification Layer

#### [MODIFY] [unique_features_and_improvements.md](file:///l:/Android/sreerajp_todo/docs/unique_features_and_improvements.md)
- Update section 3.7 title and description to mark feature as implemented with green tick `✅`.

#### [NEW] [sub_task_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/sub_task_dao_test.dart)
- Unit tests for `SubTaskDao` using in-memory SQLite database.

#### [NEW] [task_dependency_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/task_dependency_dao_test.dart)
- Unit tests for `TaskDependencyDao` using in-memory SQLite database.

---

## Verification Plan

### Automated Tests
- Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- Run static analysis: `flutter analyze` (Must pass with 0 warnings/errors)
- Run unit & widget tests: `flutter test` (Must pass all existing and new unit tests)

### Manual Verification
1. Create a task with 3 sub-tasks, check 1 off, verify `1/3` progress pill appears on `TodoListTile`.
2. Link Task B to depend on Task A. Verify Task B displays the blocked warning badge.
3. Try starting timer on Task B, verify warning badge/snackbar alerts about pending prerequisites.
4. Complete Task A and verify Task B is no longer blocked.
