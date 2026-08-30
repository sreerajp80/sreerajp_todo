# Change Log: Fix Save Button Visibility and Contrast

**Plan reference:** `plans/20260827_212840_fix_save_button_visibility.md`

## Summary of Changes

1. **Theme Contrast Fix (`lib/presentation/shared/theme/app_theme.dart`)**:
   - Updated `contrastOn` to use WCAG luminance contrast comparison between black and white (`contrastWithBlack >= contrastWithWhite ? Colors.black : Colors.white`).
   - Updated `ColorScheme` in `_buildTheme` to set `onPrimary: contrastOn(primary)` across both light and dark themes instead of hardcoding `Colors.white` when `accent == null`.
   - In dark theme with the default accent (`#9BBAFF`), text and icons on primary buttons are now crisp dark text with a >10:1 contrast ratio instead of invisible white-on-light-blue.

2. **Screen Layout & Safe Area (`lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`)**:
   - Wrapped the form body in `SafeArea`.
   - Updated `ListView` padding to `EdgeInsets.fromLTRB(16, 16, 16, 32)` to ensure the Save button is fully elevated above Android's 3-button system navigation bar.

3. **Unit Testing (`test/presentation/app_theme_test.dart`)**:
   - Added unit test checking that `onPrimary` maintains WCAG readable contrast (> 4.5:1) against `primary` in light theme, dark theme, and all preset accent colors.

## Verification
- `flutter analyze` completed with 0 warnings.
- `flutter test` passed all 599 tests.
