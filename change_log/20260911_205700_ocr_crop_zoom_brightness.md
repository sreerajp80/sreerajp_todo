# Change Log: OCR Image Cropping, Zoom Fix, and Brightness Controls

**Date:** 2026-09-11
**Plan Reference:** `plans/20260911_204700_ocr_crop_zoom_brightness.md`

## Summary of Changes
Implemented interactive, lossless image cropping before OCR text recognition, fixed camera zooming and viewport gestures, and added hardware brightness/exposure controls.

### Key Additions & Updates:
1. **Interactive Lossless Image Cropper (`lib/presentation/screens/ocr/ocr_crop_screen.dart`):**
   - Automatically opens after capturing a photo or picking an image from the gallery.
   - Interactive crop box with corner and edge drag handles and center panning.
   - Darkened mask dims surrounding areas to clearly isolate the desired task name and description, eliminating unwanted text.
   - Crops directly from source image pixels using Flutter's built-in `dart:ui` canvas and encodes as lossless PNG, ensuring 100% original optical clarity and text sharpness.
   - "Use Full Image" option to skip cropping if desired.

2. **Camera Viewport Touch & Zoom Fix (`lib/presentation/screens/ocr/widgets/ocr_camera_overlay.dart`):**
   - Wrapped `OcrCameraOverlay` in `IgnorePointer` so all pinch-to-zoom and tap-to-focus touch gestures pass directly through to the camera viewport.
   - Reduced framing mask opacity to allow clear viewing while aligning text.

3. **Fine-Grained Zoom & Brightness Controls (`lib/presentation/screens/ocr/ocr_scan_screen.dart`):**
   - Added mode toggle pill to switch between **Zoom** and **Brightness** adjustments.
   - **Continuous Zoom Slider**:
     - Smooth slider from `_minZoom` to `_maxZoom` with live magnification badge (e.g. `2.4x`).
     - Quick preset chips (`1x`, `2x`, `3x`, `5x`).
   - **Hardware Brightness / Exposure Slider**:
     - Live slider controlling hardware camera exposure offset (`controller.setExposureOffset`).
     - Real-time EV display badge (e.g. `+1.0 EV`, `0.0 EV`, `-0.5 EV`).
     - Quick "Reset" button to instantly restore neutral 0.0 EV exposure.

4. **Localization:**
   - Added English (`lib/l10n/app_en.arb`) and Malayalam (`lib/l10n/app_ml.arb`) localizations for crop screen title, instructions, confirm/skip buttons, and brightness/zoom adjustment labels.

5. **Verification:**
   - Ran `flutter analyze` with 0 warnings or errors.
   - Verified OCR test suite passed (15/15 tests).
