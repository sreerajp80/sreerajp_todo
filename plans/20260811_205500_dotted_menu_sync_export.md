# Plan: Move Sync and Export Actions to Dotted Overflow Menu

**Status:** Planned

## Goal
Clean up the top app bar in `DailyListScreen` by creating a 3-dot overflow menu (`Icons.more_vert`) and moving the Sync (Local P2P Wi-Fi Sync, AirQR Share, AirQR Scan) and Export (Data Handoff JSON & Markdown) action buttons into it.

## Issue
The top app bar in `DailyListScreen` currently renders up to 11 individual icon buttons side-by-side (`Today`, `Calendar`, `Search`, `Copy Wizard`, `AirQR Share`, `AirQR Scan`, `Local P2P Wi-Fi Sync`, `Data Handoff Export`, `Evening Reflection`, `Undo`, `Sort`). On mobile screens and narrow viewports, this causes severe icon crowding and horizontal overflow as captured in the UI screenshot.

## Proposed Changes

### 1. Localization (`lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`)
- Add localized string keys with complete metadata:
  - `wifiSyncTitle`: "Local P2P Wi-Fi Sync"
  - `airQrShareTitle`: "AirQR Share Stream"
  - `airQrScanTitle`: "AirQR Scan Camera"
  - `moreOptions`: "More options"

### 2. Daily List Screen (`lib/presentation/screens/daily_list/daily_list_screen.dart`)
- Remove the 4 individual action icons for AirQR Share, AirQR Scan, Wi-Fi Sync, and Data Handoff from `_buildNormalAppBar`.
- Add a new 3-dot overflow menu using `PopupMenuButton` with `Icons.more_vert`.
- Render the 4 items inside the overflow popup menu with clear icons, localized labels, and clean tap handlers:
  1. `Local P2P Wi-Fi Sync` (`Icons.wifi_tethering`)
  2. `AirQR Share Stream` (`Icons.qr_code_2`)
  3. `AirQR Scan Camera` (`Icons.qr_code_scanner`)
  4. `Data Handoff (JSON & MD)` (`Icons.import_export_rounded`)

## Verification Plan
- Run `flutter gen-l10n` to rebuild localization classes.
- Run `flutter analyze` to ensure 0 lint or static analysis issues.
- Run `flutter test` to ensure all widget and unit tests pass cleanly.
