# Change Log - Move Settings to Dotted Menu

**Date:** 2026-08-11
**Plan Ref:** [plans/20260811_210800_move_settings_to_dotted_menu.md](file:///l:/Android/sreerajp_todo/plans/20260811_210800_move_settings_to_dotted_menu.md)

## Summary
Moved the Settings navigation item from the bottom navigation bar (`NavigationBar`) and side navigation rail (`NavigationRail`) into the top 3-dot overflow menu (`PopupMenuButton`) on the Daily List screen.

## Key Changes
1. **`lib/presentation/shared/widgets/responsive_scaffold.dart`**:
   - Updated `AppScaffoldDestination` enum to `{ daily, masteryDeck, statistics }`.
   - Removed Settings from `NavigationRail` and `NavigationBar` destinations.
   - Updated switch statement in `_onDestinationSelected`.

2. **`lib/presentation/screens/daily_list/daily_list_screen.dart`**:
   - Added `settings` value to `_AppBarMoreOption` enum.
   - Added Settings option (`Icons.settings_outlined`) to `PopupMenuButton<_AppBarMoreOption>` top app bar overflow menu.
   - Handled `_AppBarMoreOption.settings` in `onSelected` callback using `context.push(AppRoutes.settings)`.

3. **`lib/presentation/screens/settings/settings_screen.dart`**:
   - Replaced `ResponsiveScaffold` with `Scaffold` featuring `AppBar(title: Text(context.l10n.settingsLabel))` for standard sub-screen back button navigation.

## Verification
- `flutter analyze` completed with 0 static code analysis issues.
- `flutter test` executed and verified all test suites.
