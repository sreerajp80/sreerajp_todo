# Change Log: 3.12 Multi-Format Data Ingestion & Export Engine (JSON with Markdown)

**Plan Reference:** [plans/20260811_202326_multi_format_data_handoff.md](file:///l:/Android/sreerajp_todo/plans/20260811_202326_multi_format_data_handoff.md)  
**Date:** 2026-08-11

## Overview
Implemented specification **3.12 Multi-Format Data Ingestion & Export Engine (JSON with Markdown)** in `SreerajP ToDo`, empowering users to export and ingest tasks, subtask checklists, recurrence rules, time segment records, and embedded Markdown notes fully offline without cloud dependencies.

## Key Changes Made

1. **Domain & Data Layer:**
   - [data_handoff_payload.dart](file:///l:/Android/sreerajp_todo/lib/domain/entities/data_handoff_payload.dart): Container model representing structured JSON payloads with versioning, task lists, subtask arrays, recurrence rules, time segment records, and ISO timestamps.
   - [data_handoff_service.dart](file:///l:/Android/sreerajp_todo/lib/data/services/data_handoff_service.dart): Business logic service handling:
     - JSON payload formatting (`exportToJson`, `parseJsonPayload`).
     - Markdown checklist formatting & parsing (`exportToMarkdown`, `parseMarkdownChecklist`).
     - NFC normalization on all text inputs (`nfcNormalize`).
     - Day-Lock enforcement on past target dates (`DayLockedException`).
     - File picker integration (`pickAndReadImportFile`, `exportToFile`).

2. **Application & Routing Layer:**
   - [providers.dart](file:///l:/Android/sreerajp_todo/lib/application/providers.dart): Registered `dataHandoffServiceProvider`.
   - [app_routes.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_routes.dart): Registered `static const String dataHandoff = '/data-handoff';`.
   - [app.dart](file:///l:/Android/sreerajp_todo/lib/app.dart): Added `/data-handoff` route pointing to `DataHandoffScreen`.

3. **Presentation Layer:**
   - [data_handoff_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/data_handoff/data_handoff_screen.dart): UI screen for selecting target date, exporting JSON payloads / Markdown checklists, and importing `.json` / `.md` files.
   - [markdown_import_dialog.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/data_handoff/widgets/markdown_import_dialog.dart): Interactive modal dialog for pasting raw Markdown text (`- [ ]` / `- [x]`) with live parse preview.
   - [daily_list_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/daily_list_screen.dart): Added Data Handoff action button (`Icons.import_export_rounded`) in the AppBar.

4. **Localization & Documentation:**
   - [app_en.arb](file:///l:/Android/sreerajp_todo/lib/l10n/app_en.arb): Added localized strings with mandatory `@` ARB metadata descriptions.
   - [unique_features_and_improvements.md](file:///l:/Android/sreerajp_todo/docs/unique_features_and_improvements.md): Updated section 3.12 with implementation details and checkmark.

5. **Unit & Integration Tests:**
   - [data_handoff_service_test.dart](file:///l:/Android/sreerajp_todo/test/data/services/data_handoff_service_test.dart): Automated unit tests verifying JSON serialization, Markdown checklist parsing, NFC normalization, and Day-Lock enforcement.

## Verification & Status
- Passed `flutter analyze` with 0 warnings/errors.
- Passed `flutter test` across all service unit tests.
