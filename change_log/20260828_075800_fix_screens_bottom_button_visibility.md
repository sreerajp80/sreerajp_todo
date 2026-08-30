# Fix Screen Bottom Inset and Button Visibility Across All Screens

**Plan Reference:** [plans/20260828_075000_fix_screens_bottom_button_visibility.md](plans/20260828_075000_fix_screens_bottom_button_visibility.md)

## Summary of Changes
Fixed bottom button and content clipping across all application screens and bottom sheets caused by Android 3-button and gesture navigation bars.

### Changes Made
1. **Settings Screens:**
   - Wrapped `Scaffold` body in `SafeArea` and applied `padding: const EdgeInsets.fromLTRB(16, 16, 16, 32)` across all settings screens including:
     - `lib/presentation/screens/settings/pending_alerts_screen.dart`
     - `lib/presentation/screens/settings/ritual/ritual_settings_screen.dart`
     - `lib/presentation/screens/settings/security/app_lock_screen.dart`
     - `lib/presentation/screens/settings/date_time/working_days_screen.dart`
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
2. **Primary Screens & Tabs:**
   - `lib/presentation/screens/backup/backup_screen.dart`: Wrapped body in `SafeArea` and updated `ListView` padding to `EdgeInsets.fromLTRB(16, 16, 16, 32)`.
   - `lib/presentation/screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart`: Wrapped tab contents in `SafeArea` with `EdgeInsets.fromLTRB(16, 16, 16, 32)` so "Start Host Server" and "Connect & Sync" buttons are elevated above system navigation bars.
   - `lib/presentation/screens/data_handoff/data_handoff_screen.dart`: Wrapped scroll view in `SafeArea` with `EdgeInsets.fromLTRB(16, 16, 16, 32)`.
   - `lib/presentation/screens/about/about_screen.dart`: Wrapped in `SafeArea` with bottom padding.
   - `lib/presentation/screens/features/features_screen.dart`: Wrapped in `SafeArea` with bottom padding.
   - `lib/presentation/screens/ritual/ritual_deck_screen.dart`: Wrapped in `SafeArea` with bottom padding.
   - `lib/presentation/screens/search_results/search_results_screen.dart`: Wrapped in `SafeArea` with bottom padding.
   - `lib/presentation/screens/time_segments/time_segments_screen.dart`: Wrapped in `SafeArea` and added bottom scroll padding.
3. **Help Hub and Guides:**
   - Wrapped `body` in `SafeArea` with `EdgeInsets.fromLTRB(16, 16, 16, 32)` across `lib/presentation/screens/help/` (`help_home_screen.dart`, `backup_help_screen.dart`, `faq_troubleshooting_help_screen.dart`, `focus_pomodoro_help_screen.dart`, `mastery_deck_help_screen.dart`, `privacy_security_help_screen.dart`, `qr_handoff_help_screen.dart`, `recurring_tasks_help_screen.dart`, `task_management_help_screen.dart`, `time_tracking_help_screen.dart`, `wifi_sync_help_screen.dart`).
4. **Modal Bottom Sheets and Dialogs:**
   - `lib/presentation/screens/daily_list/widgets/evening_reflection_modal.dart`: Added `useSafeArea: true` and wrapped modal content in `SafeArea` with bottom padding.
   - `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart`: Added `useSafeArea: true` and wrapped modal content in `SafeArea`.
   - `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart`: Added `useSafeArea: true` and wrapped form in `SafeArea`.

## Verification
- Code formatted with `dart format`.
- `flutter analyze` completed with 0 errors / 0 warnings.
- `flutter test` completed with all 612 tests passing.
