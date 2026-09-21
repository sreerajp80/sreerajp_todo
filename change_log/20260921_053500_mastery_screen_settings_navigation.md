# Mastery Screen Settings Navigation

## Summary
Added navigation to the Settings screen directly from the Mastery Screen (`MasteryDeckScreen`) via an app bar icon button, matching the navigation experience of the Statistics screen.

## Reference
Plan: [plans/20260921_053500_mastery_screen_settings_navigation.md](plans/20260921_053500_mastery_screen_settings_navigation.md)

## Changes Made

1. **Presentation Layer**:
   - `lib/presentation/screens/mastery_deck/mastery_deck_screen.dart`:
     - Added a Settings `IconButton` (`Icons.settings_outlined`) to `AppBar.actions`.
     - Configured the tooltip to use localized `context.l10n.settingsLabel`.
     - Configured `onPressed` to push `AppRoutes.settings` using `go_router`.

2. **Test Suite**:
   - `test/presentation/mastery_deck_test.dart`:
     - Added a widget test `MasteryDeckScreen shows settings button in app bar` verifying that the settings action button is rendered with the proper icon and tooltip.

## Verification
- `flutter test test/presentation/mastery_deck_test.dart`: All 5 tests passed.
- `flutter analyze`: 0 issues found.
- `dart format`: Code is clean and formatted.
