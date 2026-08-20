# Change Log: Appearance, Features & Help Hubs in Settings

**Plan:** [plans/20260820_062100_settings_appearance_features_help.md](plans/20260820_062100_settings_appearance_features_help.md)

## Summary of Changes
- **Features Showcase Screen (`lib/presentation/screens/features/features_screen.dart`)**:
  - Implemented a rich, categorized Features showcase modeled after `SreerajPContactSphere`.
  - Added a gradient hero banner with app icon and subtitle.
  - Added 6 feature categories tailored for SreerajP ToDo with visual category cards, icons, descriptions, and highlight badge tags:
    1. *Daily Tasks & Workflow* (Unicode NFC normalization, Day lock safeguard, Daily list navigation, Instant undo action, Full-text search).
    2. *Time Tracking & Focus* (Multi-segment time tracking, Single running timer rule, Focus mode & Pomodoro, Live dynamic timer stream, Terminal status locks).
    3. *Mastery Deck & Spaced Repetition* (Spaced repetition flashcards, Custom decks & mastery levels, Recurring tasks & RRule engine, Bulk task copying).
    4. *Offline Sync & Air QR Transfer* (Encrypted local Wi-Fi P2P sync, Air QR task beam & scanner, Offline data handoff, 100% offline operational guarantee).
    5. *Privacy, Security & Storage* (SQLCipher AES-256 database encryption, Biometric & App PIN lock, Screenshot Guard defense, Password-protected encrypted backups).
    6. *Customization & Analytics* (Theme modes & vibrant accents, Typography & text scaling, Productivity statistics charts, Task defaults).

- **Help Center & Topic Screens (`lib/presentation/screens/help/`)**:
  - Created `HelpHomeScreen` with a gradient hero banner and structured topic cards across 6 categories.
  - Created dedicated topic help screens with `HelpIntro`, `HelpSection`, `HelpBullet`, `HelpFaqItem`, and `HelpFooter` tip components:
    - `task_management_help_screen.dart` (Daily workflow, day-lock immutability, terminal status locks)
    - `time_tracking_help_screen.dart` (Time segments, single active timer rule, auto-stop)
    - `focus_pomodoro_help_screen.dart` (Focus screen, Pomodoro work/break intervals, auto-pause)
    - `mastery_deck_help_screen.dart` (Flashcard decks, spaced repetition review intervals, mastery progression)
    - `recurring_tasks_help_screen.dart` (RRule schedules, task automation, bulk copying)
    - `wifi_sync_help_screen.dart` (Local P2P Wi-Fi transfer, security, direct device communication)
    - `qr_handoff_help_screen.dart` (Air QR scanning, task beam, clipboard handoff)
    - `privacy_security_help_screen.dart` (SQLCipher AES-256, Biometrics/PIN lock, Screenshot Guard)
    - `backup_help_screen.dart` (Encrypted ZIP backup creation, password safety, full restore process)
    - `faq_troubleshooting_help_screen.dart` (Top questions, day-lock behavior, offline architecture)

- **Settings Screen Integration (`lib/presentation/screens/settings/settings_screen.dart`)**:
  - Added `SettingsNavCard` entries for **Features** and **Help & User Guides** alongside **Appearance**.

- **Routing & L10n**:
  - Added route constants in `lib/core/constants/app_routes.dart` and `GoRoute` definitions in `lib/app.dart`.
  - Added localized strings in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.

- **Automated Tests**:
  - Created `test/presentation/features_screen_test.dart` and `test/presentation/help_screen_test.dart`.
  - Updated `test/presentation/settings_screen_test.dart` to verify all 10 settings cards and navigation.

## Verification
- `flutter analyze` completed with 0 issues.
- `flutter test` passed all 561 tests.
