# Remove duplicate comment in create/edit todo screen

Implements plan: `plans/20260928_101116_remove_duplicate_comment.md`

## What changed

- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`: removed the
  second copy of a two-line comment ("Refresh every deck, not only the selected one ...")
  that appeared twice in a row in the save flow. One copy remains.

## Behavior

No behavior change. Only a comment was removed.

## Checks

- `dart format`: no changes needed.
- `flutter analyze` on the file: no issues.
