# Remove duplicate comment in create/edit todo screen

**Status:** completed

## Files to change

- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`

## Issue

In the save flow, the same two-line comment appears twice in a row (around lines 495–498):

```dart
// Refresh every deck, not only the selected one: the task may have left
// an old deck, or a recurring edit may have touched several tasks.
// Refresh every deck, not only the selected one: the task may have left
// an old deck, or a recurring edit may have touched several tasks.
```

## Fix

Delete the second copy of the two lines. Keep one copy. No code or behavior changes.

## Checks

- `dart format` on the file.
- `flutter analyze` (expect 0 issues). No tests needed, since only a comment changes.
