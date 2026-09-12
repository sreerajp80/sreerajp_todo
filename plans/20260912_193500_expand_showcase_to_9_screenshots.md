# Plan: Expand Showcase to 9 Screens on Emulator-5554

**Status:** Completed

## Issue
The user requested expanding the App Showcase in [README.md](README.md) to 9 screens by capturing real screens from `emulator-5554`:
1. Daily Task List (`daily_list.png`)
2. Distraction-Free Focus Mode (`focus_mode.png`)
3. Spaced Repetition Mastery Deck (`mastery_deck.png`)
4. Guided Daily Ritual (`daily_ritual.png`)
5. Offline OCR Document Scanner (`ocr_scanner.png`)
6. OCR Crop & Document Editor (`ocr_crop_editor.png`)
7. Productivity Statistics Dashboard (`statistics.png`)
8. Backup Health & Optical Sync (`backup_sync.png`)
9. Settings Hub (`settings_hub.png`)

## Proposed Changes

### 1. Configure SystemUI Demo Mode on `emulator-5554`
- Enable Android SystemUI Demo Mode to ensure clean status bars across all 9 captures (100% battery, 12:00 clock, full Wi-Fi, zero clutter).

### 2. Populate Sample Data & Navigate Screens
- Populate sample tasks (In-Progress with live running timer, Completed, Pending with sub-tasks, Dropped).
- Add sample Mastery Deck cards with retention rating.
- Navigate to and capture:
  1. `docs/screenshots/daily_list.png`: Daily list with progress bar, active running timer, and task cards.
  2. `docs/screenshots/focus_mode.png`: Focus Mode screen with radial countdown timer and task controls.
  3. `docs/screenshots/mastery_deck.png`: Spaced Repetition Mastery Deck with practice deck cards.
  4. `docs/screenshots/daily_ritual.png`: Guided Daily Ritual contemplation and intention screen.
  5. `docs/screenshots/ocr_scanner.png`: Offline OCR scanner viewfinder with document reticle.
  6. `docs/screenshots/ocr_crop_editor.png`: Document crop, rotation, and contrast enhancement editor.
  7. `docs/screenshots/statistics.png`: Productivity statistics dashboard with completion rate bar charts.
  8. `docs/screenshots/backup_sync.png`: Backup Health dashboard with AES-256 backup controls and Air-QR sync.
  9. `docs/screenshots/settings_hub.png`: Settings Hub showing appearance, time tracking, and security cards.

### 3. Update [README.md](README.md)
- Update the **App Showcase** section into a clean 3x3 table highlighting all 9 core feature views with descriptive captions.
- Update the screenshots table in [docs/screenshots/README.md](docs/screenshots/README.md).

## Verification Plan
1. Validate that all 9 images are saved in `docs/screenshots/` as crisp, full-color PNGs.
2. Verify that `README.md` and `docs/screenshots/README.md` reference all 9 screenshots using relative paths.
3. Check for zero machine-specific details or absolute paths.
