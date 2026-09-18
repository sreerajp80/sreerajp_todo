# Plan: Strictly Align Project Code to Engineering and Design Guidelines

**Status:** completed

## The ask

Ensure the project code strictly adheres to the guidelines in `docs/guidelines/`, specifically:
- `guideline.md` (§1 About-screen metadata, §2 Keystore, §4 Checklist).
- `flutter_project_engineering_standard.md`:
  - §7.8: Mandatory tooltips on all icon-only controls (`IconButton`, `FloatingActionButton`, `PopupMenuButton`).
  - §8.1: Android App Bundle language splitting disabled in `android/app/build.gradle.kts`.
  - §8.2: Mandatory string externalization (zero hardcoded user-visible strings in UI widgets).
  - §11.2: No undocumented empty catch blocks (`catch (_) {}`).
  - §15: Security, offline-only operations, and data safety.

## Files to change

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | Add `bundle { language { enableSplit = false } }` to ensure all localized resources stay installed on Play Store downloads. |
| `lib/l10n/app_en.arb` | Add localized keys and `@key` descriptions for missing tooltips and user-visible strings. |
| `lib/l10n/app_ml.arb` | Add authentic Malayalam translations for all newly added ARB keys. |
| `lib/presentation/screens/backup/backup_screen.dart` | Add tooltip to password toggle `IconButton`; localize AirQR tooltips and payload snackbar. |
| `lib/presentation/screens/copy_todos/copy_todos_screen.dart` | Add localized tooltips to close, edit date, and remove task `IconButton`s. |
| `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` | Add localized tooltip to subtask remove `IconButton`. |
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | Add localized tooltip to multi-select close button; localize AirQR sync complete snackbar. |
| `lib/presentation/screens/mastery_deck/mastery_deck_screen.dart` | Replace hardcoded `'Refresh'` tooltip with localized tooltip. |
| `lib/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart` | Replace hardcoded `'Refresh'` tooltip; add localized tooltips to `PopupMenuButton` and status toggle `IconButton`. |
| `lib/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart` | Add localized tooltips to close, clear task name, and clear description `IconButton`s. |
| `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart` | Add localized tooltip to mic `FloatingActionButton`. |
| `lib/presentation/screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart` | Replace hardcoded tooltip on copy button; localize user-facing snackbars and dialog strings. |
| `lib/presentation/screens/features/features_screen.dart` | Replace raw string literal `'Features'` in `AppBar` title with `context.l10n.settingsFeatures`. |
| `lib/presentation/screens/help/help_home_screen.dart` | Replace raw string literal `'Help & User Guides'` in `AppBar` title with `context.l10n.settingsHelp`. |
| `lib/presentation/shared/widgets/responsive_scaffold.dart` | Localize `'Mastery'` bottom navigation label. |
| `lib/presentation/screens/daily_list/widgets/recall_confidence_dialog.dart` | Replace raw `'Cancel'` text with `context.l10n.cancel`. |
| `lib/presentation/screens/data_handoff/data_handoff_screen.dart` | Localize export and import snackbar notifications and dialog options. |
| `lib/presentation/screens/ocr/ocr_scan_screen.dart` | Localize error snackbar messages. |
| `lib/presentation/widgets/air_qr_preview_sheet.dart` | Localize preview dialog title, format error, and action button labels. |
| `lib/presentation/widgets/air_qr_share_dialog.dart` | Localize stream generation error and close button label. |
| `lib/core/utils/atomic_saver.dart` | Add safety rationale comment to empty catch block. |
| `lib/data/database/database_service.dart` | Add safety rationale comment to empty catch block. |
| `lib/data/services/data_handoff_service.dart` | Add safety rationale comments to empty catch blocks. |
| `lib/data/services/p2p_wifi_sync_service.dart` | Add safety rationale comment to empty catch block. |
| `lib/domain/entities/data_handoff_payload.dart` | Add safety rationale comments to fallback parsing catch blocks. |
| `lib/domain/entities/p2p_sync_payload.dart` | Add safety rationale comments to fallback parsing catch blocks. |
| `lib/presentation/screens/air_qr_scan_screen.dart` | Add safety rationale comment to parser catch block. |
| `lib/presentation/screens/ocr/ocr_scan_screen.dart` | Add safety rationale comments to cleanup catch blocks. |
| `test/presentation/icon_button_tooltips_compliance_test.dart` | Add automated unit/widget test asserting that icon buttons have tooltips per §7.8. |

## The issues found

1. **Language Splitting Configuration (§8.1, `guideline.md §4`):**
   - `android/app/build.gradle.kts` does not configure `bundle.language.enableSplit = false`. When downloaded from Google Play, users switching languages may miss resources if splits are enabled.

2. **Missing and Hardcoded Tooltips on Icon-Only Controls (§7.8):**
   - `IconButton`s without tooltips:
     - `backup_screen.dart` (password visibility toggle)
     - `copy_todos_screen.dart` (close button, pick date button, remove task button)
     - `create_edit_todo_screen.dart` (remove subtask button)
     - `daily_list_screen.dart` (multi-select clear selection button)
     - `mastery_deck_detail_screen.dart` (status toggle button)
     - `ocr_result_bottom_sheet.dart` (close button, clear name button, clear description button)
   - `PopupMenuButton` without tooltip:
     - `mastery_deck_detail_screen.dart` (deck actions menu)
   - `FloatingActionButton` without tooltip:
     - `voice_command_sheet.dart` (mic recording button)
   - Hardcoded string tooltips:
     - `backup_screen.dart` (`'AirQR Share Stream'`, `'AirQR Scan Camera'`)
     - `mastery_deck_screen.dart` and `mastery_deck_detail_screen.dart` (`'Refresh'`)
     - `p2p_wifi_sync_screen.dart` (`'Copy Pairing Details'`)

3. **Hardcoded User-Facing Strings (§8.2):**
   - `features_screen.dart` uses `Text('Features')` instead of `settingsFeatures`.
   - `help_home_screen.dart` uses `Text('Help & User Guides')` instead of `settingsHelp`.
   - `responsive_scaffold.dart` uses `Text('Mastery')`.
   - `recall_confidence_dialog.dart` uses `Text('Cancel')` instead of `cancel`.
   - `data_handoff_screen.dart`, `ocr_scan_screen.dart`, `p2p_wifi_sync_screen.dart`, `backup_screen.dart`, `daily_list_screen.dart`, `air_qr_preview_sheet.dart`, and `air_qr_share_dialog.dart` have hardcoded English text in notifications, snackbars, and action sheets.

4. **Undocumented Empty Catch Blocks (§11.2):**
   - Several background/cleanup operations contain `catch (_) {}` without documentation explaining why suppression is safe.

## The proposed fix

1. **Configure Gradle Language Splitting:**
   - In `android/app/build.gradle.kts`, add:
     ```kotlin
     android {
         bundle {
             language {
                 enableSplit = false
             }
         }
     }
     ```

2. **Add Localization Keys:**
   - Add all missing tooltip and UI labels to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.
   - Ensure all keys have `@key` metadata and valid Malayalam translations.
   - Run `flutter gen-l10n`.

3. **Update Presentation Controls:**
   - Provide localized tooltips for all icon buttons, FABs, and popup menus.
   - Replace all raw string literals with localized accessors via `context.l10n`.

4. **Document Silent Catch Blocks:**
   - Add comments explaining safety (e.g., `// Safe to suppress: best-effort temporary file cleanup`).

5. **Automated Verification Test:**
   - Add a compliance test verifying that icon controls have tooltips as mandated by §7.8.

## Verification plan

### Automated tests
- Run `flutter gen-l10n`.
- Run `flutter analyze` to ensure 0 static analysis issues.
- Run `flutter test` to ensure all existing and new tests pass cleanly.
