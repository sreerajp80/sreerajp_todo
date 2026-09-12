# Change Log: Capture App Showcase Screenshots

**Date:** 2026-09-12 09:55:00
**Related Plan:** `plans/20260912_094600_capture_app_screenshots.md`

## Summary of Changes

Captured and verified all 6 showcase screenshots required by `README.md` using the active Android emulator running the production release APK (`app-x86_64-prod-release.apk`).

## Captured Artifacts

1. **Daily List View (`docs/screenshots/daily_list.png`)**
   - Clean status bar via Android SystemUI Demo Mode.
   - Shows active daily list with a morning intention card ("Ship production v1.14.5 release docs").
   - Shows daily completion progress bar (33%).
   - Displays realistic sample tasks across multiple states: in-progress with live running timer, completed with revert button, and pending with quick-start action.

2. **Focus Mode & Rituals (`docs/screenshots/focus_ritual.png`)**
   - Immersive full-screen focus timer with radial progress ring.
   - Shows active task title, elapsed/target duration countdown, and pause/stop controls.

3. **Mastery Deck (`docs/screenshots/mastery_deck.png`)**
   - Spaced Repetition Mastery Deck screen showing daily review counter and mastery progression.
   - Shows active learning task ("Master Riverpod State Notifiers") ready for interval review.

4. **Offline OCR & Voice (`docs/screenshots/ocr_voice.png`)**
   - On-device ML Kit OCR viewfinder with text boundary reticle and camera controls.
   - Displays offline OCR capture interface for digitizing handwritten notes directly into structured todos.

5. **Statistics & Insights (`docs/screenshots/statistics.png`)**
   - Analytics dashboard showing daily overview bar chart.
   - Displays status breakdown, total time tracked, and completion rate cards.

6. **Encrypted Backup & Air-QR Transfer (`docs/screenshots/backup_sync.png`)**
   - Dual-key backup screen featuring the Backup Health Dashboard.
   - Displays AES-256 ZIP export/restore cards and Air-QR offline sync icons.

## Verification

- Verified all 6 image files exist in `docs/screenshots/` and match image preview standards.
- Removed temporary scratch buffer files.
- Confirmed relative links in `README.md` correctly target each captured image.
