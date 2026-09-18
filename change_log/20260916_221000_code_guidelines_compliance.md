# Change Log: Code Guidelines Strict Compliance

Reference plan: `plans/20260916_211000_code_guidelines_compliance.md`

## Overview

This update aligns the codebase strictly with the project guidelines in `docs/guidelines/guideline.md` and `docs/guidelines/flutter_project_engineering_standard.md`.

## Key Changes

### 1. Android App Bundle Configuration
- File: `android/app/build.gradle.kts`
- Added `bundle { language { enableSplit = false } }` under the `android` block.
- Prevents Google Play from stripping localized strings (such as Malayalam and Sanskrit) when users download or update the app on devices set to English.

### 2. Localization & String Externalization
- Files: `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`
- Added missing localized strings and tooltips:
  - `tooltipTogglePassword`: Tooltip for showing or hiding password fields.
  - `tooltipRemoveTask`: Tooltip for removing a task from the list.
  - `tooltipRemoveSubTask`: Tooltip for deleting a subtask.
  - `tooltipVoiceRecord`: Tooltip for voice input button.
  - `tooltipClear`: Generic tooltip for clearing form input fields.
  - `tooltipToggleStatus`: Tooltip for task completion toggle button.
  - `tooltipAirQrShare`: Tooltip for AirQR sharing action.
  - `tooltipAirQrScan`: Tooltip for AirQR scanner action.
  - `airQrBackupReceived`: Status message when backup items are received via AirQR.
  - `deckLoadError`, `deckNotFound`, `deckTasksLoadError`: Localized error messages for deck views.
- Included full `@key` metadata descriptions for all new keys in `lib/l10n/app_en.arb`.
- Added accurate Malayalam translations in `lib/l10n/app_ml.arb` ensuring 100% key parity.
- Re-generated localizations with `flutter gen-l10n`.

### 3. Accessibility Tooltips on Interactive Icon Controls
- Enforced guideline §7.8 by adding localized tooltips to all icon-only buttons:
  - `lib/presentation/screens/backup/backup_screen.dart`: Added tooltips for password visibility toggle and AirQR buttons.
  - `lib/presentation/screens/copy_todos/copy_todos_screen.dart`: Added tooltips for close, edit date, and remove task buttons.
  - `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`: Added tooltip for subtask delete button.
  - `lib/presentation/screens/daily_list/daily_list_screen.dart`: Added tooltip for multi-select close button.
  - `lib/presentation/screens/mastery_deck/mastery_deck_screen.dart`: Replaced hardcoded tooltip with localized `tooltipRefresh`.
  - `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart`: Added tooltips for refresh and deck menu options; used dynamic completion tooltip.
  - `lib/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart`: Added tooltips for close, clear title, and clear description buttons.
  - `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart`: Added tooltip for voice recording button.
  - `lib/presentation/screens/air_qr/air_qr_share_dialog.dart`: Added tooltips for close buttons.

### 4. Code Health & Safe Error Handling
- Added documentation explaining intentional empty catch blocks (guideline §11.2) across data and presentation files:
  - `lib/data/services/atomic_saver.dart`
  - `lib/data/services/database_service.dart`
  - `lib/data/services/data_handoff_service.dart`
  - `lib/data/services/p2p_wifi_sync_service.dart`
  - `lib/domain/entities/data_handoff_payload.dart`
  - `lib/domain/entities/p2p_sync_payload.dart`
  - `lib/presentation/screens/air_qr/air_qr_scan_screen.dart`
  - `lib/presentation/screens/ocr/ocr_scan_screen.dart`
- Resolved `use_build_context_synchronously` lint warnings across async gaps.

### 5. Compliance Automated Test Suite
- Added `test/presentation/icon_button_tooltips_compliance_test.dart`:
  - Validates that `android/app/build.gradle.kts` disables App Bundle language splitting.
  - Scans all presentation screens to ensure interactive icon buttons include tooltips.
  - Verifies widget tooltip helpers.

## Verification
- `flutter analyze`: 0 issues found.
- `flutter test`: 760 tests passed cleanly.
