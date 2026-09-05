# Fix SnackBar Queue Delay And Outdated Feedback Messages

**Status:** completed

## The issue

When a user performs several actions in quick succession:
1. Deletes all occurrences of a recurring task.
2. Creates a new recurring task.
3. Starts the timer on today's instance.
4. Marks the instance as completed.

The feedback messages appear very late and in a slow sequence:
- The user first sees the delete message.
- Then the task creation message.
- Then the timer starting message.
- Finally, the task completion message with the Undo button appears long after the task was marked completed.

Why this happens:
- Flutter's `ScaffoldMessenger` maintains an internal FIFO (first-in, first-out) queue of SnackBars.
- Each normal SnackBar stays on screen for 4 seconds by default.
- When an action triggers `showSnackBar()`, it is added to the back of the queue instead of replacing older messages.
- Even `showUndoSnackBar` was using `hideCurrentSnackBar()`, which only dismisses the active message but leaves the rest of the queue intact.
- As a result, the user must wait through all previous messages (over 12 seconds) before the Undo button for the completed task appears. This makes reverting changes slow and shows obsolete messages for tasks that are already finished.

## Files to change

- `lib/presentation/shared/widgets/undo_status_snackbar.dart`:
  - Replace `hideCurrentSnackBar()` with `clearSnackBars()` in `showUndoSnackBar()`.
  - Add `showAppSnackBar()` helper that calls `clearSnackBars()` before displaying a message with a concise duration (2 seconds by default).
- `lib/presentation/screens/daily_list/daily_list_screen.dart`:
  - Ensure task deletion, moving, porting, persistent undo button, and error messages clear previous SnackBars so messages never queue up.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`:
  - Use `clearSnackBars()` for task creation, update, and port feedback so messages appear immediately upon saving.
- `lib/presentation/shared/widgets/timer_controls.dart`:
  - Clear queued SnackBars before showing timer take-over or discarded segment notices.
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`:
  - Clear queued SnackBars before showing the blocked task warning.
- `test/presentation/undo_snackbar_test.dart`:
  - Add tests verifying that `showUndoSnackBar` and immediate SnackBars clear previously queued messages without delay.

## The fix

1. **Clear queued SnackBars on every status and feedback action:**
   Use `ScaffoldMessenger.of(context).clearSnackBars()` before `showSnackBar()`. This purges all pending messages in the queue and immediately dismisses the active message.
2. **Immediate Undo availability:**
   When a user marks a task completed (or changes its status), `clearSnackBars()` ensures the Undo SnackBar appears instantly. The user does not have to wait to revert their action.
3. **Shorter display duration for transient messages:**
   Informational notices (like "Task created" or "Occurrences deleted") use a concise 2-second duration so they do not linger, while undoable actions keep the full 5-second window required for user safety.

## Verification

- Run unit and widget tests: `flutter test test/presentation/undo_snackbar_test.dart`
- Run full test suite: `flutter test`
- Run static analysis: `flutter analyze`
