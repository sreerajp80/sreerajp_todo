# Refresh Mastery Deck screen after a task changes

Implements plan: `plans/20260927_214313_refresh_mastery_deck_after_todo_changes.md`

## Problem

After moving, completing, editing (and so on) a deck task from the daily list,
the Mastery Deck screen kept showing old data. The user had to open and close
the task to see the change. Saving an edit only refreshed the deck selected on
the form, so a deck the task had just left was never refreshed.

## What changed

- `lib/application/providers.dart`
  - The daily list's `onDataChanged` callback now also refreshes every deck
    (`masteryDeckTodosProvider` and `masteryDeckProgressProvider`, whole family).
  - The `onTimerStopped` callback also refreshes every deck, so a deck task's
    status is correct right after its timer stops.
- `lib/application/daily_todo_notifier.dart`
  - `onDataChanged` is now called after create, update, complete, SRS complete,
    drop, reopen, the three bulk actions, and both undo paths. Before, only
    move and delete called it. The statistics screen also stays fresh now.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
  - On save, every deck is refreshed instead of only the selected one. This
    covers moving a task between decks, removing it from a deck, and editing
    a repeating task (which does not go through the daily list notifier).
    The refresh runs as soon as the save succeeds, before the screen closes.

## Tests

- New `test/application/mastery_deck_refresh_test.dart`: moving, completing
  and editing a deck task through the daily list notifier updates the cached
  deck task list.
- `test/presentation/create_edit_todo_screen_test.dart`: new test that saving
  an edit refreshes a deck the task is no longer in.
- `flutter analyze`: no issues. `flutter test`: all tests pass.
