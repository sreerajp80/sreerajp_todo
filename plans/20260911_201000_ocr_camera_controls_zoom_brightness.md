# OCR Camera Zoom, Brightness, and Exposure Controls Plan

**Status:** Planned
**Date:** 2026-09-11

## Issue
In the OCR camera scanner (`lib/presentation/screens/ocr/ocr_scan_screen.dart`), the user requested enhanced manual control over camera settings during scanning:
- Manual brightness / exposure compensation control (brightening dark documents or dimming glaring papers).
- Fine-grained zoom control (continuous slider alongside quick presets).
- Enhanced camera adjustments accessible while framing documents.

## Proposed Fix

### 1. Camera Controller Exposure & Zoom State
Extend `_OcrScanScreenState`:
- **Exposure / Brightness Control**:
  - Query `getMinExposureOffset()` and `getMaxExposureOffset()` upon camera initialization.
  - Query `getExposureOffsetStepSize()`.
  - Maintain `_minExposure`, `_maxExposure`, `_currentExposure` (defaulting to 0.0 EV).
  - Add `_setExposureOffset(double value)` calling `_controller.setExposureOffset(value)`.
  - Exposure reset action button (quick tap to return to 0.0 EV).
- **Fine-Grained Zoom Control**:
  - Keep pinch-to-zoom and expand preset buttons to `1x`, `2x`, `3x`.
  - Add continuous zoom slider with real-time zoom level badge (e.g., `1.8x`).

### 2. UI Controls Bar & Adjustments Overlay
Add an interactive adjustments panel / toggleable control bar on `OcrScanScreen`:
- **Control Tabs / Toggle**:
  - Mode selector between **Zoom** (`Icons.zoom_in`) and **Brightness** (`Icons.brightness_6_outlined` / `Icons.wb_sunny_outlined`).
- **Interactive Brightness Slider**:
  - Vertical or horizontal smooth slider with sun icon indicators (`Icons.brightness_low` -> `Icons.brightness_high`).
  - EV readout label showing `+0.0 EV`, `+1.0 EV`, `-0.5 EV`.
  - Quick "Reset" button to return to auto / neutral exposure.
- **Interactive Zoom Slider**:
  - Smooth slider with `1x`, `2x`, `3x` quick snap chips.
  - Magnification readout (e.g. `2.4x`).

### 3. Localization
Add ARB keys and descriptions in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`:
- `ocrBrightnessTooltip`: "Brightness / Exposure" / "തെളിച്ചം / എക്സ്പോഷർ"
- `ocrZoomTooltip`: "Zoom" / "സൂം"
- `ocrResetExposure`: "Reset brightness" / "തെളിച്ചം പുനഃക്രമീകരിക്കുക"
- `ocrExposureLevel`: "Exposure: {ev} EV" / "എക്സ്പോഷർ: {ev} EV"
- Run `flutter gen-l10n`.

### 4. Testing & Verification
- Verify widget tests with `flutter test test/presentation/ocr/ocr_result_bottom_sheet_test.dart`.
- Verify full test suite passes with `flutter test`.
- Verify zero warnings with `flutter analyze`.

## Files to Change
- `lib/presentation/screens/ocr/ocr_scan_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_ml.dart`
- `plans/20260911_201000_ocr_camera_controls_zoom_brightness.md`
