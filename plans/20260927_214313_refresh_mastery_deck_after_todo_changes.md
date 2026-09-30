# Refresh Mastery Deck screen after a task changes on the daily list

**Status:** completed

## Issue

When the user moves a task to another date from the daily todo list and then goes
back to the Mastery Deck screen, the task still shows the old date. The user has to
open the task and close it again before the new date shows.

## Cause

`masteryDeckTodosProvider` and `masteryDeckProgressProvider` in
`lib/application/providers.dart` are plain (cached) `FutureProvider.family`
providers. They load once and keep their result. The daily list uses
`DailyTodoNotifier`, which never tells these providers that data changed. Only the
Mastery Deck screen itself invalidates them (for example when the edit screen
closes), which is why "open and close" works as a workaround.

The same stale data also happens after other daily-list actions on a deck task:
complete, drop, reopen, undo, delete, and edit.

### What happens when a task is edited and saved (checked)

The save code is in `create_edit_todo_screen.dart` (`_onSave`). After saving it
refreshes **only the deck that is selected on the form**. This leaves gaps:

1. **Deck changed or removed.** If the task was in deck A and the user moves it to
   deck B, or removes the deck, deck A is never refreshed. Deck A keeps showing
   the task until the user opens and closes something on the deck screen.
2. **Edited from the daily list.** The deck screen only refreshes itself when the
   edit screen was opened *from the deck screen*. When the edit is done from the
   daily list, only the "selected deck" refresh above runs, so gap 1 shows up.
3. **Recurring task edit** ("this and future" / "all"). Many tasks are updated,
   but again only the selected deck is refreshed, and the daily list's change
   callback is not called.
4. **Port (move) from the edit screen's status menu.** This goes through
   `DailyTodoNotifier.portTodo` → `moveTodo`, so the fix below covers it.
5. The date field is only shown when creating a task, so an edit cannot change
   the date in any other way.

## Files to change

- `lib/application/providers.dart`
- `lib/application/daily_todo_notifier.dart`
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
- `test/application/` — add or extend a notifier test (see Tests below)

## Fix plan

1. In `providers.dart`, inside the `onDataChanged` callback of `dailyTodoProvider`,
   also invalidate the whole `masteryDeckTodosProvider` family and the whole
   `masteryDeckProgressProvider` family. (Invalidating a family with no argument
   refreshes every deck at once.)
2. In `daily_todo_notifier.dart`, call `onDataChanged?.call()` after every data
   change that can affect a deck task, not only move/delete:
   `createTodo`, `updateTodo`, `markCompleted`, `markSrsCompleted`, `markDropped`,
   `reopenTodo`, the three bulk actions, and both branches of
   `undoLastStatusChange`. (Move and delete already call it.)
   This also keeps the statistics screen fresh after status changes, which is a
   small bonus.
3. In `create_edit_todo_screen.dart` `_onSave`, replace the "refresh only the
   selected deck" block with a refresh of the **whole**
   `masteryDeckTodosProvider` and `masteryDeckProgressProvider` families. It
   runs right after the save succeeds (before the screen closes), for create,
   normal edit and recurring edit. This fixes gaps 1–3: the old deck, the new
   deck and "no deck" are all correct as soon as the task is saved.
4. Also refresh both families in the `onTimerStopped` callback, so a deck task's
   status is right after its timer stops from the daily list.
5. No change to the layer rules: the notifier still only calls a callback; the
   provider file decides what to refresh.

## Tests

- Add a unit test that builds `DailyTodoNotifier` with a counting `onDataChanged`
  callback and checks it is called after `moveTodo`, `markCompleted`,
  `markDropped`, `reopenTodo`, and `updateTodo` (using the existing mocktail
  repository/use-case mocks).
- Add a widget test in `test/presentation/create_edit_todo_screen_test.dart`:
  edit a deck task, change its deck, save, and check that the old deck's
  `masteryDeckTodosProvider` is re-read.
- Run `flutter analyze` and `flutter test`.
