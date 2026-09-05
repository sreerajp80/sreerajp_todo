# Change Log: Delete Time Slots and Recurring Task Edit Options

**Date:** 2026-09-05
**Plan Reference:** [plans/20260905_054700_delete_time_slots_and_recurring_edit_options.md](plans/20260905_054700_delete_time_slots_and_recurring_edit_options.md)

## Summary of Changes

Implemented the two requested features:
1. **Delete time slots (time segments):**
   - Added the ability to delete recorded time segments on a task with a confirmation dialog.
   - Added an Undo SnackBar (5-second duration) allowing instant restoration of the deleted time segment.
   - Enforced the Hard Rule 3 Day Lock requirement (`isPastDate(todo.date)`) so that past day time segments remain immutable.
2. **Recurring task edit options:**
   - When saving an edited recurring task, a dialog prompts the user to select the edit scope:
     - **This instance only:** Detaches the modified task if recurrence changed or modifies only today's instance without altering the series.
     - **All future instances:** Updates today's instance, updates the rule, and syncs future instances (or regenerates future occurrences if the recurrence frequency changed).
     - **All instances:** Updates today's instance, past instances (metadata), and future instances along with the recurrence rule.

---

## Files Changed

### Localization
- `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`: Added localization strings for `confirmEditRecurring`, `confirmEditRecurringBody`, `editOnlyThis`, `editThisAndFuture`, `editAllOccurrences`, `deleteTimeSegment`, `confirmDeleteSegment`, `confirmDeleteSegmentBody`, and `timeSegmentDeleted`.
- `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`, `lib/l10n/app_localizations_ml.dart`: Generated localization files updated via `flutter gen-l10n`.

### Data Layer
- `lib/data/dao/todo_dao.dart`: Added `findByRecurrenceRuleId`, `findByRecurrenceRuleIdFromDate`, and `existsByRecurrenceRuleIdOnDate` to query todos by recurrence rule across dates.
- `lib/data/repositories/time_segment_repository_impl.dart`:
  - Enforced day-lock check in `deleteSegment` and `restoreSegment` throwing `DayLockedException` if parent todo is from a past date.
  - Added task history logging (`TodoHistoryEventType.edited`) on delete and restore.
- `lib/data/repositories/todo_repository_impl.dart`: Implemented `getTodosByRecurrenceRuleId`, `getTodosByRecurrenceRuleIdFromDate`, and `existsRuleInstanceOnDate`.

### Domain Layer
- `lib/domain/repositories/todo_repository.dart`: Added method signatures for querying recurring todos across dates.
- `lib/domain/usecases/generate_recurring_tasks.dart`: Added check for existing rule instance on date to prevent regenerating duplicate instances when an instance title is modified.
- `lib/domain/usecases/update_recurring_todos.dart`: Created domain usecase handling `thisInstanceOnly`, `allFutureInstances`, and `allInstances` updates.

### Application Layer
- `lib/application/time_tracking_notifier.dart`: Added `deleteSegment` and `restoreSegment` to manage segment deletion, paused state invalidation, and state refreshing.
- `lib/application/providers.dart`: Registered `updateRecurringTodosProvider`.

### Presentation Layer
- `lib/presentation/screens/time_segments/time_segments_screen.dart`:
  - Added delete button in `_SegmentTile` for non-past todos.
  - Added confirmation dialog (`confirmDeleteSegment`) and 5-second SnackBar with an `Undo` action.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`:
  - When editing a recurring task, prompts the user with an `AlertDialog` offering "This instance only", "All future instances", and "All instances".
  - Delegates to `updateRecurringTodosProvider`.

### Tests
- `test/domain/usecases/update_recurring_todos_test.dart`: Added comprehensive unit tests covering all three recurring update scopes.
- `test/domain/usecases/delete_time_segment_test.dart`: Added unit tests verifying segment deletion, restoration, and day-lock prevention on past dates.
- `test/presentation/time_segments_screen_test.dart`: Added widget tests for segment delete button, confirmation dialog, and undo snackbar.
- `test/presentation/create_edit_todo_screen_test.dart`: Added widget test verifying recurring edit prompt dialog.
- `test/presentation/copy_todos_screen_test.dart`, `test/presentation/focus_screen_test.dart`, `test/presentation/todo_list_tile_test.dart`, `test/presentation/undo_snackbar_test.dart`: Updated mock repository signatures.

---

## Verification

- `flutter analyze`: 0 issues found.
- `flutter test`: All 656 unit and widget tests passed.
