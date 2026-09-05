# Change Log: Fix SnackBar Queue Delay And Outdated Feedback Messages

**Date:** 2026-09-05
**Plan Reference:** [plans/20260905_064200_fix_snackbar_queue_delay.md](plans/20260905_064200_fix_snackbar_queue_delay.md)

## Summary of Changes

Fixed the issue where doing multiple task operations in quick succession caused messages to queue up and delayed the task status change SnackBar and its Undo button:

1. **SnackBar Queue Purging (`clearSnackBars`)**:
   - In `showUndoSnackBar()`, replaced `hideCurrentSnackBar()` with `clearSnackBars()`. This ensures that when a task status changes (e.g. marked as completed or dropped), any queued messages from earlier operations (such as deleting recurring tasks or creating a task) are immediately purged and the current message is dismissed.
   - The undo message with its action button now appears immediately without having to wait through previous messages.

2. **Shared Feedback Helper (`showAppSnackBar`)**:
   - Added `showAppSnackBar(BuildContext context, ...)` in `undo_status_snackbar.dart` that calls `clearSnackBars()` before displaying informational notices.
   - Configured a concise default duration of 2 seconds for transient feedback so that messages do not linger unnecessarily, while undoable status messages maintain their full 5-second window (`kUndoTimeoutSeconds`).

3. **Updated Feedback Callers Across Screens**:
   - In `daily_list_screen.dart`, updated recurring task deletion, single task deletion, auto carry-over, manual carry-over, AirQR sync, move, error, and persistent undo button taps to clear queued messages.
   - In `create_edit_todo_screen.dart`, updated task creation, task update, and task port feedback to clear queued messages.
   - In `timer_controls.dart`, cleared queued messages before showing timer takeover and discarded segment notices.
   - In `todo_list_tile.dart`, cleared queued messages before displaying the blocked task warning.
   - In `backup_screen.dart`, `pending_todos_alert_sheet.dart`, `evening_reflection_modal.dart`, and `copy_todos_screen.dart`, replaced lingering queue calls with `clearSnackBars()`.

4. **Testing & Verification**:
   - Added widget tests in `test/presentation/undo_snackbar_test.dart` verifying that `showUndoSnackBar` and `showAppSnackBar` immediately clear older queued messages and show the newest message right away.
   - Ran static analysis (`flutter analyze`): 0 issues found.
   - Ran full test suite (`flutter test`): All 662 tests passed.

---

## Files Changed

### Presentation Layer
- `lib/presentation/shared/widgets/undo_status_snackbar.dart`: Replaced `hideCurrentSnackBar()` with `clearSnackBars()` in `showUndoSnackBar`; added `showAppSnackBar` helper with concise 2-second default duration.
- `lib/presentation/shared/widgets/timer_controls.dart`: Added `clearSnackBars()` before timer takeover and discarded segment notifications.
- `lib/presentation/screens/daily_list/daily_list_screen.dart`: Updated delete, carry-over, error, and undo notices to use `showAppSnackBar`.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`: Updated create, edit, port, and error notices to use `showAppSnackBar`.
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`: Updated blocked task warning to use `showAppSnackBar`.
- `lib/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart`: Added `clearSnackBars()` before displaying messages.
- `lib/presentation/screens/daily_list/widgets/evening_reflection_modal.dart`: Added `clearSnackBars()` before showing reflection confirmation.
- `lib/presentation/screens/copy_todos/copy_todos_screen.dart`: Added `clearSnackBars()` before showing copy errors.
- `lib/presentation/screens/backup/backup_screen.dart`: Changed `hideCurrentSnackBar()` to `clearSnackBars()`.

### Tests
- `test/presentation/undo_snackbar_test.dart`: Added widget tests for queue clearing on `showUndoSnackBar` and `showAppSnackBar`.

---

## Verification

- `dart format lib/ test/`: Formatted 3 files.
- `flutter analyze`: Completed with 0 issues found.
- `flutter test test/presentation/undo_snackbar_test.dart`: 7/7 tests passed.
- `flutter test`: 662/662 tests passed.
