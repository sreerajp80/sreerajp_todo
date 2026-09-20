# Change Log: Strictly Align Code Structure with Guidelines

**Date:** 2026-09-20
**Plan:** plans/20260920_182500_strictly_align_code_structure.md

## Overview

Audited and aligned the codebase to strictly adhere to `docs/guidelines/` (`guideline.md`, `flutter_project_engineering_standard.md`, and `architecture.md`) and repository engineering rules (`AGENTS.md`).

## Summary of Changes

1. **Static Analysis & Linter Rules (`analysis_options.yaml`):**
   - Added 23 recommended baseline linter rules from `flutter_project_engineering_standard.md §16.1`, including `prefer_final_fields`, `sized_box_for_whitespace`, `noop_primitive_operations`, `use_decorated_box`, `avoid_bool_literals_in_conditional_expressions`, `close_sinks`, `cancel_subscriptions`, `prefer_is_empty`, and `avoid_unnecessary_containers`.
   - Fixed all linter warnings across data and presentation code (e.g., replaced redundant string interpolations, replaced unnecessary containers with `DecoratedBox`, simplified boolean conditional expressions, and closed unused stream controllers in tests).

2. **Decoupling Presentation from Data Layer:**
   - Enforced the hard architectural rule that presentation widgets must never directly import from `package:sreerajp_todo/data/`.
   - Created domain entity re-exports (`lib/domain/entities/todo_priority.dart`, `lib/domain/entities/todo_status.dart`, `lib/domain/entities/todo_entity.dart`, `lib/domain/entities/time_segment_entity.dart`, `lib/domain/entities/recall_confidence.dart`, `lib/domain/entities/statistics_models.dart`, `lib/domain/entities/backup_file_info.dart`).
   - Exposed `airQrServiceProvider`, `airQrPayloadServiceProvider`, and `p2pWifiSyncServiceProvider` in `lib/application/providers.dart`.
   - Re-exported domain types from `lib/application/providers.dart` for UI consumption.
   - Refactored `AirQrScanScreen`, `AirQrPreviewSheet`, `AirQrShareDialog`, `BackupScreen`, `P2pWifiSyncScreen`, `StatisticsScreen`, and all presentation tiles/cards to consume services via Riverpod providers and domain types instead of direct data imports.
   - Removed all direct data imports from the presentation layer (0 occurrences remaining).

3. **Presentation Directory Layout Consolidation:**
   - Consolidated shared presentation widgets by moving `air_qr_preview_sheet.dart` and `air_qr_share_dialog.dart` from `lib/presentation/widgets/` to `lib/presentation/shared/widgets/`.
   - Deleted the redundant `lib/presentation/widgets/` folder.
   - Updated all call sites in `lib/presentation/screens/daily_list/daily_list_screen.dart` and `lib/presentation/screens/backup/backup_screen.dart`.
   - Updated `docs/project_structure.md` documentation to reflect the structure.

4. **Synchronized App Configuration Fallbacks:**
   - Updated `AppConfig.fallback` in `lib/core/config/app_config.dart` to `version: '2.1.0'` and `build: '45'`, ensuring consistency with `pubspec.yaml` and `assets/config/app_config.json`.
   - Updated `test/core/config/app_config_test.dart` to verify the new fallback defaults.

5. **Formatting and Code Hygiene:**
   - Ran `dart format lib/ test/ integration_test/`.
   - Verified that `flutter analyze` reports 0 issues.
   - Verified that all 779 tests pass with `flutter test`.
