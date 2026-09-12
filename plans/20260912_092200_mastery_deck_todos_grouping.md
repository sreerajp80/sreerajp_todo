# Implementation Plan — Mastery Deck Correction, Todos Under Deck & Tag Grouping

**Status:** Proposed (Awaiting User Approval)

## Overview
Correct the Mastery Deck system so that:
1. Creating a mastery deck creates only the deck itself without automatically creating any todo.
2. The user can create multiple different todos under that deck to work toward mastering it.
3. In the daily todo screen, todos belonging to a mastery deck are tagged and grouped with their mastery deck name as tags.
4. Each mastery deck card in the Mastery Deck screen displays the overall progress across all its todos (completion percentage, progress bar, and status counts).
5. Tapping on a mastery deck card opens a deck detail view listing all its todos with their progress indication and status, and lets the user add new todos under that deck.

---

## Issue / Problem
1. **Unwanted Automatic Todo Creation:** Currently, creating a mastery item calls `GenerateSpacedRepetitionTasks`, which immediately creates a daily todo with the deck's title in today's task list.
2. **Missing Deck-to-Todos Hierarchy:** The user cannot create multiple different tasks under a single mastery deck.
3. **No Overall Progress on Mastery Cards:** The mastery deck screen lists items with level badges, but does not calculate or display overall progress across child todos.
4. **Missing Mastery Tagging / Grouping on Daily List:** The daily todo screen does not show which mastery deck a task belongs to as a tag, nor does it allow grouping or filtering by mastery tag.
5. **No Deck Detail Screen:** Tapping a mastery deck item does not open a view showing all child todos and their statuses.

---

## Proposed Fix & Architecture

### 1. Data Layer (`lib/data/`)
- **`TodoDao` (`lib/data/dao/todo_dao.dart`)**:
  - Add `findBySpacedRepetitionItemId(String deckId)` to retrieve all todos linked to a specific mastery deck, ordered by date descending and sort order.
- **`TodoRepository` & `TodoRepositoryImpl` (`lib/domain/repositories/todo_repository.dart`, `lib/data/repositories/todo_repository_impl.dart`)**:
  - Expose `Future<List<TodoEntity>> getTodosByMasteryDeckId(String deckId)`.

### 2. Application Layer (`lib/application/`)
- **Mastery Providers (`lib/application/providers.dart`)**:
  - `masteryDeckTodosProvider(String deckId)`: `FutureProvider.family` that loads all `TodoEntity` items under `deckId`.
  - `masteryDeckProgressProvider(String deckId)`: Computes overall progress for a deck:
    - Total todos count.
    - Completed count.
    - Progress ratio (`0.0` to `1.0`).
    - Counts by status (pending, working, completed, dropped).
    - Total time tracked across all todos in the deck.
  - `allMasteryDecksMapProvider`: Provides a fast `Map<String, String>` (deck ID -> deck title) for displaying mastery tags on todo tiles without querying the database repeatedly.

### 3. Presentation Layer (`lib/presentation/`)

#### A. Mastery Deck Screen (`lib/presentation/screens/mastery_deck/mastery_deck_screen.dart`)
- Update create deck dialog:
  - Title: "New Mastery Deck".
  - Input: Deck Title and Description.
  - On create: Inserts `SpacedRepetitionItemEntity`. **Does not create any todo.**
- Replace simple list items with rich **Mastery Deck Cards**:
  - Deck title and description.
  - Progress indicator bar and completion percentage (e.g. `60%`, `3 of 5 completed`).
  - Status breakdown chips (`Pending`, `Working`, `Completed`).
  - Total time tracked on the deck.
  - Tapping card opens the Mastery Deck Detail screen.

#### B. Mastery Deck Detail Screen (`lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart`) [NEW]
- Route: `/mastery-deck/:id`.
- Header:
  - Deck title, description.
  - Overall progress ring/bar with percentage and stats summary.
- List of todos under this deck:
  - Displays each todo's title, scheduled date, status badge (`Pending`, `Working`, `Completed`, `Dropped`, `Ported`), and progress indication (time tracked, target time, subtask count, completion toggle).
  - Tapping a todo allows editing or marking status.
- Action:
  - Floating action button / button to "Add Todo to Deck", opening `CreateEditTodoScreen` with `initialMasteryDeckId` prefilled, or a quick-add dialog.

#### C. Daily Todo List Screen (`lib/presentation/screens/daily_list/`)
- **`TodoListTile` (`lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`)**:
  - When `todo.spacedRepetitionItemId != null`, display a tag chip: `🏷️ #<Mastery Name>` in the metadata wrap.
  - Tapping the tag opens the Mastery Deck Detail screen for that deck.
- **`DailyListScreen` (`lib/presentation/screens/daily_list/daily_list_screen.dart`)**:
  - When the daily list contains todos associated with mastery decks, show a horizontal Tag Filter bar under the header (`All`, `#DeckName1`, `#DeckName2`), allowing users to easily view todos grouped by mastery tag.

#### D. Create / Edit Todo Screen (`lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`)
- Add `initialMasteryDeckId` parameter.
- Add an optional "Mastery Deck" picker field so users can assign a todo to any existing mastery deck (or create one).

#### E. Routing & Navigation (`lib/core/constants/app_routes.dart`, `lib/app.dart`)
- Add `AppRoutes.masteryDeckDetail` (`/mastery-deck/:id`).
- Register route in `lib/app.dart`.

#### F. Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`)
- Add keys for "New Mastery Deck", "Mastery Progress", "Tasks Completed", "Add Todo to Deck", "No tasks in this deck yet", "Mastery Deck Tags", etc.
- Run `flutter gen-l10n`.

---

## Files to Modify / Create

### [NEW]
- `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart`
- `test/presentation/screens/mastery_deck/mastery_deck_detail_screen_test.dart`

### [MODIFY]
- `lib/core/constants/app_routes.dart`
- `lib/app.dart`
- `lib/data/dao/todo_dao.dart`
- `lib/domain/repositories/todo_repository.dart`
- `lib/data/repositories/todo_repository_impl.dart`
- `lib/application/providers.dart`
- `lib/presentation/screens/mastery_deck/mastery_deck_screen.dart`
- `lib/presentation/screens/daily_list/daily_list_screen.dart`
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ml.arb`
- `test/data/dao/todo_dao_test.dart`
- `test/presentation/screens/mastery_deck/mastery_deck_screen_test.dart`

---

## Verification Plan

### Automated Tests
1. Run `flutter test test/data/dao/todo_dao_test.dart` to verify `findBySpacedRepetitionItemId`.
2. Run `flutter test test/presentation/screens/mastery_deck/` to verify deck cards, progress calculation, and detail screen listing.
3. Run `flutter analyze` to ensure 0 warnings and clean code standard compliance.
4. Run full test suite `flutter test` to prevent any regressions.

### Manual Verification
1. Open Mastery Deck screen (`/mastery-deck`).
2. Create a new Mastery Deck ("Learn Dart"). Confirm NO todo is added to today's daily list.
3. Tap on the "Learn Dart" card. Verify the detail screen opens and indicates 0 tasks and 0% progress.
4. Tap "+ Add Todo" inside the deck detail screen. Add "Async programming".
5. Navigate to the Daily List. Verify "Async programming" displays a tag chip with `#Learn Dart`.
6. Use the Mastery tag filter on the daily list to filter tasks by deck tag.
7. Complete "Async programming". Return to Mastery Deck screen and confirm the card shows updated progress (1 of 1 completed, 100% progress).
