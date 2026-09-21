# Implementation Plan - Mastery Screen Settings Navigation

**Status:** Completed

## Issue
On the Mastery Screen (`MasteryDeckScreen`), there is no navigation button or menu option to open Settings. While the Daily List and Statistics screens have options to open Settings, the Mastery screen only has a refresh button in its app bar. As a result, users on the Mastery Screen cannot directly access Settings.

## Proposed Changes

### Presentation Layer

#### [MODIFY] lib/presentation/screens/mastery_deck/mastery_deck_screen.dart
- Add a settings `IconButton` to the `AppBar` actions list.
- Use `Icons.settings_outlined` as the icon and `context.l10n.settingsLabel` for the tooltip.
- In the `onPressed` callback, call `context.push(AppRoutes.settings)`.

### Test Suite

#### [MODIFY] test/presentation/mastery_deck_test.dart
- Add a widget test verifying that the settings button appears on `MasteryDeckScreen`.
- Verify that tapping the settings button triggers navigation to the Settings screen.

## Verification Plan

### Automated Tests
- Run `flutter test test/presentation/mastery_deck_test.dart` to verify the new test passes.
- Run `flutter test` to ensure all existing tests pass.
- Run `flutter analyze` to ensure 0 lint or static analysis issues.

### Manual Verification
- Open the app and tap the Mastery tab in the navigation bar.
- Verify the settings gear icon is visible in the top right of the app bar.
- Tap the settings icon and verify that it opens the Settings screen.
