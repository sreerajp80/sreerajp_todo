# Plan: Add Feature Tour Screenshots from Emulator-5554 to README.md

**Status:** Completed

## Issue
The user requested adding more screenshots to [README.md](README.md) using the active Android emulator `emulator-5554`.
Currently, the **App Showcase** contains 9 high-level overview screenshots (`daily_list.png`, `focus_mode.png`, `mastery_deck.png`, `daily_ritual.png`, `ocr_scanner.png`, `ocr_crop_editor.png`, `statistics.png`, `backup_sync.png`, `settings_hub.png`).
However, several deep workflow features in the **Feature Tour** lack visual screenshots:
1. **Task Creation & Editing:** Form with duration, recurrence, tags, sub-tasks, and priority.
2. **Time Tracking & Segments:** Time Segments screen with segment duration breakdown and manual segment indicators.
3. **Bilingual Voice Task Parser:** Modal voice sheet with speech recognition and natural date/duration parsing.
4. **FTS5 & Indic Phonetic Search:** Full-text search with phonetic query matching.
5. **Local Wi-Fi Sync:** Peer-to-peer Wi-Fi synchronization dashboard.
6. **Multi-Format Data Handoff:** Obsidian-ready Markdown and structured JSON export screen.

## Proposed Fix

### 1. Configure SystemUI Demo Mode on `emulator-5554`
- Enable Android SystemUI Demo Mode (`com.android.systemui.demo`) to ensure consistent, clean status bars (12:00, 100% battery, no extraneous icons).

### 2. Capture New Feature Screenshots from `emulator-5554`
- Navigate the app on `emulator-5554` and capture the following screens:
  1. `docs/screenshots/create_task.png`: The Task Creation / Edit screen showing title autocomplete, sub-tasks, duration, priority, and recurrence options.
  2. `docs/screenshots/time_segments.png`: The Time Segments screen for a task with live running segment, recorded intervals, and manual segment indicators.
  3. `docs/screenshots/voice_parser.png`: The bilingual voice task input sheet.
  4. `docs/screenshots/search_phonetic.png`: The SQLite FTS5 search interface displaying search results.
  5. `docs/screenshots/wifi_sync.png`: The Local Wi-Fi Sync screen with discovery and connection options.
  6. `docs/screenshots/data_handoff.png`: The Data Handoff screen showing Markdown and JSON export controls.

### 3. Update Documentation
- **[README.md](README.md):**
  - Embed the newly captured screenshots into the corresponding sections of the **Feature Tour** (e.g., *Creating and Editing Tasks*, *Time Tracking and Live Multi-Timers*, *Bilingual Voice Task Parser*, *FTS5 Search and Indic Phonetic Search*, *Air-QR Optical Transfer & Local Wi-Fi Sync*, *Multi-Format Data Handoff*).
  - Use clean, centered preview cards with consistent widths (`width="320"` or formatted tables).
- **[docs/screenshots/README.md](docs/screenshots/README.md):**
  - Update the catalog table to document all 15 captured screenshots with their descriptions and recommended resolutions.

## Verification Plan
1. Ensure all 6 new PNG files are saved in `docs/screenshots/` without artifacts or distortion.
2. Verify all markdown image links in `README.md` and `docs/screenshots/README.md` use valid relative repository paths.
3. Verify that no absolute paths or machine-specific identifiers are introduced.
4. Run `dart format` and `flutter analyze` to ensure repository integrity.
