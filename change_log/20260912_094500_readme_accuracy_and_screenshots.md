# Change Log: README.md Accuracy Update & Screenshots Strategy

**Date:** 2026-09-12 09:45:00
**Plan:** `plans/20260912_094000_readme_accuracy_and_screenshots.md`

## Summary of Changes

1. **Updated [README.md](README.md):**
   - **Permissions Correction:** Realigned the permissions section with reality. Accurately documented that `CAMERA` is used for the offline OCR scanner and Air-QR optical transfer, `RECORD_AUDIO` is used for the on-device bilingual voice parser, and `POST_NOTIFICATIONS`/`SCHEDULE_EXACT_ALARM` are used for ongoing timers and reminders. Emphasized the core security guarantee that `INTERNET` and telemetry permissions are 100% absent.
   - **Features & Screen Inventory:** Added comprehensive documentation for modern features:
     - Sub-tasks and checklist prerequisite dependencies
     - Spaced repetition task mastery deck (SM-2 SRS algorithm)
     - Daily mindful rituals (morning intention & evening reflection journal)
     - Distraction-free Focus Mode
     - Offline OCR Task Scanner & image editor (crop, rotate, contrast)
     - Bilingual Voice Task Parser (English & Malayalam)
     - FTS5 full-text search and Indic phonetic sandhi search
     - Optical Air-QR transfer and local P2P Wi-Fi synchronization
     - Multi-format data handoff (Markdown & JSON export)
     - Daily progress header and settings customization
   - **Screenshots Showcase:** Upgraded screenshots section to use standard GitHub markdown image references with forward-slash paths pointing to `docs/screenshots/`.
   - **Cross-Platform & Quality Commands:** Updated build, release, and testing instructions.

2. **Created [docs/screenshots/README.md](docs/screenshots/README.md):**
   - Added a detailed guide on required resolutions (1080×2400 for mobile, 1920×1080 for desktop), aspect ratios, naming conventions, sample data privacy rules, and step-by-step instructions for capturing screenshots from Android (via ADB/shortcuts) and Windows desktop.

## Verification
- Verified markdown links and rendering syntax.
- Confirmed zero personal system paths or machine-identifying info in all modified and new files.
