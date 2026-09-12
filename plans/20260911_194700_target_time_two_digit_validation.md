# Target Duration Field Two-Digit Limit and Typing Validation Plan

**Status:** Implemented
**Date:** 2026-09-11

## Issue
In `TargetTimeField` (`lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart`), the duration input boxes for hours and minutes currently allow up to 4 digits (`LengthLimitingTextInputFormatter(4)`). Furthermore, there is no real-time validation while typing for minutes (> 59) or hours.
The user requested:
1. Ensure only two digits are allowed in the hours and minutes fields.
2. Validate while typing.
3. Address the question of whether hours should be capped at 24 (or 23), 12, or 99 (since it was not specified).

## Proposed Fix
1. **Enforce Two-Digit Maximum:**
   - Change `LengthLimitingTextInputFormatter(4)` to `LengthLimitingTextInputFormatter(2)` on both hours and minutes `TextField`s.
   - Retain `FilteringTextInputFormatter.digitsOnly` to prevent any non-digit characters.

2. **Real-Time Validation While Typing:**
   - Add state tracking for hours and minutes validation errors while typing in `TargetTimeField`.
   - For **Minutes**: Valid values are `0` to `59`. If a user enters a value greater than `59` (e.g. `60`–`99`), display an inline validation error (`0–59`).
   - For **Hours**:
     - Clarify the maximum bound with the user:
       - **Option A (Recommended - 24-hour limit):** Cap hours at `23` (or `24`), matching the single-day scope of the daily task planner (`0–23` hours). If > 23 (or > 24), display an inline validation error.
       - **Option B (12-hour limit):** Cap hours at `12` (`0–12` hours).
       - **Option C (Any 2 digits / 99 hours):** Allow any 2-digit hour (`0–99` hours) without an upper bound error, restricting only length to 2 digits.
   - When an error is present:
     - Display clear error text or error borders on the invalid field.
     - Prevent emitting an invalid duration or notify parent form of invalid state so invalid target time cannot be saved.
   - When input is valid:
     - Clear the error and emit the calculated `targetSeconds` via `widget.onChanged`.

3. **Localization:**
   - Add localized error message strings for hours and minutes out-of-range validation in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.
   - Run `flutter gen-l10n` to update generated localizations.

4. **Testing:**
   - Update `test/presentation/target_time_field_test.dart` to verify:
     - Input length is strictly limited to 2 digits.
     - Typing values > 59 in minutes shows validation error.
     - Typing values exceeding the hours limit shows validation error.
     - Valid 2-digit inputs emit correct `targetSeconds`.

## Files to Change
- `lib/presentation/screens/create_edit_todo/widgets/target_time_field.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_ml.dart`
- `test/presentation/target_time_field_test.dart`

## Verification
- Run `flutter test test/presentation/target_time_field_test.dart`
- Run `flutter analyze`
- Run all tests with `flutter test`
