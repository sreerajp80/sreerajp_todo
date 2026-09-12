# Image Cropping, Zoom Fix, and Brightness Controls for OCR Scanner Plan

**Status:** Implemented
**Date:** 2026-09-11

## Issue
1. **Fixed Camera Rectangle & Unwanted Text**: The camera viewfinder currently shows a fixed rectangle where unwanted background or surrounding text can creep in. The user needs the ability to crop the captured/selected image before OCR runs, ensuring original image quality is preserved without degradation.
2. **Camera Zoom Not Working**: The user was unable to zoom the camera. Investigation showed that the camera overlay was absorbing gesture events because it sat on top of the `GestureDetector` without `IgnorePointer`.
3. **Brightness & Zoom Controls**: Users need clear, manual sliders to control camera brightness (exposure compensation) and fine-grained zoom level during scanning.

## Proposed Fix

### 1. Fix Camera Viewfinder Gestures & Overlay
- Wrap `OcrCameraOverlay` in `IgnorePointer` so touch and pinch gestures pass directly to the camera viewport.
- Replace the rigid fixed rectangle with a clean, unobtrusive framing guide that clearly indicates the user can capture freely and crop unwanted text in the next step.

### 2. Camera Controls: Zoom & Brightness / Exposure Sliders
- In `lib/presentation/screens/ocr/ocr_scan_screen.dart`:
  - **Exposure & Brightness Control**:
    - Read `getMinExposureOffset()`, `getMaxExposureOffset()`, and `getExposureOffsetStepSize()`.
    - Provide an interactive Brightness / Exposure slider with a sun icon (`Icons.wb_sunny_outlined`), showing live EV values (e.g., `-1.0 EV`, `0.0 EV`, `+1.5 EV`) and a quick reset button.
    - Apply changes via `controller.setExposureOffset(value)`.
  - **Zoom Control**:
    - Provide a dedicated continuous Zoom slider alongside quick preset chips (`1x`, `2x`, `3x`).
    - Fix pinch-to-zoom gesture on the viewport.
    - Show live magnification readout badge (e.g. `1.0x`, `2.4x`).
  - **Adjustment Switcher**:
    - A clean toggle bar above the shutter to switch between **Zoom** and **Brightness** sliders.

### 3. Interactive Image Cropper (`OcrCropScreen`)
- Create `lib/presentation/screens/ocr/ocr_crop_screen.dart`:
  - Opens immediately after a photo is captured or selected from the gallery.
  - Displays the full captured image with an interactive, resizable crop box (movable corners, edges, and pan-able framing box).
  - Darkened outer mask showing exactly what will be included and excluding unwanted text.
  - Quick action to "Use Full Image" or "Confirm Crop".
  - Crop execution uses Flutter's built-in `dart:ui` canvas and pixel renderer (`drawImageRect` + `toImage` + lossless PNG export):
    - Zero external packages required.
    - Crops at the exact full resolution of the captured photo so text remains sharp and quality is 100% preserved.
  - Saves the cropped image to a temporary file and forwards it to ML Kit text recognition.

### 4. Localization
- Add strings to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`:
  - Crop screen title ("Crop Text Area" / "ടെക്സ്റ്റ് ഭാഗം ക്രോപ്പ് ചെയ്യുക").
  - Crop instructions ("Drag corners to frame task name and description" / "ടാസ്ക് വിവരങ്ങൾ മാത്രം ഉൾപ്പെടുത്താൻ കോണുകൾ ക്രമീകരിക്കുക").
  - "Scan Cropped Area" / "ക്രോപ്പ് ചെയ്തത് സ്കാൻ ചെയ്യുക".
  - "Full Image" / "മുഴുവൻ ചിത്രം".
  - Brightness/exposure slider labels and reset tooltip.
- Run `flutter gen-l10n`.

### 5. Automated Testing
- Add unit/widget tests for the crop calculation logic and review sheet integration.
- Verify zero analyzer issues with `flutter analyze`.
- Verify full test suite passes with `flutter test`.

## Files to Change
- [NEW] `lib/presentation/screens/ocr/ocr_crop_screen.dart`
- [MODIFY] `lib/presentation/screens/ocr/ocr_scan_screen.dart`
- [MODIFY] `lib/presentation/screens/ocr/widgets/ocr_camera_overlay.dart`
- [MODIFY] `lib/l10n/app_en.arb`
- [MODIFY] `lib/l10n/app_ml.arb`
- [MODIFY] `plans/20260911_204700_ocr_crop_zoom_brightness.md`
