# Delete Time Slots and Recurring Task Edit Options

**Status:** completed

## The ask

1. **Delete time slots:** Users should be able to delete time slots (time segments) on a task, with confirmation and undo support.
2. **Recurring task edit options:** When editing an instance of a recurring task, prompt the user whether to apply the change to:
   - "This instance only"
   - "All future instances"
   - "All instances"

## The issue today

1. **Time slot deletion:**
   - In `TimeSegmentsScreen` (`_SegmentTile`), there is only an edit button for time notes and tap-to-edit for start/end times. There is no button or action to delete a time slot.
   - `TimeTrackingNotifier` does not expose a `deleteSegment` or `restoreSegment` method for screen widgets.
   - `TimeSegmentRepositoryImpl.deleteSegment` lacks the mandatory day-lock check (`isPastDate(todo.date)`), which must throw `DayLockedException` for past dates per Hard Rule 3.
2. **Recurring task edits:**
   - In `CreateEditTodoScreen`, when editing a task with a recurrence rule (`todo.recurrenceRuleId != null`), hitting Save updates only that specific todo's fields and/or unconditionally edits the rule. It does not prompt the user for their desired scope ("this instance only", "all future instances", or "all instances").
   - There is no domain use case coordinating partial or series-wide updates to recurring instances and their underlying recurrence rule.
   - `TodoDao` and `TodoRepository` lack methods to query todos by `recurrence_rule_id` across dates for bulk updates.

## Decisions

* **Day lock preserved:** As required by Hard Rule 3, time slots and tasks dated in the past remain read-only. Deleting a segment on a past day is rejected. When editing "all instances" of a recurring series, past instances update title, description, priority, and target time metadata via `bypassLock: true` as an administrative series update without altering past completion status or past time segments.
* **Undo UX preserved:** Deleting a time slot shows a SnackBar with a 5-second timeout and an "Undo" action that restores the deleted slot.
* **Confirmation dialogs:**
   - Deleting a time slot requires a simple confirmation dialog ("Delete time segment?").
   - Editing a recurring task shows an AlertDialog asking the user to choose: "This instance only", "All future instances", or "All instances" (plus "Cancel").
* **Relative paths and privacy:** All plans and change logs use relative repository paths and contain no sensitive or private information.

## The plan

### 1. Data Layer: Time Segment Deletion & Recurring Task Queries

#### `lib/data/repositories/time_segment_repository_impl.dart`
- In `deleteSegment(String segmentId)`:
  - Fetch the segment and its parent todo.
  - If `todo != null && isPastDate(todo.date)`, throw `DayLockedException`.
  - Delete segment using `_timeSegmentDao.delete(segmentId)`.
  - Log a task history event (`TodoHistoryEventType.edited`) with description `Time segment deleted: <time-range> (<duration>)`.

#### `lib/data/dao/todo_dao.dart`
- Add `findByRecurrenceRuleId(String recurrenceRuleId)`: returns all todos matching `recurrence_rule_id`.
- Add `findByRecurrenceRuleIdFromDate(String recurrenceRuleId, String fromDate)`: returns todos matching `recurrence_rule_id` where `date >= fromDate`.
- Add `existsByRecurrenceRuleIdOnDate(String recurrenceRuleId, String date, {String? excludeId})`.

#### `lib/domain/repositories/todo_repository.dart` & `lib/data/repositories/todo_repository_impl.dart`
- Expose `getTodosByRecurrenceRuleId(String recurrenceRuleId)`.
- Expose `getTodosByRecurrenceRuleIdFromDate(String recurrenceRuleId, String fromDate)`.

### 2. Domain Layer: Recurring Task Update Use Case

#### `lib/domain/usecases/update_recurring_todos.dart` (NEW)
- Define `enum RecurringEditTarget { thisInstanceOnly, allFutureInstances, allInstances }`.
- Method `execute({required TodoEntity baseTodo, required TodoEntity updatedTodo, required RecurrenceRuleEntity? updatedRule, required RecurringEditTarget target})`:
  - **`thisInstanceOnly`**:
    - Updates only `updatedTodo` for `baseTodo.date`.
    - If recurrence was removed on the form, sets `recurrenceRuleId = null` on this todo.
    - Leaves the recurrence rule and all other instances untouched.
  - **`allFutureInstances`**:
    - Updates `updatedTodo` for `baseTodo.date`.
    - If `updatedRule != null`:
      - If recurrence pattern (RRULE) changed: updates the rule, deletes future unworked pending instances (`date > baseTodo.date AND recurrence_rule_id = rule.id AND status = 'pending'`), and calls `GenerateRecurringTasks` to recreate the look-ahead window.
      - If recurrence pattern did not change: updates the rule title/description/end-date, and updates all existing future instances (`date > baseTodo.date AND recurrence_rule_id = rule.id`) with the new title, description, priority, targetSeconds, and subTasks.
    - If `updatedRule == null` (repeat removed):
      - Ends the rule at yesterday (`rule.copyWith(endDate: yesterday)`).
      - Deletes future pending unworked instances.
      - Updates `updatedTodo` with `recurrenceRuleId = null`.
  - **`allInstances`**:
    - Updates `updatedTodo` for `baseTodo.date`.
    - If `updatedRule != null`:
      - Updates rule details.
      - If recurrence pattern changed: deletes future pending instances and regenerates lookahead.
      - Updates all instances with `recurrence_rule_id = rule.id` (using `bypassLock: true` for past instances) with the new title, description, priority, targetSeconds, and subTasks.
    - If `updatedRule == null` (repeat removed):
      - Deletes the recurrence rule.
      - Deletes future pending unworked instances.
      - Sets `recurrenceRuleId = null` on all remaining instances.

### 3. Application Layer: Riverpod Providers & Notifiers

#### `lib/application/time_tracking_notifier.dart`
- Add `deleteSegment(TimeSegmentEntity segment)`: calls `_repository.deleteSegment(segment.id)`, clears paused state if applicable, and refreshes state via `loadSegments()`.
- Add `restoreSegment(TimeSegmentEntity segment)`: calls `_repository.restoreSegment(segment)` and refreshes state via `loadSegments()`.

#### `lib/application/providers.dart`
- Register `updateRecurringTodosProvider`: provides `UpdateRecurringTodos` with `todoRepository`, `recurrenceRuleRepository`, and `generateRecurringTasks`.

### 4. Presentation Layer & UI

#### `lib/presentation/screens/time_segments/time_segments_screen.dart`
- In `_SegmentTile`:
  - If `!isPast`, add a delete `IconButton` (`Icons.delete_outline`) next to the note icon.
  - On press, display a confirmation dialog (`confirmDeleteSegment`).
  - If confirmed, call `ref.read(timeTrackingProvider(todoId).notifier).deleteSegment(segment)`.
  - Show SnackBar with `Undo` action (`restoreSegment(segment)`) for 5 seconds.

#### `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
- In `_save()`:
  - When editing (`widget.isEditing && _existingTodo?.recurrenceRuleId != null`):
    - Present an `AlertDialog` with options:
      - "This instance only" (`RecurringEditTarget.thisInstanceOnly`)
      - "All future instances" (`RecurringEditTarget.allFutureInstances`)
      - "All instances" (`RecurringEditTarget.allInstances`)
      - "Cancel"
    - If cancelled, abort save and keep user on screen.
    - Otherwise, execute `updateRecurringTodosProvider` with the selected target.

### 5. Localization & Text

#### `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_localizations*.dart`
- `deleteTimeSegment`: "Delete time segment"
- `confirmDeleteSegment`: "Delete time segment?"
- `confirmDeleteSegmentBody`: "Are you sure you want to delete this time segment?"
- `timeSegmentDeleted`: "Time segment deleted"
- `confirmEditRecurring`: "Edit recurring task?"
- `confirmEditRecurringBody`: "This task is part of a recurring series. How would you like to apply your changes?"
- `editOnlyThis`: "This instance only"
- `editThisAndFuture`: "All future instances"
- `editAllOccurrences`: "All instances"

### 6. Tests & Verification

- Unit tests in `test/domain/usecases/update_recurring_todos_test.dart` for all three edit scopes (`thisInstanceOnly`, `allFutureInstances`, `allInstances`).
- Unit tests in `test/data/repositories/time_segment_repository_impl_test.dart` or `test/domain/usecases/delete_time_segment_test.dart` verifying deletion, day-lock rejection on past days, and undo restoration.
- Widget tests for `TimeSegmentsScreen` (delete button, confirmation dialog, undo snackbar).
- Widget tests for `CreateEditTodoScreen` (recurring edit confirmation dialog with three options).
- Run `flutter analyze` (must be 0 issues) and `flutter test`.
