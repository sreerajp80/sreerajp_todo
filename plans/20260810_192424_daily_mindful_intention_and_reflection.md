# Implementation Plan — Daily Mindful Intention Card & Reflection Ritual

**Status:** Awaiting Approval

## Goal Description
Implement Feature 3.4: Daily Mindful Intention Card & Reflection Ritual.
- **Morning Intention Card:** An expandable header card docked above today's task list (reusing UI patterns from daily_rule_cards layout) presenting serene daily focus rules (e.g., *"Focus on single-tasking today; handle duty without extra emotional noise"*). Supports expanding/collapsing, cycling intentions, and setting custom focus rules.
- **Evening Reflection Ritual:** A 60-second reflection modal available at the end of the day that summarizes today's completed vs. dropped time ratio, completed task count vs. dropped task count, and lets the user record a brief NFC-normalized daily reflection note stored in SQLite.

---

## User Review Required
> [!IMPORTANT]
> - Database schema version will be incremented from 4 to 5 (`kDatabaseVersion = 5`).
> - New SQLite tables `daily_reflections` and `daily_intentions` will be created via `migration_v5.dart`.
> - All user reflection notes written to SQLite will be NFC-normalized via `unicodeUtils.nfcNormalize(value)`.
> - Day-lock rules apply: past day reflection notes and intentions remain immutable read-only records (`DayLockedException`).

---

## Open Questions
None.

---

## Proposed Changes

### Data & Migration Layer

#### [MODIFY] [app_constants.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_constants.dart)
- Increment `kDatabaseVersion` from 4 to 5.

#### [NEW] [daily_reflection_entity.dart](file:///l:/Android/sreerajp_todo/lib/data/models/daily_reflection_entity.dart)
- Create `@freezed` model `DailyReflectionEntity` (`date`, `reflectionNote`, `completedSeconds`, `droppedSeconds`, `createdAt`, `updatedAt`).

#### [NEW] [daily_intention_entity.dart](file:///l:/Android/sreerajp_todo/lib/data/models/daily_intention_entity.dart)
- Create `@freezed` model `DailyIntentionEntity` (`date`, `intentionText`, `createdAt`).

#### [NEW] [migration_v5.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_v5.dart)
- Create migration script for v5:
  - `daily_reflections` table (`date TEXT PRIMARY KEY`, `reflection_note TEXT NOT NULL`, `completed_seconds INTEGER NOT NULL`, `dropped_seconds INTEGER NOT NULL`, `created_at TEXT NOT NULL`, `updated_at TEXT NOT NULL`).
  - `daily_intentions` table (`date TEXT PRIMARY KEY`, `intention_text TEXT NOT NULL`, `created_at TEXT NOT NULL`).

#### [MODIFY] [migration_runner.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_runner.dart)
- Register and execute `migration_v5.dart` when upgrading DB to version 5.

#### [NEW] [daily_reflection_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/daily_reflection_dao.dart)
- Create DAO methods for `daily_reflections` and `daily_intentions` tables:
  - `getReflectionForDate(String date)`
  - `saveReflection(DailyReflectionEntity reflection)`
  - `getIntentionForDate(String date)`
  - `saveIntention(DailyIntentionEntity intention)`

---

### Domain Layer

#### [NEW] [daily_reflection_repository.dart](file:///l:/Android/sreerajp_todo/lib/domain/repositories/daily_reflection_repository.dart)
- Define repository contract for reading and saving daily reflections and intentions.

#### [NEW] [daily_reflection_repository_impl.dart](file:///l:/Android/sreerajp_todo/lib/data/repositories/daily_reflection_repository_impl.dart)
- Implement `DailyReflectionRepository` enforcing NFC normalization (`unicodeUtils.nfcNormalize`) and day-lock checks (`DayLockedException` on past date updates).

---

### Application Layer

#### [MODIFY] [providers.dart](file:///l:/Android/sreerajp_todo/lib/application/providers.dart)
- Add `dailyReflectionDaoProvider`, `dailyReflectionRepositoryProvider`, and state providers for fetching/updating intention and reflection data for the active date.

---

### Localization Layer

#### [MODIFY] [app_en.arb](file:///l:/Android/sreerajp_todo/lib/l10n/app_en.arb)
- Add strings for Morning Intention Card and Evening Reflection Ritual (`morningIntention`, `eveningReflection`, `eveningReflectionTitle`, `reflectionSummaryTitle`, `completedTime`, `droppedTime`, `completionRatio`, `reflectionNoteHint`, `reflectionSaved`, `cycleIntention`, `startReflection`, `mindfulFocusRules`).

#### [MODIFY] [app_ml.arb](file:///l:/Android/sreerajp_todo/lib/l10n/app_ml.arb)
- Add Malayalam translations for Intention Card and Reflection Ritual strings.

---

### Presentation Layer

#### [NEW] [morning_intention_card.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/widgets/morning_intention_card.dart)
- Expandable header card widget docked atop the Daily List:
  - Displays serene daily focus rule/intention with icon and styling.
  - Expand/collapse chevron button.
  - Cycle intention button to switch serene focus thoughts.
  - "Evening Reflection" action button.

#### [NEW] [evening_reflection_modal.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/widgets/evening_reflection_modal.dart)
- Modal dialog/bottom sheet for the 60-second reflection ritual:
  - Productivity summary: completed vs. dropped time ratio, total tracked duration, completed vs. dropped task counts.
  - Reflection note multiline text field.
  - Save button with SnackBar confirmation.

#### [MODIFY] [daily_list_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/daily_list_screen.dart)
- Dock `MorningIntentionCard` at the top of the Daily List.
- Add Evening Reflection action button in the app bar.

---

### Documentation & Verification Layer

#### [MODIFY] [unique_features_and_improvements.md](file:///l:/Android/sreerajp_todo/docs/unique_features_and_improvements.md)
- Mark section 3.4 title and Phase 2 roadmap entry as implemented with green tick `✅ [Implemented]`.

#### [NEW] [daily_reflection_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/daily_reflection_dao_test.dart)
- Unit tests for `DailyReflectionDao` and `DailyIntentionDao` using in-memory SQLite database.

---

## Verification Plan

### Automated Tests
- Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- Run static analysis: `flutter analyze` (Must pass with 0 warnings/errors)
- Run unit & widget tests: `flutter test` (Must pass all existing and new unit tests)

### Manual Verification
1. Open Daily List screen on Today's date and verify `MorningIntentionCard` is rendered docked above the task list.
2. Expand and collapse the card, tap the cycle button to cycle through serene focus intentions.
3. Tap "Evening Reflection Ritual" button to trigger the modal.
4. Verify productivity summary calculates completed time vs. dropped time ratio accurately.
5. Enter a reflection note, save it, and re-open to verify persistence.
6. Navigate to a past day and verify intention and reflection note are displayed in read-only mode.
