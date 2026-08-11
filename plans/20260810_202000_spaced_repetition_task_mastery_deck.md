# Implementation Plan — Spaced Repetition Task Mastery Deck (Anki-Style Habit & Skill Engine)

**Status:** Proposed (Awaiting User Approval)

## Overview
Implement an Anki-style Spaced Repetition Task Deck (SM-2 algorithm) for recurring maintenance, study, or skill-building tasks. Tasks tagged with `#mastery` or `#spaced-repetition` (or created via the Mastery Deck UI) auto-schedule review dates dynamically based on recall confidence ratings (**Hard**, **Revision**, **Easy**).

---

## Issue / Problem
Currently, repeating tasks only support static calendar schedules (e.g. every N days or RRULE). Users studying topics, practicing skills, or retaining stotras/maintenance routines are forced to adhere to fixed schedules regardless of memory retention. This causes burnout on easy items and insufficient practice on difficult ones.

---

## Proposed Fix & Architecture

### 1. Data & Database Layer (Migration V6)
- **Increment `kDatabaseVersion`** from 5 to 6 in `lib/core/constants/app_constants.dart`.
- **Create `migration_v6.dart`**:
  - Add table `spaced_repetition_items`:
    - `id` TEXT PRIMARY KEY
    - `title` TEXT NOT NULL UNIQUE
    - `description` TEXT
    - `level` INTEGER NOT NULL DEFAULT 1
    - `ease_factor` REAL NOT NULL DEFAULT 2.5
    - `interval_days` INTEGER NOT NULL DEFAULT 1
    - `next_review_date` TEXT NOT NULL
    - `last_reviewed_at` TEXT
    - `active` INTEGER NOT NULL DEFAULT 1
    - `created_at` TEXT NOT NULL
    - `updated_at` TEXT NOT NULL
  - Alter `todos` table:
    - Add `spaced_repetition_item_id` TEXT (NULLABLE, FK to `spaced_repetition_items(id)` ON DELETE SET NULL).
  - Add indices `idx_srs_items_next_review` and `idx_todos_srs_item_id`.
- **Models**:
  - Create `lib/data/models/recall_confidence.dart` enum (`hard`, `revision`, `easy`).
  - Create `lib/data/models/spaced_repetition_item_entity.dart` (`@freezed`).
  - Update `lib/data/models/todo_entity.dart` with `spacedRepetitionItemId`.
- **DAO & Repository**:
  - Create `lib/data/dao/spaced_repetition_dao.dart`.
  - Create `lib/domain/repositories/spaced_repetition_repository.dart`.
  - Create `lib/data/repositories/spaced_repetition_repository_impl.dart`.

### 2. Domain & Application Layer
- **Use Cases**:
  - `GenerateSpacedRepetitionTasks`: Scans active `spaced_repetition_items` due on or before today (`next_review_date <= today`) and creates pending `TodoEntity` items on today's list if not already present.
  - `CompleteSrsTodo`: Takes `todoId` and `RecallConfidence`. Calculates new interval:
    - **Hard**: `interval = 1`, `level = 1`, `next_review_date = Today + 1 day`.
    - **Revision**: `interval = 3`, `level = level`, `next_review_date = Today + 3 days`.
    - **Easy**: `level = level + 1`, `interval = 7 * level`, `next_review_date = Today + (7 * level) days`.
    Updates the parent SRS item and marks the current todo completed.
  - Auto-tag handling: Auto-link tasks created with `#mastery` or `#spaced-repetition` to SRS items.
- **Providers (`lib/application/providers.dart`)**:
  - Register `spacedRepetitionDaoProvider`, `spacedRepetitionRepositoryProvider`, `generateSpacedRepetitionTasksProvider`, `completeSrsTodoProvider`.

### 3. Presentation Layer
- **Recall Confidence Modal / Dialog**:
  - `RecallConfidenceDialog` in `lib/presentation/screens/daily_list/widgets/recall_confidence_dialog.dart`.
  - When completing a task tagged `#mastery` / `#spaced-repetition` or linked to an SRS item, this modal presents three distinct recall buttons (**Hard** [1 day], **Revision** [3 days], **Easy** [7×lvl days]).
- **Mastery Deck Management View**:
  - Screen or tab to view all active Mastery Deck items, current interval, level, next review due date, and add new items.
- **App Strings**: Add localized/centralized strings in `lib/core/constants/app_strings.dart`.

---

## Files to Create / Modify

### [NEW]
- `lib/data/database/migrations/migration_v6.dart`
- `lib/data/models/recall_confidence.dart`
- `lib/data/models/spaced_repetition_item_entity.dart`
- `lib/data/dao/spaced_repetition_dao.dart`
- `lib/domain/repositories/spaced_repetition_repository.dart`
- `lib/data/repositories/spaced_repetition_repository_impl.dart`
- `lib/domain/usecases/generate_spaced_repetition_tasks.dart`
- `lib/domain/usecases/complete_srs_todo.dart`
- `lib/presentation/screens/daily_list/widgets/recall_confidence_dialog.dart`
- `lib/presentation/screens/mastery_deck/mastery_deck_screen.dart`
- `test/data/dao/spaced_repetition_dao_test.dart`
- `test/domain/usecases/complete_srs_todo_test.dart`

### [MODIFY]
- `lib/core/constants/app_constants.dart` (Increment `kDatabaseVersion` to 6)
- `lib/core/constants/app_strings.dart` (Add SRS strings)
- `lib/core/constants/app_routes.dart` (Add `/mastery-deck` route)
- `lib/data/database/migrations/migration_runner.dart` (Add v6 runner)
- `lib/data/models/todo_entity.dart` (Add `spacedRepetitionItemId`)
- `lib/data/dao/todo_dao.dart` (Include `spaced_repetition_item_id` in SQL queries)
- `lib/domain/repositories/todo_repository.dart` (Update repo interface if needed)
- `lib/data/repositories/todo_repository_impl.dart` (Update repository impl)
- `lib/application/providers.dart` (Add SRS providers)
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` (Trigger recall dialog on completion for SRS tasks)
- `lib/app.dart` (Add mastery deck route)

---

## Verification Plan

### Automated Tests
- Run `dart run build_runner build --delete-conflicting-outputs` to generate `@freezed` models.
- Run `flutter test test/data/dao/spaced_repetition_dao_test.dart` (in-memory SQLite tests).
- Run `flutter test test/domain/usecases/complete_srs_todo_test.dart` (unit tests for SM-2 interval calculation).
- Run `flutter analyze` (Must be 0 errors, 0 warnings).
- Run `flutter test` (All tests passing).

### Manual Verification
- Create a todo with title `Chapter 1 recitation #mastery`.
- Complete the task and verify the Recall Confidence Dialog pops up (**Hard**, **Revision**, **Easy**).
- Tap **Easy** and verify the next review date is scheduled for Today + 7 days.
