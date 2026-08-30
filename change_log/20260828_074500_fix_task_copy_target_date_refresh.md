# Change Log: Fix Task Copy and Port Target Date Refresh

**Date:** 2026-08-28 07:45:00  
**Plan:** `plans/20260828_073700_fix_task_copy_target_date_refresh.md`

## Summary of Changes
Fixed an issue where tasks copied or ported to another date (such as moving tasks from August 27th to August 28th) did not immediately display on the target date screen until restarting the application.

## Detailed Changes

### Presentation Layer
- `lib/presentation/screens/daily_list/daily_list_screen.dart`:
  - Added target date cache invalidation in `_openCopyWizard` for each copied task's target date.
  - Added target date cache invalidation in `_showPortDatePicker` upon porting and undoing a port.
  - Ensured `DailyListScreen.initState` and `didUpdateWidget` trigger `loadTodos()` on post-frame callback so switching between dates always refreshes from SQLite.
- `lib/presentation/screens/copy_todos/copy_todos_screen.dart`:
  - Added `ref.invalidate(dailyTodoProvider(_targetDate!))` in `_executeCopy` prior to popping back to ensure any active or cached provider updates immediately.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`:
  - Added `ref.invalidate(dailyTodoProvider(targetDate))` when porting a task from the edit screen.
- `lib/presentation/screens/ritual/widgets/ritual_settle_step.dart`:
  - Added `ref.invalidate(dailyTodoProvider(widget.date))` after carrying over leftover tasks.

### Tests
- Added `test/presentation/copy_todos_screen_test.dart` to verify copy selection and interaction workflows.
- Ran static analysis (`flutter analyze`: 0 issues) and full test suite (`flutter test`: 612 passed).
