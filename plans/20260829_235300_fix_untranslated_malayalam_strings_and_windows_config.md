# Fix Untranslated Malayalam Strings and Enable Windows Desktop Config

**Status:** Proposed

## Problem
1. When building the application, Flutter l10n warns that 16 messages are untranslated in `lib/l10n/app_ml.arb` (pertaining to Data Handoff and Action Change features).
2. The local Flutter environment does not have Windows desktop support enabled (`flutter config --enable-windows-desktop`).

## Fix
1. Add the 16 missing translations with NFC normalization to `lib/l10n/app_ml.arb`.
2. Enable Windows desktop build in Flutter config.
3. Regenerate l10n and run full test and build verification.

## Files to Change
- `lib/l10n/app_ml.arb` (relative repo path)

## Verification
- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- `flutter build apk --flavor prod --release --split-per-abi`
- `flutter build windows --release`
