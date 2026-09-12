# Plan: README.md Accuracy Update & Screenshots Strategy

**Status:** Completed
**Date:** 2026-09-12 09:40:00

## 1. Issue Description
The project `README.md` was written during an early v1.0 stage and contains out-of-date information and inaccuracies when compared to the active production codebase (v1.14.4+39):
1. **Inaccurate Permissions Table:** `README.md` states that the app does not request Camera, Microphone, or Notifications permissions. In the actual app, `CAMERA` is used for Air-QR scanning and OCR task scanning, `RECORD_AUDIO` is used for on-device voice task parsing, and `POST_NOTIFICATIONS`/`SCHEDULE_EXACT_ALARM` are used for live timers and background reminders. The true security guarantee is **zero internet access** (no `INTERNET` permission, zero network analytics/cloud).
2. **Missing Key Modern Features:** Features implemented in later phases are missing from the features and screen tables:
   - Sub-tasks & Checklist Dependencies
   - Daily Mindful Intention & Evening Reflection (Mindful Ritual)
   - Spaced Repetition Task Mastery Deck (SM-2 SRS)
   - FTS5 Full-Text Search with Indic Phonetic Sandhi Search
   - Air-QR Optical Device-to-Device Sync
   - Local Offline Wi-Fi P2P Sync
   - Multi-Format Data Handoff (Markdown & JSON export)
   - Bilingual Voice Task Parser (English & Malayalam)
   - Offline OCR Task Scanner & Image Editor
   - Focus Mode
   - Background Alarms & Ongoing Live Timer Notifications
   - Settings (Appearance, Language selector, Task defaults, Security)
3. **Screenshots Section:** The section uses broken Windows backslash paths (`docs\screenshots\...`) and lists only 3 screens. Currently, no screenshots exist in the repository. For GitHub publishing, screenshots need a clean structure, GitHub-compatible markdown, and clear instructions/placeholders.
4. **Path & Formatting Consistency:** Ensure all file paths in `README.md` use forward slashes (`docs/...`) for GitHub rendering.

## 2. Proposed Changes

### File: `README.md`
- **Header & Version:** Update app overview reflecting current state, offline-first guarantees, and multi-platform support.
- **Screenshots Section:**
  - Create standard GitHub markdown image references pointing to `docs/screenshots/`.
  - Provide a curated set of key showcase screenshots (Daily List & Timer, Focus Mode, Spaced Repetition Mastery Deck, Offline OCR & Voice, Statistics & Charts, Backup & Sync).
- **Features at a Glance:**
  - Update feature list to include sub-tasks, ritual mode, mastery deck, OCR, voice input, Air-QR, Wi-Fi sync, FTS5 search, notifications, and language selector.
- **How the App Works:**
  - Add concise descriptions for sub-tasks, daily ritual, mastery deck, offline OCR, voice parsing, Air-QR transfer, and focus mode.
- **Permissions:**
  - Correct the permissions table: accurately explain what permissions are used (Camera for OCR/Air-QR, Microphone for offline voice parser, Notifications/Alarms for timer/reminders).
  - Strongly emphasize the **zero internet** offline guarantee (`INTERNET` permission is completely absent).
- **App Screens:**
  - Update the screen directory table to include all current screens.
- **Build & Verification:**
  - Update instructions to align with current scripts and Flutter 3.44.8 / Dart 3.12.2.

### Directory: `docs/screenshots/`
- Create `docs/screenshots/` directory with a guide (`docs/screenshots/README.md`) explaining the exact dimensions, naming conventions, and commands to capture clean screenshots.

## 3. Verification Plan
1. Validate `README.md` links and markdown formatting.
2. Check that all documented features accurately match `docs/features.md` and codebase implementations.
3. Verify zero privacy leaks (no personal paths or system info).
4. Run `flutter analyze` and markdown lint check.
