# Change Log: Add Feature Tour Screenshots to README.md

**Date:** 2026-09-12  
**Plan:** [plans/20260912_213500_add_feature_tour_screenshots.md](../plans/20260912_213500_add_feature_tour_screenshots.md)

## Summary of Changes

Captured 6 additional high-resolution feature screenshots directly from the Android app on `emulator-5554` with SystemUI demo mode enabled, and integrated them into the **Feature Tour** sections of `README.md` and the screenshot inventory in `docs/screenshots/README.md`:

1. **Creating and Editing Tasks (`docs/screenshots/create_task.png`)**: Shows the task creation form with title autocomplete, description field, priority selectors (Low, Normal, High, Urgent), target duration controls, and sub-task input.
2. **Bilingual Voice Task Parser (`docs/screenshots/voice_parser.png`)**: Shows the voice parsing bottom sheet with English and Malayalam language toggle and live speech capture indicator.
3. **Time Segments & Manual Entry (`docs/screenshots/time_segments.png`)**: Shows the time tracking log with active running timer, segment list, and manual time entry button.
4. **FTS5 & Phonetic Search (`docs/screenshots/search_phonetic.png`)**: Shows the SQLite FTS5 search interface displaying matched tasks with status badges and Indic phonetic search support.
5. **Local P2P Wi-Fi Sync (`docs/screenshots/wifi_sync.png`)**: Shows the local peer-to-peer Wi-Fi synchronization dashboard with sync scope options and host/peer connection controls.
6. **Multi-Format Data Handoff (`docs/screenshots/data_handoff.png`)**: Shows the Markdown and JSON data export interface with preview and sharing actions.

## Updated Files

- `README.md`: Embedded centered preview screenshots into 6 Feature Tour subsections (*Creating and Editing Tasks*, *Bilingual Voice Task Parser*, *Manual Time Entry & Overlap Validation*, *FTS5 Search and Indic Phonetic Search*, *Air-QR Optical Transfer & Local Wi-Fi Sync*, and *Multi-Format Data Handoff*).
- `docs/screenshots/README.md`: Expanded the catalog from 9 to 15 screenshots, categorizing them into Main App Showcase (9 screens) and Feature Tour Screens (6 screens).
- `docs/screenshots/`: Added 6 new lossless PNG screenshots.
- `plans/20260912_213500_add_feature_tour_screenshots.md`: Marked status as Completed.
