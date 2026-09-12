# Change Log: Update README.md for GitHub Home Page

**Date:** 2026-09-12  
**Plan Reference:** [plans/20260912_192500_update_readme_github_homepage.md](plans/20260912_192500_update_readme_github_homepage.md)

## Summary of Changes

Updated [README.md](README.md) to serve as a comprehensive, visually rich, and accurate GitHub home page for the SreerajP ToDo project:

1. **Header & Repository Badges**:
   - Added centered application logo branding (`assets/splash/splash_logo.png`).
   - Added shields.io badges for Platform (Android & Windows), Flutter (3.44.8), Dart (3.12.2), Security (SQLCipher + AES-256), Privacy (100% Offline | Zero Telemetry), and License (MIT).
2. **Key Highlights**:
   - Outlined core architectural guarantees: 100% offline with zero internet permission, strict day-lock discipline, live multi-timers, on-device OCR and bilingual voice parsing, SM-2 spaced repetition, mindful daily rituals, and air-gapped sync.
3. **App Showcase**:
   - Re-styled the screenshots section with centered responsive containers displaying the 6 high-resolution screenshots from `docs/screenshots/` (`daily_list.png`, `focus_ritual.png`, `mastery_deck.png`, `ocr_voice.png`, `statistics.png`, `backup_sync.png`).
4. **Feature Tour Updates**:
   - Expanded descriptions for on-device OCR image adjustments (crop, rotate, contrast/brightness enhancements), bilingual voice task parsing (English and Malayalam), mastery deck manual tasks and tag grouping, background notifications and scheduled exact alarms (`SCHEDULE_EXACT_ALARM`), and multi-format data handoff.
5. **Technical Architecture Diagram & Tech Stack Matrix**:
   - Documented the 5-layer Clean Architecture (`presentation/`, `application/`, `domain/`, `data/`, `core/`) with responsibilities and technologies used.
6. **Synchronized Route Mappings**:
   - Replaced out-of-date route names with canonical paths from [lib/core/constants/app_routes.dart](lib/core/constants/app_routes.dart) (e.g. `/todo/new`, `/todo/:id`, `/todo/:id/segments`, `/mastery-deck/:id`, `/ocr-scan`, `/ritual/deck`).
7. **Transparent Permissions Ledger**:
   - Clarified purpose of all runtime permissions used (Camera, Record Audio, Notifications, Exact Alarms, Boot Completed) vs absent permissions (Zero Internet, Zero Location, Zero Telephony).
8. **Installation, Build & Verification**:
   - Updated build guides and offline audit commands.
9. **License**:
   - Added MIT License details linked to [LICENSE](LICENSE).

## Verification
- Verified all 11 referenced local paths and images exist in the workspace.
- Ensured zero absolute machine paths, user names, or internal network details exist.
