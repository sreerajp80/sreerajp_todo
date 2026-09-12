# Plan: Advanced OCR Enhancements — Working Rotation, Document Contrast/Brightness Filters, Zoom Cropping, Portrait/Landscape Adaptation, and Field Interchange

**Status:** Approved by User

## Overview
This plan addresses all user feedback:
1. **Fix Image Rotation & Display Bug:** In `OcrCropScreen`, rotating the image modified `_decodedImage` in memory, but line 385 rendered `Image.file(File(widget.imagePath))`. We will replace it with `RawImage(image: _decodedImage)` so rotation visually updates immediately on screen.
2. **Prominent Rotation Controls:** Add a clear, prominent "Rotate 90°" button with icon and label in the bottom editing toolbar so users never have to search for it.
3. **Contrast & Brightness Document Filters:** Raw photos often have uneven lighting, shadows, or low contrast, making OCR misread or drop text. We will add real-time document enhancement presets:
   - **Original:** Natural colors.
   - **Document B&W (High Contrast):** Converts to grayscale and boosts contrast, separating text cleanly from paper background (industry-standard for OCR).
   - **Brighten:** Boosts exposure to eliminate shadows and dim lighting.
   These filters will be previewed live and applied to the image pixels sent to ML Kit.
4. **Zoom & Fine Cropping:** Provide zoom capability (quick 1x / 2x toggle and smooth view) so users can inspect small text and adjust the crop boundaries with precision.
5. **Portrait & Landscape Mode Support:**
   - **OcrCropScreen:** Adapts controls gracefully in both portrait and landscape (side toolbar or compact bar in landscape so image area is maximized).
   - **OcrScanScreen:** Viewfinder and camera controls adapt to device orientation.
   - **OcrResultBottomSheet:** Responsive layout ensuring all fields and buttons are easily visible and scrollable in both portrait and landscape orientations.
6. **Interchange Title & Description:** Make the swap/interchange button between Title and Description highly prominent (styled pill/card button with `Icons.swap_vert`, distinct background, and haptic feedback) so users can easily flip them with a single tap if text was detected in reverse order.

---

## Files to Change

1. `lib/presentation/screens/ocr/utils/ocr_image_filter.dart` [NEW]
   - Encapsulates color filter matrices for OCR optimization (High Contrast B&W, Grayscale, Brightness boost).
   - Pure Flutter utility with zero external dependencies (uses standard Flutter `ColorFilter.matrix`).

2. `lib/presentation/screens/ocr/ocr_crop_screen.dart` [MODIFY]
   - Switch display to `RawImage(image: _decodedImage)` so rotations are visible immediately.
   - Add image enhancement modes: `original`, `documentBw` (high contrast), and `brighten`.
   - Add real-time `ColorFilter.matrix` preview and apply the filter when exporting cropped or full image.
   - Add prominent bottom toolbar with Rotate 90°, Enhance filter toggles, Use Full Image, and Confirm Crop.
   - Support landscape layout (responsive toolbar layout so crop viewport has ample space).
   - Add zoom toggle (1x / 2x / fit) or zoomable viewport.

3. `lib/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart` [MODIFY]
   - Upgrade the Interchange/Swap button into a prominent, styled button with haptic feedback and clear text ("⇄ Interchange Title & Description").
   - Ensure landscape responsiveness: scrollable layout with keyboard avoidance and proper max heights.

4. `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` [MODIFY]
   - Add localization strings for enhancement modes and interchange:
     - `ocrFilterOriginal` ("Original" / "യഥാർത്ഥം")
     - `ocrFilterBw` ("B&W Document" / "ഹൈ കോൺട്രാസ്റ്റ്")
     - `ocrFilterBrighten` ("Brighten" / "വെളിച്ചം കൂട്ടുക")
     - `ocrZoom` ("Zoom" / "വലുതാക്കുക")
     - `ocrSwapFieldsPrompt` ("Interchange Title & Description" / "ശീർഷകവും വിവരണവും പരസ്പരം മാറ്റുക")
   - Run `flutter gen-l10n`.

5. `test/presentation/screens/ocr/ocr_image_filter_test.dart` [NEW]
   - Unit tests verifying the color filter matrix values and transformations.

---

## Verification Plan

### Automated Tests
- Run `flutter test test/presentation/screens/ocr/ocr_image_filter_test.dart`
- Run all project tests: `flutter test`
- Run static analysis: `flutter analyze`

### Manual Verification
- Test image rotation: Verify that clicking "Rotate 90°" immediately rotates the image on screen in both portrait and landscape modes.
- Test filter toggles: Switch between Original, B&W High Contrast, and Brighten; confirm live preview and improved text legibility.
- Test interchange button: Verify that tapping the interchange button instantly swaps Title and Description in the review sheet.
- Test landscape mode: Hold device in landscape, verify crop screen, camera, and result sheet lay out cleanly and comfortably.
