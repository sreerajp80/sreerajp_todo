# Fix the "Status changed to …" SnackBar that never goes away

Implements plan: `plans/20261005_065007_fix_sticky_undo_snackbar.md`

## What was wrong

- In Flutter 3.44, a SnackBar with an action button (Undo, Retry) stays on
  screen until it is closed (`SnackBar.persist` is `true` by default when an
  action is set). Our 5-second timeout was ignored.
- The SnackBar from the day list stayed visible after opening the New Todo /
  Edit Todo screen.
- The Undo SnackBar had no close (X) button.

## What changed

- `lib/presentation/shared/widgets/undo_status_snackbar.dart`
  - `showUndoSnackBar`: `persist: false` (closes after `kUndoTimeoutSeconds`)
    and `showCloseIcon: true`. Right padding removed, since the close button
    has its own space.
  - `showAppSnackBar`: `persist: false`; shows the close button when an action
    is given.
  - New helper `hideAppSnackBars(context)` that clears any SnackBar.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`:
  clears leftover SnackBars after the first frame when the screen opens.
- `lib/presentation/shared/widgets/timer_controls.dart`,
  `lib/presentation/screens/time_segments/time_segments_screen.dart`,
  `lib/presentation/screens/backup/backup_screen.dart`: SnackBars with
  Undo/Retry now use `persist: false` and show a close button.
- `test/presentation/undo_snackbar_test.dart`:
  - The auto-dismiss test now checks that the SnackBar is really gone after
    the timeout.
  - New test: the close button hides the Undo SnackBar.
  - New test: `hideAppSnackBars` removes a visible SnackBar.

The persistent app-bar Undo button on the day list is unchanged.
No ARB changes: the close button uses Flutter's built-in "Close" label.

## Checks

- `dart format`: done.
- `flutter analyze`: no issues.
- `flutter test`: all 833 tests passed.
