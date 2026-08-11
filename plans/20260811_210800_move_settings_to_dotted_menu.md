# Implementation Plan - Move Settings to Dotted Menu

**Status:** Awaiting Approval

## Issue
Currently, Settings is listed as the 4th item in the bottom navigation bar (`NavigationBar`) and side navigation rail (`NavigationRail`). The user requested to move Settings out of the bottom navigation bar and into the 3-dot overflow menu (dotted menu) at the top of the app bar.

## Proposed Changes

### Presentation Layer

#### [MODIFY] [responsive_scaffold.dart](file:///l:/Android/sreerajp_todo/lib/presentation/shared/widgets/responsive_scaffold.dart)
- Remove `settings` from `AppScaffoldDestination` enum (`AppScaffoldDestination { daily, masteryDeck, statistics }`).
- Remove Settings from `NavigationRail` and `NavigationBar` destinations (reducing tabs from 4 to 3: Daily List, Mastery, Statistics).
- Update switch mapping in `_onDestinationSelected`.

#### [MODIFY] [daily_list_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/daily_list/daily_list_screen.dart)
- Add `settings` to `_AppBarMoreOption` enum.
- Add Settings `PopupMenuItem` to top app bar 3-dot overflow menu (`PopupMenuButton<_AppBarMoreOption>`).
- Handle `_AppBarMoreOption.settings` in `onSelected` callback using `context.push(AppRoutes.settings)`.

#### [MODIFY] [settings_screen.dart](file:///l:/Android/sreerajp_todo/lib/presentation/screens/settings/settings_screen.dart)
- Replace `ResponsiveScaffold` wrapper with a clean `Scaffold` containing `AppBar(title: Text(context.l10n.settingsLabel))`.
- This ensures proper sub-page navigation with back button when opened from the dotted menu.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure 0 static analysis errors.
- Run `flutter test` to ensure all existing widget/unit tests pass.

### Manual Verification
- Launch application on desktop/emulator (`flutter run -d windows` or `flutter run --flavor dev`).
- Verify bottom navigation bar has 3 items: Daily List, Mastery, Statistics.
- Tap top 3-dot menu icon on Daily List screen to verify Settings item appears at the top.
- Tap Settings item to verify navigation to Settings screen with functional back button.
