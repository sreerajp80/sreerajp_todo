# Fix Task Copy / Port Not Showing on Target Date

**Status:** Complete

## Context & Problem
When copying or moving tasks from one day (e.g. August 27th) to another day (e.g. August 28th) using the Copy Wizard or Port action:
1. The tasks are correctly inserted into the SQLite database for the target date.
2. The user sees a success message (e.g., "X tasks copied" or "Task ported").
3. However, when opening or navigating to the target date (August 28th), the copied/ported tasks do not appear.
4. This happens because `dailyTodoProvider` is a cached `StateNotifierProvider.family`. If the target date was already visited or initialized earlier in the session, its in-memory state remains stale because `dailyTodoProvider(targetDate)` is never invalidated or refreshed after the copy/port operation.

## Proposed Changes

### Presentation Layer
#### [lib/presentation/screens/daily_list/daily_list_screen.dart](lib/presentation/screens/daily_list/daily_list_screen.dart)
- In `_openCopyWizard`: Invalidate `dailyTodoProvider` for each target date present in `result.copied` (`for (final date in result.copied.map((e) => e.date).toSet()) ref.invalidate(dailyTodoProvider(date));`).
- In `_showPortDatePicker`: Invalidate `dailyTodoProvider(targetDate)` upon successful porting and upon undoing.
- In `_DailyListScreenState.initState`: Trigger `loadTodos()` on post frame callback to ensure the list is always fresh from SQLite when visiting a date.
- In `_DailyListScreenState.didUpdateWidget`: If `oldWidget.date != widget.date`, trigger `loadTodos()` for the new date.

#### [lib/presentation/screens/copy_todos/copy_todos_screen.dart](lib/presentation/screens/copy_todos/copy_todos_screen.dart)
- In `_executeCopy`: Invalidate `ref.invalidate(dailyTodoProvider(_targetDate!))` before popping the result.

#### [lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart](lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart)
- In port handler: Invalidate `ref.invalidate(dailyTodoProvider(targetDate))`.

#### [lib/presentation/screens/ritual/widgets/ritual_settle_step.dart](lib/presentation/screens/ritual/widgets/ritual_settle_step.dart)
- In `_carryOver`: Invalidate `dailyTodoProvider(widget.date)`.

### Tests
- Update/add widget and unit tests in `test/` ensuring target date provider invalidation and freshness on navigation.

## Verification Plan
1. Run `flutter analyze` to ensure zero issues.
2. Run `flutter test` to ensure all existing and new tests pass.
3. Validate copy and port workflows across dates.
