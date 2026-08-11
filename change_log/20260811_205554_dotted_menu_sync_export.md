# Change Log: Move Sync and Export Actions to Dotted Overflow Menu

**Plan:** [plans/20260811_205500_dotted_menu_sync_export.md](plans/20260811_205500_dotted_menu_sync_export.md)

## Summary of Changes
- Refactored `DailyListScreen` (`lib/presentation/screens/daily_list/daily_list_screen.dart`) top app bar actions to replace 4 individual action icons (`AirQR Share`, `AirQR Scan`, `Local P2P Wi-Fi Sync`, `Data Handoff`) with a unified 3-dot overflow menu (`PopupMenuButton<_AppBarMoreOption>` using `Icons.more_vert`).
- Added localized title strings and descriptions in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` for `wifiSyncTitle`, `airQrShareTitle`, `airQrScanTitle`, and `moreOptions`.
- Re-generated localizations (`flutter gen-l10n`).
- Extracted helper method `_handleAirQrScan()` and defined `enum _AppBarMoreOption`.

## Verification Results
- Ran `flutter gen-l10n` — Generated cleanly.
- Ran `flutter analyze` — 0 issues found.
