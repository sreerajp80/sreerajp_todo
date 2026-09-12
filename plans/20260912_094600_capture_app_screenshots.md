# Plan: Capture Release Screenshots on Emulator

**Status:** Completed
**Date:** 2026-09-12 09:46:00

## 1. Issue Description
`README.md` references 6 showcase screenshots in `docs/screenshots/`:
- `docs/screenshots/daily_list.png`
- `docs/screenshots/focus_ritual.png`
- `docs/screenshots/mastery_deck.png`
- `docs/screenshots/ocr_voice.png`
- `docs/screenshots/statistics.png`
- `docs/screenshots/backup_sync.png`

The emulator `emulator-5554` (x86_64) is running, and the release APK `build/app/outputs/flutter-apk/app-x86_64-prod-release.apk` has been compiled. We need to install the application, create realistic demo data, navigate to each required screen, and capture high-resolution screenshots into `docs/screenshots/`.

## 2. Proposed Changes

### Files to Create / Capture:
- `docs/screenshots/daily_list.png`
- `docs/screenshots/focus_ritual.png`
- `docs/screenshots/mastery_deck.png`
- `docs/screenshots/ocr_voice.png`
- `docs/screenshots/statistics.png`
- `docs/screenshots/backup_sync.png`

### Execution Steps:
1. **Install APK:** Install `build/app/outputs/flutter-apk/app-x86_64-prod-release.apk` onto `emulator-5554` using ADB.
2. **Grant Permissions:** Grant runtime permissions (`POST_NOTIFICATIONS`, etc.) so dialogues do not obscure screenshots.
3. **Launch & Setup Sample Data:**
   - Launch `in.sreerajp/in.sreerajp.sreerajp_todo.MainActivity`.
   - Add clean sample tasks with different statuses (Pending with running timer, Completed, Dropped, Ported).
   - Add sub-tasks, a target duration, and a morning intention.
4. **Capture Screenshots:**
   - **Daily List:** Main list view with progress header, tasks, and running timer (`daily_list.png`).
   - **Focus / Ritual:** Focus mode screen or Morning Intention & Reflection (`focus_ritual.png`).
   - **Mastery Deck:** Spaced repetition deck screen (`mastery_deck.png`).
   - **OCR / Voice:** OCR Scanner screen or Voice Input bottom sheet (`ocr_voice.png`).
   - **Statistics:** Statistics dashboard showing charts and table (`statistics.png`).
   - **Backup & Sync:** Backup screen showing backup health dashboard and export options (`backup_sync.png`).
5. **Verify & Optimize:** Ensure images are crisp, properly sized, and correctly referenced in `README.md`.

## 3. Verification Plan
- Inspect each generated screenshot in `docs/screenshots/`.
- Ensure all 6 files are present, valid PNGs, and match the references in `README.md`.
