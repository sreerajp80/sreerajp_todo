# Fix Untranslated Malayalam Strings and Flutter Windows Desktop Config

**Plan:** plans/20260829_235300_fix_untranslated_malayalam_strings_and_windows_config.md
**Date:** 2026-08-29

## Changes
- **Malayalam Localization (`lib/l10n/app_ml.arb`):**
  - Added 16 missing NFC-normalized Malayalam translation keys for the Data Handoff (JSON/MD export, import, checklist parsing) and Action Change features.
- **Flutter Configuration:**
  - Enabled Windows desktop support via `flutter config --enable-windows-desktop`.

## Verification
- `flutter gen-l10n`: Completed with 0 untranslated warnings.
- `flutter analyze`: Completed with 0 issues found.
- `flutter test`: All 626 tests passed cleanly.
- `flutter build apk --flavor prod --release --split-per-abi`: Succeeded with code 0 (all 3 release APKs built).
