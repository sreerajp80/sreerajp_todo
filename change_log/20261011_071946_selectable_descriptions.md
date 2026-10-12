# Make descriptions selectable

Implements plan: `plans/20261011_071349_selectable_descriptions.md`

## What changed

The full description on detail screens can now be selected and copied
(long-press, then drag the handles or tap Copy). Each `Text` widget was
replaced with `SelectableText`, with the same style and alignment. The
`AdaptiveDirectionality` wrapper is kept, so right-to-left text still shows
correctly.

| File | Text made selectable |
|------|----------------------|
| `lib/presentation/screens/time_segments/time_segments_screen.dart` | Todo description in the header |
| `lib/presentation/screens/task_history/task_history_screen.dart` | Todo description in the summary card |
| `lib/presentation/screens/focus/focus_screen.dart` | Todo description under the title |
| `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart` | Deck description in the header |

## Not changed (on purpose)

The short previews in tappable list rows (Copy Todos, Search Results, the
Mastery Deck list) stay as plain text. Making them selectable would stop the
row tap from working.

## Checks

- `dart format`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 864 tests passed.
