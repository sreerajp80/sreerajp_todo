# Task History Creation Time and Moved Time for Moved Tasks

**Status:** Implemented  
**Plan reference:** `plans/20260829_202000_task_history_creation_time_for_moved_tasks.md`  

---

## Summary of Changes

1. **Repository Layer (`lib/data/repositories/todo_repository_impl.dart`)**:
   - Updated `moveTodo` to persist the initial date in `sourceDate` (`todo.sourceDate ?? fromDate`).
   - Updated `getHistoryForTodo` so that any synthesized creation history event retains the original creation timestamp (`todo.createdAt`) and formats the description with the original source date (`todo.sourceDate ?? todo.date`).
   - Ensured the `moved` event records the exact time the move happened.

2. **Presentation Layer (`lib/presentation/screens/task_history/task_history_screen.dart`)**:
   - Updated the task summary card to display an original source date indicator (`Task moved: <originalDate>`) when viewing history for a moved task.
   - Preserved timeline chronological rendering where "Task Created" shows the original creation time, "Task Moved" shows the moved time, and all subsequent events show their respective execution times.

3. **Tests**:
   - Added unit test in `test/domain/usecases/move_todo_test.dart` verifying that moved task history retains the original creation time for the created event and records the moved timestamp for the move event.
   - Added widget test in `test/presentation/task_history_screen_test.dart` verifying the display of moved task history with original creation timestamp and source date indicator.
   - Verified that all 625 unit and widget tests pass and `flutter analyze` reports 0 issues.
