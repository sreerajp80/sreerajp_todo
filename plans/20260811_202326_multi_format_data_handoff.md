# Plan: 3.12 Multi-Format Data Ingestion & Export Engine (JSON with Markdown)

**Status:** Proposed

## Problem / Requirement
Implement specification **3.12 Multi-Format Data Ingestion & Export Engine**, simplified per user instruction:
*"We need only JSON with markdown if json cannot hold the style. Else only JSON"*

The application requires an offline-first data handoff engine capable of:
1. Exporting task lists, subtask checklists, recurrence rules, and time segment records to structured JSON payloads containing embedded Markdown formatting for descriptions and checklist styles.
2. Exporting human-readable Markdown checklist (`.md`) files and formatted summaries.
3. Ingesting external `.md` files or raw Markdown text containing `- [ ]` and `- [x]` checklist items, parsing them into `TodoEntity` instances and subtasks for target dates.
4. Ingesting structured JSON task payloads via system file pickers (`FilePicker`), running schema verification, sanitizing bounds, and enforcing NFC normalization (`unicodeUtils.nfcNormalize`).
5. Enforcing Day-Lock constraints (preventing imports into past dates).

## Proposed Changes

### Data & Domain Layer
- **`lib/domain/entities/data_handoff_payload.dart`**: Domain container model for JSON export/import payloads (date, target range, list of tasks, subtasks, recurrence rules, time segments, exported timestamp).
- **`lib/data/services/data_handoff_service.dart`**: Business logic service for:
  - Serializing tasks and time tracking data to JSON with embedded Markdown styles.
  - Exporting formatted Markdown checklist text (`- [ ]`, `- [x]`).
  - Parsing Markdown checklist items from raw text or `.md` files into task entities and subtask checklists.
  - Ingesting and validating JSON payloads with schema verification and NFC normalization.
  - Enforcing past-day day-lock checks before saving ingested tasks to SQLite repository.

### Application Layer
- **`lib/application/providers.dart`**: Expose `dataHandoffServiceProvider` and `dataHandoffStateNotifierProvider`.

### Presentation Layer
- **`lib/core/constants/app_routes.dart`**: Add `static const String dataHandoff = '/data-handoff';`.
- **`lib/presentation/screens/data_handoff/data_handoff_screen.dart`**: Main Data Handoff UI screen with JSON Export, Markdown Export, JSON Import, and Markdown Import options.
- **`lib/presentation/screens/data_handoff/widgets/markdown_import_dialog.dart`**: Modal dialog for pasting raw Markdown checklist text with live parsing preview.
- **`lib/app.dart`**: Register route `/data-handoff` in GoRouter configuration.
- **`lib/presentation/screens/daily_list/daily_list_screen.dart`**: Add "Data Handoff (JSON/MD)" menu option in the overflow menu.

### Localization & Documentation
- **`lib/l10n/app_en.arb`**: Add localized strings with mandatory `@` ARB metadata descriptions.
- **`docs/unique_features_and_improvements.md`**: Update section 3.12 to reflect implementation status.

### Unit & Service Tests
- **`test/data/services/data_handoff_service_test.dart`**: Unit tests verifying JSON serialization, Markdown checklist parsing, NFC normalization, schema verification, and Day-Lock enforcement.

## Verification Plan
1. Run `dart run build_runner build --delete-conflicting-outputs` if needed.
2. Run `flutter analyze` to ensure 0 lint errors and full ARB metadata compliance.
3. Run `flutter test` to verify all unit and service tests pass.
