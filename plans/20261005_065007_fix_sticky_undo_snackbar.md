# Fix the "Status changed to …" SnackBar that never goes away

**Status:** completed

## What the issue is

1. On the day list, the user marks a task Completed (or Dropped, or Reopened).
   The app shows "Status changed to Completed" with an **Undo** button.
2. The user then taps **+** to create a new task. The same message is still on
   screen in the New Todo window, and it never goes away by itself. The only way
   to remove it is to swipe it down.

There are two causes:

- **The message never times out.** In the Flutter version we use (3.44), a
  SnackBar that has an action button (like Undo) stays on screen until it is
  closed. Flutter's `SnackBar.persist` setting is `true` by default whenever an
  action is present, so our `duration: 5 seconds` is ignored. This also breaks
  the project rule "SnackBar with 5-second timeout".
- **The message follows the user to other screens.** SnackBars belong to the
  app-wide `ScaffoldMessenger`, so a message from the day list stays visible
  after moving to the New Todo / Edit Todo screen, where it makes no sense.

Also, `showUndoSnackBar` sets `showCloseIcon: false`, so there is no close (X)
button.

## Plan for the fix

1. `lib/presentation/shared/widgets/undo_status_snackbar.dart`
   - `showUndoSnackBar`: add `persist: false` so it hides after 5 seconds,
     and turn on the close (X) button (`showCloseIcon: true`). Keep the Undo
     button on the same line as the message.
   - `showAppSnackBar`: add `persist: false` and `showCloseIcon: true` when an
     action is passed, so action SnackBars also time out and can be closed.
   - Add a small helper `hideAppSnackBars(BuildContext context)` that removes
     any visible SnackBar.
2. `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
   - When the screen opens, call `hideAppSnackBars` (after the first frame),
     so a message from the previous screen never shows on New Todo / Edit Todo.
   - The persistent app-bar Undo button on the day list is not changed, so the
     user can still undo after the SnackBar is gone.
3. Other SnackBars with an Undo/Retry action get the same `persist: false`
   and close button, so they also time out:
   - `lib/presentation/shared/widgets/timer_controls.dart`
   - `lib/presentation/screens/time_segments/time_segments_screen.dart`
   - `lib/presentation/screens/backup/backup_screen.dart`
4. Tests — `test/presentation/undo_snackbar_test.dart`
   - Add a test: the undo SnackBar shows a close button and is gone after
     5 seconds.
   - Add a test: tapping the close button hides it.

No new text is added, so no ARB changes are needed (the close button uses
Flutter's built-in localized "Close" label).

## Files to be changed

- `lib/presentation/shared/widgets/undo_status_snackbar.dart`
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
- `lib/presentation/shared/widgets/timer_controls.dart`
- `lib/presentation/screens/time_segments/time_segments_screen.dart`
- `lib/presentation/screens/backup/backup_screen.dart`
- `test/presentation/undo_snackbar_test.dart`
- `change_log/<timestamp>_fix_sticky_undo_snackbar.md` (new)

## Checks

- `dart format`, `flutter analyze` (0 issues), `flutter test`.
