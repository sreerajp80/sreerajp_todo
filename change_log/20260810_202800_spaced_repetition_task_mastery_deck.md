# Change Log — Spaced Repetition Task Mastery Deck (Anki-Style Habit & Skill Engine)

**Plan Reference:** [plans/20260810_202000_spaced_repetition_task_mastery_deck.md](file:///l:/Android/sreerajp_todo/plans/20260810_202000_spaced_repetition_task_mastery_deck.md)

---

## Summary of Changes

Implemented feature **3.5 Spaced Repetition Task Mastery Deck (Anki-Style Habit & Skill Engine)** for adaptive memory retention and skill maintenance tasks.

### 1. Database & Schema Migration (V6)
- **`app_constants.dart`**: Incremented `kDatabaseVersion` from 5 to 6.
- **`migration_v6.dart`**: Created database migration creating table `spaced_repetition_items` (`id`, `title`, `description`, `level`, `ease_factor`, `interval_days`, `next_review_date`, `last_reviewed_at`, `active`, `created_at`, `updated_at`) and adding `spaced_repetition_item_id` column to `todos` table with column existence guard.
- **`migration_runner.dart`**: Registered migration v6 execution step.

### 2. Models & Data Access Layer
- **`recall_confidence.dart`**: Created `RecallConfidence` enum (`hard`, `revision`, `easy`).
- **`spaced_repetition_item_entity.dart`**: Created Freezed domain entity model for SRS items.
- **`todo_entity.dart`**: Updated `TodoEntity` with `spacedRepetitionItemId`.
- **`spaced_repetition_dao.dart`**: Created DAO for CRUD and query operations on `spaced_repetition_items`.
- **`spaced_repetition_repository.dart` & `spaced_repetition_repository_impl.dart`**: Created repository interface and implementation for SRS items.

### 3. Use Cases & Application Layer
- **`generate_spaced_repetition_tasks.dart`**: Created usecase to scan SRS items due on or before today and insert pending daily tasks.
- **`complete_srs_todo.dart`**: Created SM-2 completion usecase:
  - **Hard**: Resets interval to 1 day, resets level to 1.
  - **Revision**: Maintains interval at 3 days.
  - **Easy**: Expands level by 1 and interval to $7 \times \text{level}$ days.
- **`providers.dart`**: Exposed SRS DAOs, repositories, and usecases via Riverpod.
- **`daily_todo_notifier.dart`**: Added `markSrsCompleted` method.
- **`main.dart`**: Triggered SRS task generation on application startup.

### 4. Presentation & UI Layer
- **`recall_confidence_dialog.dart`**: Created modal presenting recall confidence options (**Hard**, **Revision**, **Easy**) with color-coded interval badges.
- **`daily_list_screen.dart`**: Updated completion action to intercept tasks tagged `#mastery` or `#spaced-repetition` or linked to an SRS item to display `RecallConfidenceDialog`.
- **`mastery_deck_screen.dart`**: Built Mastery Deck view for viewing, adding, and deleting SRS items.
- **`app_routes.dart` & `responsive_scaffold.dart`**: Added `/mastery-deck` route and navigation destination across mobile & desktop platforms.

### 5. Automated Verification
- Ran `dart run build_runner build --delete-conflicting-outputs` (Clean code generation).
- Added `test/data/spaced_repetition_dao_test.dart` (Passed).
- Added `test/domain/usecases/complete_srs_todo_test.dart` (Passed).
- Ran `flutter analyze` (0 issues found).
- Ran `flutter test` (All 256 unit and widget tests passed).
