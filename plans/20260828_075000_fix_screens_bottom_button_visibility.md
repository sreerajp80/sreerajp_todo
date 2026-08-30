# Fix Screen Bottom Inset and Button Visibility Across All Screens

**Status:** Ready for Review

## Problem Description
On mobile devices (especially Android with 3-button or gesture navigation bars), buttons and content placed at the bottom of scrollable screens and bottom sheets are partially or completely covered by the system navigation bar (such as the "Preview alert" button on the Pending Task Alerts screen, "Run ritual now" on Ritual Settings, "Connect & Sync" on P2P Sync, and action buttons in modal sheets).

In a previous fix for the Create/Edit task screen (`plans/20260827_212840_fix_save_button_visibility.md`), this issue was resolved by wrapping the body in a `SafeArea` and providing generous bottom padding (`EdgeInsets.fromLTRB(16, 16, 16, 32)`).

We need to analyze and apply this consistent fix across all screens and bottom sheets in the application.

## Proposed Changes

### 1. Settings Screens
Wrap `Scaffold` body in `SafeArea` and ensure `ListView` padding is `EdgeInsets.fromLTRB(16, 16, 16, 32)`:
- `lib/presentation/screens/settings/pending_alerts_screen.dart` (Preview alert button)
- `lib/presentation/screens/settings/ritual/ritual_settings_screen.dart` (Run ritual now button)
- `lib/presentation/screens/settings/security/app_lock_screen.dart` (Secret change button)
- `lib/presentation/screens/settings/date_time/working_days_screen.dart` (Reset button)
- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/presentation/screens/settings/accent_color_screen.dart`
- `lib/presentation/screens/settings/appearance_screen.dart`
- `lib/presentation/screens/settings/date_time_screen.dart`
- `lib/presentation/screens/settings/language_screen.dart`
- `lib/presentation/screens/settings/permissions_screen.dart`
- `lib/presentation/screens/settings/security_screen.dart`
- `lib/presentation/screens/settings/task_defaults_screen.dart`
- `lib/presentation/screens/settings/theme_mode_screen.dart`
- `lib/presentation/screens/settings/time_tracking_screen.dart`
- `lib/presentation/screens/settings/typography_screen.dart`
- `lib/presentation/screens/settings/date_time/clock_format_screen.dart`
- `lib/presentation/screens/settings/date_time/date_format_screen.dart`
- `lib/presentation/screens/settings/date_time/day_start_screen.dart`
- `lib/presentation/screens/settings/date_time/week_start_screen.dart`
- `lib/presentation/screens/settings/task_defaults/defaults_autocomplete_screen.dart`
- `lib/presentation/screens/settings/task_defaults/defaults_day_list_screen.dart`
- `lib/presentation/screens/settings/task_defaults/defaults_new_task_screen.dart`
- `lib/presentation/screens/settings/task_defaults/defaults_task_actions_screen.dart`
- `lib/presentation/screens/settings/time_tracking/auto_stop_screen.dart`
- `lib/presentation/screens/settings/time_tracking/focus_mode_screen.dart`
- `lib/presentation/screens/settings/time_tracking/pomodoro_screen.dart`
- `lib/presentation/screens/settings/time_tracking/time_display_screen.dart`
- `lib/presentation/screens/settings/time_tracking/timer_behaviour_screen.dart`

### 2. Primary Screens & Tabs
- `lib/presentation/screens/backup/backup_screen.dart` (Wrap in `SafeArea` with bottom padding)
- `lib/presentation/screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart` (Wrap tab views in `SafeArea` with bottom padding)
- `lib/presentation/screens/data_handoff/data_handoff_screen.dart` (Wrap in `SafeArea` with bottom padding)
- `lib/presentation/screens/about/about_screen.dart` (Wrap in `SafeArea` with bottom padding)
- `lib/presentation/screens/features/features_screen.dart` (Wrap in `SafeArea` with bottom padding)
- `lib/presentation/screens/search_results/search_results_screen.dart` (Wrap in `SafeArea` with bottom padding)
- `lib/presentation/screens/ritual/ritual_deck_screen.dart` (Wrap in `SafeArea` with bottom padding)

### 3. Help Screens
Wrap `body` in `SafeArea` and ensure `EdgeInsets.fromLTRB(16, 16, 16, 32)` on:
- `lib/presentation/screens/help/help_home_screen.dart`
- `lib/presentation/screens/help/backup_help_screen.dart`
- `lib/presentation/screens/help/faq_troubleshooting_help_screen.dart`
- `lib/presentation/screens/help/focus_pomodoro_help_screen.dart`
- `lib/presentation/screens/help/mastery_deck_help_screen.dart`
- `lib/presentation/screens/help/privacy_security_help_screen.dart`
- `lib/presentation/screens/help/qr_handoff_help_screen.dart`
- `lib/presentation/screens/help/recurring_tasks_help_screen.dart`
- `lib/presentation/screens/help/task_management_help_screen.dart`
- `lib/presentation/screens/help/time_tracking_help_screen.dart`
- `lib/presentation/screens/help/wifi_sync_help_screen.dart`

### 4. Bottom Sheets and Forms
- `lib/presentation/screens/daily_list/widgets/evening_reflection_modal.dart`: Add `useSafeArea: true` and wrap with `SafeArea`.
- `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart`: Add `useSafeArea: true` and wrap with `SafeArea`.
- `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart`: Wrap in `SafeArea` so the Save and Cancel buttons are elevated above system navigation bars.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure all existing tests continue to pass.
- Run `flutter analyze` to ensure 0 static analysis errors/warnings.

### Manual Verification
- Verify that on screens with bottom buttons (like Pending Task Alerts, Ritual Settings, Working Days, P2P Sync, Backup, and Create/Edit task), the buttons sit comfortably above the Android navigation bar and are completely visible.
