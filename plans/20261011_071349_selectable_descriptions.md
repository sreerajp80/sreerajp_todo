# Make descriptions selectable

**Status:** completed

## Issue

On detail screens, the todo description (and the Mastery Deck description) is
shown with a plain `Text` widget. Users cannot long-press to select or copy it.
This is a problem for long descriptions that the user wants to reuse.

## Scope

Change only the places where the **full** description is shown as read-only
detail text:

| File | Widget shown |
|------|--------------|
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | Todo description in the header |
| `lib/presentation/screens/task_history/task_history_screen.dart` | Todo description in the summary card |
| `lib/presentation/screens/focus/focus_screen.dart` | Todo description under the title (centered) |
| `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart` | Deck description in the header |

**Not changed (on purpose):** list rows that show a short, cut-off preview
(1–2 lines) and react to a tap:

- `copy_todos/copy_todos_screen.dart` (tap toggles the checkbox)
- `search_results/search_results_screen.dart` (tap opens the todo)
- `mastery_deck/mastery_deck_screen.dart` (tap opens the deck)

A selectable text widget there would take the tap and long-press for
itself. Tapping the row would then stop working, and only the first
line could be copied anyway. The user can open the detail screen and
copy from there.

The edit screen already uses a text input box, so it is already selectable.

## Fix

In each file listed above, replace `Text(description, style: ...)` with
`SelectableText(description, style: ..., textAlign: ...)`, and keep the same
style and alignment. Keep the existing `AdaptiveDirectionality` wrapper, so
right-to-left text still shows correctly.

No new strings, no ARB changes, no logic changes, no layer changes (presentation
only).

## Verification

- `dart format` on the changed files.
- `flutter analyze` → 0 issues.
- `flutter test` → all pass. If any widget test finds the description in a
  way that `SelectableText` breaks, update that test.

## Change log

Write `change_log/<timestamp>_selectable_descriptions.md` after implementing.
