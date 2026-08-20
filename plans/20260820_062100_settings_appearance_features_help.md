# Implementation Plan: Appearance, Features & Help Hubs for Settings

**Status:** Proposed

## Problem / Requirement
In `SreerajPContactSphere`, the Settings screen features dedicated, rich hubs for **Appearance**, **Features**, and **Help & User Guides**. 
In `sreerajp_todo`, while Appearance settings exist, there are no dedicated **Features** and **Help & User Guides** hubs in Settings, and the card layout in Settings can be enhanced to match the rich visual presentation of ContactSphere.

## Proposed Fix
1. **Features Hub (`lib/presentation/screens/features/features_screen.dart`)**:
   - Create a comprehensive, visual Features showcase screen modeled after ContactSphere.
   - Include a gradient hero card with app icon and description.
   - Group all features into 6 core categories tailored specifically for SreerajP ToDo:
     1. *Daily Tasks & Workflow* (Daily list, Day lock, Unicode NFC normalization, Instant undo, Search & filters).
     2. *Time Tracking & Focus* (Multi-segment time tracking, Single running timer rule, Pomodoro/Focus mode, Live stream timer, Terminal status locks).
     3. *Mastery Deck & Spaced Repetition* (Flashcard decks, Spaced repetition algorithm, Mastery levels, Recurring tasks RRule engine, Bulk task copy).
     4. *Offline Sync & Air QR Transfer* (Local Wi-Fi P2P device sync, Air QR visual beam & scan, Offline data handoff, Zero network offline guarantee).
     5. *Privacy, Security & Storage* (SQLCipher AES-256 database encryption, Biometric & App PIN lock, Screenshot Guard, Password-protected backup ZIPs).
     6. *Customization & Statistics* (Theme modes, Typography & scaling, Productivity stats charts, Task defaults).
   - Provide highlight badge tags for each feature.

2. **Help Center Hub & Topic Screens (`lib/presentation/screens/help/`)**:
   - Create `HelpHomeScreen` with a gradient hero banner and organized topic cards under categories:
     - Task Management & Workflow
     - Time Tracking & Focus Mode
     - Mastery Deck & Habits
     - Sync & Offline Sharing
     - Privacy, Security & Backups
     - Frequently Asked Questions
   - Create detailed, plain-English help topic screens:
     - `task_management_help_screen.dart` (Daily workflow, day-lock immutability, terminal status locks)
     - `time_tracking_help_screen.dart` (Time segments, target duration, single running timer rule)
     - `focus_pomodoro_help_screen.dart` (Focus mode, Pomodoro cycles, auto-stop safeguards)
     - `mastery_deck_help_screen.dart` (Decks, spaced repetition intervals, mastery ratings)
     - `recurring_tasks_help_screen.dart` (RRule schedules, task automation, bulk copying)
     - `wifi_sync_help_screen.dart` (P2P Wi-Fi transfer, pairing, security)
     - `qr_handoff_help_screen.dart` (Air QR scanning, task beam, clipboard handoff)
     - `privacy_security_help_screen.dart` (SQLCipher AES-256, Biometrics/PIN lock, Screenshot Guard)
     - `backup_help_screen.dart` (ZIP backup, password encryption, restore process)
     - `faq_troubleshooting_help_screen.dart` (Top questions, day-lock behavior, offline architecture)

3. **Routing & Navigation**:
   - Register route constants in `lib/core/constants/app_routes.dart` (`AppRoutes.features`, `AppRoutes.help`, and help subroutes).
   - Register `GoRoute` entries in `lib/app.dart`.

4. **Settings Screen Integration (`lib/presentation/screens/settings/settings_screen.dart`)**:
   - Add `SettingsNavCard` entries for **Features** and **Help & User Guides** with matching iconography and styling.
   - Organize Settings cards logically (Appearance, Features, Help, Task Defaults, Date & Time, Time Tracking, Security, Backup, Language, Permissions, About).

5. **Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`)**:
   - Add localized keys for Features and Help titles and subtitles.
   - Run `flutter gen-l10n` to update generated classes.

## Files to Create / Modify
- `lib/core/constants/app_routes.dart` [MODIFY]
- `lib/app.dart` [MODIFY]
- `lib/l10n/app_en.arb` [MODIFY]
- `lib/l10n/app_ml.arb` [MODIFY]
- `lib/presentation/screens/settings/settings_screen.dart` [MODIFY]
- `lib/presentation/screens/features/features_screen.dart` [NEW]
- `lib/presentation/screens/help/help_home_screen.dart` [NEW]
- `lib/presentation/screens/help/task_management_help_screen.dart` [NEW]
- `lib/presentation/screens/help/time_tracking_help_screen.dart` [NEW]
- `lib/presentation/screens/help/focus_pomodoro_help_screen.dart` [NEW]
- `lib/presentation/screens/help/mastery_deck_help_screen.dart` [NEW]
- `lib/presentation/screens/help/recurring_tasks_help_screen.dart` [NEW]
- `lib/presentation/screens/help/wifi_sync_help_screen.dart` [NEW]
- `lib/presentation/screens/help/qr_handoff_help_screen.dart` [NEW]
- `lib/presentation/screens/help/privacy_security_help_screen.dart` [NEW]
- `lib/presentation/screens/help/backup_help_screen.dart` [NEW]
- `lib/presentation/screens/help/faq_troubleshooting_help_screen.dart` [NEW]
- `test/presentation/screens/features_screen_test.dart` [NEW]
- `test/presentation/screens/help_screen_test.dart` [NEW]

## Verification
- Run `flutter analyze` (must be 0 issues).
- Run `flutter test` (all tests passing).
