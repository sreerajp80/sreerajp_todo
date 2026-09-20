# Strictly Align Project Code Structure with Guidelines

**Status:** completed

## 1. What the issue is

An audit of the project code structure against `docs/guidelines/` (`guideline.md`, `flutter_project_engineering_standard.md`, and `architecture.md`) identified the following areas for strict alignment:

1. **Layer Boundary Violations (`flutter_project_engineering_standard.md §4.1` & `§4.2`, `AGENTS.md`):**
   - Presentation files directly import `package:sreerajp_todo/data/`:
     - `lib/presentation/screens/air_qr_scan_screen.dart` directly imports and instantiates `AirQrService` and `AirQrPayloadService`.
     - `lib/presentation/widgets/air_qr_preview_sheet.dart` directly imports `AirQrPayloadService`.
     - `lib/presentation/widgets/air_qr_share_dialog.dart` directly imports `TodoEntity`, `AirQrPayloadService`, and `AirQrService`.
     - `lib/presentation/shared/task_default_labels.dart` directly imports `TodoPriority` from `package:sreerajp_todo/data/models/todo_priority.dart`.
   - `AGENTS.md` and `flutter_project_engineering_standard.md §4` mandate:
     - `presentation/` never imports `data/` directly.
     - Widgets consume Riverpod providers from `lib/application/providers.dart`.
     - Dependency direction: `presentation → application → domain/usecases → domain/repositories ← data`.

2. **Presentation Widget Folder Hierarchy (`flutter_project_engineering_standard.md §3`, `docs/project_structure.md`):**
   - `lib/presentation/widgets/` currently exists as an isolated folder containing only two files (`air_qr_preview_sheet.dart` and `air_qr_share_dialog.dart`).
   - All other shared UI components in presentation live under `lib/presentation/shared/widgets/`.
   - These two shared AirQR modal dialogs/sheets belong in `lib/presentation/shared/widgets/`.

3. **Missing Baseline Linter Rules (`flutter_project_engineering_standard.md §16.1`):**
   - `flutter_project_engineering_standard.md §16.1` mandates recommended baseline additions to `analysis_options.yaml` (`prefer_final_fields`, `avoid_unnecessary_containers`, `sized_box_for_whitespace`, `prefer_is_empty`, `avoid_empty_else`, `unnecessary_brace_in_string_interps`, `unnecessary_this`, `no_duplicate_case_values`, `avoid_redundant_argument_values`, `use_full_hex_values_for_flutter_colors`, `cancel_subscriptions`, `close_sinks`, `use_decorated_box`, `avoid_bool_literals_in_conditional_expressions`, `noop_primitive_operations`, `use_enums`).
   - `analysis_options.yaml` currently omits these rules.

4. **Unused Framework Import in Application State Layer (`flutter_project_engineering_standard.md §4.1`):**
   - `lib/application/providers.dart` has an unused import `import 'package:flutter/material.dart';` on line 1. State layers must not import widget framework classes unless needed.

5. **Outdated Fallback Constants in `AppConfig` (`guideline.md §1.4`):**
   - `lib/core/config/app_config.dart` specifies fallback `version: '1.14.8'` and `build: '43'`, whereas `pubspec.yaml` and `assets/config/app_config.json` are on `version: 2.1.0` and `build: 45`.

## 2. Files to be changed

| File | Action | Proposed Change |
|---|---|---|
| `analysis_options.yaml` | MODIFY | Add standard baseline linter rules from `flutter_project_engineering_standard.md §16.1`. |
| `lib/core/config/app_config.dart` | MODIFY | Update `AppConfig.fallback` version and build to `2.1.0` and `45` to match `pubspec.yaml`. |
| `lib/application/providers.dart` | MODIFY | Remove unused `material.dart` import; expose `airQrServiceProvider` and `airQrPayloadServiceProvider`, and re-export payload types for presentation consumption. |
| `lib/domain/entities/todo_priority.dart` | NEW | Re-export `TodoPriority` from domain entity layer so presentation never imports data directly. |
| `lib/presentation/shared/task_default_labels.dart` | MODIFY | Import `TodoPriority` from domain entity layer instead of `data/models/`. |
| `lib/presentation/shared/widgets/air_qr_preview_sheet.dart` | NEW | Moved from `lib/presentation/widgets/air_qr_preview_sheet.dart`, consuming AirQR services via providers/domain. |
| `lib/presentation/shared/widgets/air_qr_share_dialog.dart` | NEW | Moved from `lib/presentation/widgets/air_qr_share_dialog.dart`, consuming AirQR services via providers/domain. |
| `lib/presentation/widgets/air_qr_preview_sheet.dart` | DELETE | Removed in favor of `presentation/shared/widgets/`. |
| `lib/presentation/widgets/air_qr_share_dialog.dart` | DELETE | Removed in favor of `presentation/shared/widgets/`. |
| `lib/presentation/screens/air_qr_scan_screen.dart` | MODIFY | Consume AirQR services via Riverpod / application layer, eliminating direct `data/` imports. |
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | MODIFY | Update import path of `air_qr_share_dialog.dart` and `air_qr_preview_sheet.dart`. |
| `lib/presentation/screens/backup/backup_screen.dart` | MODIFY | Update import path of `air_qr_share_dialog.dart` and `air_qr_preview_sheet.dart`. |
| `docs/project_structure.md` | MODIFY | Ensure directory layout documentation reflects the unified `lib/presentation/shared/widgets/` structure. |

## 3. The plan for the fix

### 3.1 Update `analysis_options.yaml`
1. Add the full recommended baseline additions from `flutter_project_engineering_standard.md §16.1`.
2. Run `flutter analyze` to verify clean compliance.

### 3.2 Update `AppConfig.fallback` in `lib/core/config/app_config.dart`
1. Update `version: '2.1.0'` and `build: '45'` in `AppConfig.fallback`.

### 3.3 Provide AirQR Services via Riverpod in `lib/application/providers.dart`
1. Remove `import 'package:flutter/material.dart';` from `lib/application/providers.dart`.
2. Add `airQrServiceProvider` and `airQrPayloadServiceProvider`.
3. Re-export `AirQrPayloadType` and `AirQrParsedPayload` from application/domain so presentation widgets do not touch `data/`.

### 3.4 Decouple Presentation from Data
1. Create `lib/domain/entities/todo_priority.dart` re-exporting `TodoPriority`.
2. Update `lib/presentation/shared/task_default_labels.dart` to import `package:sreerajp_todo/domain/entities/todo_priority.dart`.
3. Relocate `lib/presentation/widgets/air_qr_preview_sheet.dart` and `lib/presentation/widgets/air_qr_share_dialog.dart` to `lib/presentation/shared/widgets/`.
4. Update `lib/presentation/screens/air_qr_scan_screen.dart`, `daily_list_screen.dart`, and `backup_screen.dart` to use the shared widgets and application providers.
5. Remove the empty `lib/presentation/widgets/` directory.

### 3.5 Documentation Sync
1. Verify `docs/project_structure.md` accurately documents the directory structure and test layout.

## 4. Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure 0 errors and 0 warnings with all baseline linter rules enabled.
- Run `flutter test test/l10n/` and `flutter test test/widgets/`.
- Run `flutter test` (all 779+ tests).
