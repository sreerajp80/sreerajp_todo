# Change Log: Mastery Deck Manual Todos & Tag Grouping

**Plan Reference:** `plans/20260912_092200_mastery_deck_todos_grouping.md`  
**Date:** 2026-09-12  

## Overview
Updated the Mastery Deck feature so that creating a deck only creates the deck itself (no automatic todo is generated). Users can now create and associate multiple daily todos under any mastery deck. In the daily todo list screen, these tasks display a mastery deck tag chip and can be filtered by deck. The mastery deck screen and detail screen show overall progress, task counts, and completion status.

## Changes Made

### 1. Data & Domain Layer
- `lib/data/dao/todo_dao.dart`:
  - Added `findBySpacedRepetitionItemId(String spacedRepetitionItemId)` to fetch all todos linked to a specific mastery deck.
- `lib/domain/repositories/todo_repository.dart` & `lib/data/repositories/todo_repository_impl.dart`:
  - Added and implemented `getTodosByMasteryDeckId(String deckId)`.
- `lib/domain/usecases/generate_spaced_repetition_tasks.dart`:
  - Disabled automatic background generation of daily tasks for spaced repetition / mastery decks so that deck creation does not generate any tasks automatically.

### 2. Application Layer
- `lib/application/providers.dart`:
  - Created `MasteryDeckProgress` model holding `totalTasks`, `completedTasks`, `workingTasks`, `pendingTasks`, `droppedTasks`, `completionRatio`, and `totalTrackedSeconds`.
  - Added `allMasteryDecksProvider` and `allMasteryDecksMapProvider` for fast lookup of deck titles.
  - Added `masteryDeckTodosProvider(deckId)` and `masteryDeckProgressProvider(deckId)` for calculating overall progress.

### 3. Navigation & Routing
- `lib/core/constants/app_routes.dart`:
  - Added `masteryDeckDetail` route (`/mastery-deck/:id`) and `masteryDeckDetailPath(id)`.
  - Added optional `masteryDeckId` query parameter to `createTodoPath`.
- `lib/app.dart`:
  - Registered route for `MasteryDeckDetailScreen`.
  - Added support for preselecting a mastery deck via query parameter when opening `CreateEditTodoScreen`.

### 4. Localization
- `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`:
  - Added localization strings for mastery deck titles, subtitles, empty states, overall progress, and task counters.
  - Generated localization files using `flutter gen-l10n`.

### 5. Presentation Layer
- `lib/presentation/screens/mastery_deck/mastery_deck_screen.dart`:
  - Updated creation dialog to only create the deck (without creating a task).
  - Designed `_MasteryDeckCard` showing deck title, description, progress percentage, progress bar, task counters, and total time spent.
  - Added tap navigation on cards to the detail screen.
- `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart` (New):
  - Displays deck header, overall progress summary card with completion percentage and task breakdown badges.
  - Lists child todos with their current status, duration, and target times.
  - Provides a "+ Add Task to Deck" button to quickly create a new todo linked to this deck.
- `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`:
  - Added a Mastery Deck selector chip row allowing users to link a task to any deck.
  - Preserves selected deck when creating or updating tasks.
- `lib/presentation/screens/daily_list/daily_list_screen.dart`:
  - Added horizontal mastery tag filter chips above the daily list when tagged tasks exist.
  - Allows filtering daily tasks by mastery deck.
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`:
  - Added `#DeckName` tag badge in the task tile metadata row with tap interaction opening the deck details.

### 6. Testing & Quality Assurance
- `test/data/todo_dao_test.dart`:
  - Added unit test verifying `findBySpacedRepetitionItemId`.
- `test/presentation/mastery_deck_test.dart`:
  - Added widget tests for empty state, deck cards with progress calculation, deck detail screen with child todos, and todo list tile mastery tag badge rendering.
- Code analysis with `flutter analyze` completed with 0 warnings.
