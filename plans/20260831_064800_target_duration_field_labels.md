# Target Duration Field UX Clarification Plan

**Status:** Proposed
**Date:** 2026-08-31

## Issue
In the task creation and editing screen (`CreateEditTodoScreen`), the **Target Time** ("ലക്ഷ്യ സമയം") input fields contain two number boxes (Hours and Minutes) initialized to `0`. However:
1. Global `InputDecorationTheme` has `floatingLabelBehavior: FloatingLabelBehavior.never`, so the `labelText` on the `TextField` is hidden when the field already has a value (`0`). Users cannot tell which box is for hours and which is for minutes.
2. The UI does not clearly state that this field represents the estimated **duration** required to complete the task.

## Proposed Fix
1. **Explicit Field Labels & Suffixes:**
   - In `TargetTimeField` (`lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart`), structure each input box with an explicit top label (`Text(label)`) so "Hours" / "മണിക്കൂർ" and "Minutes" / "മിനിറ്റ്" are always visible.
   - Add clear suffix/helper indicators (e.g., `h` / `m` or localized labels).
2. **Clarify Duration in Hint / Subtitle:**
   - Update `targetTimeHint` in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` to explain that this is the estimated duration to complete the task (e.g., "Estimated duration to complete this task. Set both to 0 for no target time.").
   - Regenerate localization files (`flutter gen-l10n` or generated localization classes).

## Files to Change
- `lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_ml.dart`

## Verification
- Run `flutter analyze`
- Run `flutter test`
