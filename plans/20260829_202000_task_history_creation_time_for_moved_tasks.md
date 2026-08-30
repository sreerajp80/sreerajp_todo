# Task History Creation Time and Moved Time for Moved Tasks

**Status:** Pending Approval

## Problem
When a task is moved to another date:
1. In the task history, the original creation event and creation time must strictly reflect the original time and date when the task was first created.
2. The move event itself, and all subsequent operations (timer sessions, manual segments, status changes, edits) must reflect the moved time / event occurrence time.
3. If a task was moved and had its `created` history entry synthesized (e.g. from legacy records), it should correctly show the original source creation date and timestamp, not the new moved date.
4. The task summary card in the Task History screen should clearly present the original creation date/time alongside the current date if the task was moved.

---

## Proposed Changes

### 1. Data Layer (`lib/data/repositories/todo_repository_impl.dart`)
- **`moveTodo`**:
  - Preserve `sourceDate` as `todo.sourceDate ?? fromDate` so that the original creation date is permanently tracked on the entity.
  - Log `TodoHistoryEventType.moved` with `eventTime` as current timestamp (`nowIso` = moved time) and metadata `{ "from_date": "$fromDate", "to_date": "$targetDate" }`.
- **`getHistoryForTodo`**:
  - For synthetic `created` event when no recorded `created` event exists in `todo_history`, ensure `eventTime` uses the original `todo.createdAt`, and the description uses the original source date (`todo.sourceDate ?? from_date ?? todo.date`).
  - Ensure chronological ordering (`event_time ASC`) ensures the original creation event appears first, followed by the move event with the moved timestamp, followed by all subsequent events.

### 2. Presentation Layer (`lib/presentation/screens/task_history/task_history_screen.dart`)
- **`_buildTaskSummaryCard`**:
  - Display the task's current date as well as the original creation date/time if the task was moved from another date (`todo.sourceDate != null`).
- **Timeline tiles**:
  - "Task Created" event tile displays the original creation timestamp (`event.eventTime` = original time) and original creation date description.
  - "Task Moved" event tile displays the moved timestamp (`event.eventTime` = moved time) and movement description (`Moved from X to Y`).
  - Rest of the event tiles (timer started/stopped, status changed, edited, subtasks) display their respective execution timestamps at or after the move.

### 3. Tests
- **`test/domain/usecases/move_todo_test.dart`**:
  - Add test verifying that when a task is created on Date 1 and moved on Date 2, task history retains the original creation time for the `created` event and the moved time for the `moved` event.
- **`test/presentation/task_history_screen_test.dart`**:
  - Add widget test verifying that moved task history displays the original creation time and moved time accurately.

---

## Verification Plan
1. **Automated Tests:**
   - Run `flutter test test/domain/usecases/move_todo_test.dart`
   - Run `flutter test test/presentation/task_history_screen_test.dart`
   - Run full test suite: `flutter test`
   - Run static analysis: `flutter analyze`
2. **Manual Verification:**
   - Verify that moving a task from a past date or alert window preserves the original creation timestamp in the Task History screen while recording the move event at the current time.
