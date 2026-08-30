# Implementation Plan: Fix Save Button Visibility and Contrast

**Status:** Ready for Review

## Problem Description
1. **Low Contrast Text & Icon in Dark Mode**: When in dark mode with the default accent colour (`Color(0xFF9BBAFF)` — light pastel blue), `AppTheme` sets `onPrimary` to `Colors.white` whenever `accent == null`. White text and icons on the light blue button background have very low contrast (~1.4:1 ratio), making the button text ("സംരക്ഷിക്കുക" / "Save") almost completely invisible.
2. **Bottom Navigation Bar Overlap**: In `CreateEditTodoScreen`, the form `ListView` lacks proper `SafeArea` / bottom system inset handling. On Android devices with a 3-button system navigation bar, the Save button at the bottom of the form is partially covered and cut off behind the Android system navigation bar.

## Proposed Changes

### 1. [lib/presentation/shared/theme/app_theme.dart](file:///L:/Android/sreerajp_todo/lib/presentation/shared/theme/app_theme.dart)
- Update `onPrimary` in `_buildTheme` to use `contrastOn(primary)` instead of hardcoding `Colors.white` when `accent == null`.
- This ensures high-contrast dark text/icon on light accents (like `defaultDarkAccent` `#9BBAFF`) and white text on dark accents (like `defaultLightAccent` `#355FA8`).

### 2. [lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart](file:///L:/Android/sreerajp_todo/lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart)
- Wrap the form / `ListView` in `SafeArea` and add proper bottom padding (`EdgeInsets.fromLTRB(16, 16, 16, 24)`) so that the Save button is always fully visible and elevated above the Android system navigation bar.

### 3. [test/presentation/app_theme_test.dart](file:///L:/Android/sreerajp_todo/test/presentation/app_theme_test.dart)
- Add a unit test verifying that `onPrimary` maintains adequate WCAG contrast against `primary` in both light and dark modes with default accents.

## Verification Plan

### Automated Tests
- Run `flutter test test/presentation/app_theme_test.dart`
- Run `flutter test` to ensure all tests pass without regressions.
- Run `flutter analyze` to verify zero static analysis warnings.

### Manual Verification
- Verify the Save button is clearly visible and readable in dark mode with high-contrast text and icon.
- Verify the Save button is fully above the Android system navigation bar.
