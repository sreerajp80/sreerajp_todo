# Change Log: Target Duration Field Labels & Completion Duration UX

**Date:** 2026-08-31
**Plan:** `plans/20260831_064800_target_duration_field_labels.md`

## Summary
Clarified the Target Time widget in the task create/edit screen so that users can clearly see which box represents **Hours** and which represents **Minutes**, and understand that the field indicates the estimated **duration** to complete the task.

## Changes Made
1. **Target Time UI Field (`lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart`)**:
   - Added explicit top labels above each input box using `l10n.targetHoursLabel` ("Hours" / "മണിക്കൂർ") and `l10n.targetMinutesLabel` ("Minutes" / "മിനിറ്റ്") so they remain visible at all times regardless of existing text or theme floating label behavior.
   - Added unit suffixes (`h` and `m`) to the input text fields.
2. **Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_localizations_en.dart`, `lib/l10n/app_localizations_ml.dart`)**:
   - Updated `targetTimeHint` to state that it represents the estimated duration for completing the task ("Estimated duration to complete this task. Leave both at zero for no target." / "ടാസ്ക് പൂർത്തിയാക്കാൻ ഉദ്ദേശിക്കുന്ന ദൈർഘ്യം. ലക്ഷ്യം വേണ്ടെങ്കിൽ രണ്ടും പൂജ്യമായി വെക്കുക.").
3. **Tests (`test/presentation/target_time_field_test.dart`, `test/presentation/create_edit_todo_screen_test.dart`)**:
   - Added unit and widget tests for `TargetTimeField` in English and Malayalam locales.
   - Verified that all 630 tests pass.

## Verification
- Static code analysis: `flutter analyze` completed with 0 issues.
- Test suite: `flutter test` passed with 630/630 tests passing.
