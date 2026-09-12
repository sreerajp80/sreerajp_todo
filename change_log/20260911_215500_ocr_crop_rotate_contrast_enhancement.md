# Change Log: Advanced OCR Rotation, Document Contrast/Brightness Enhancement, and Interchange Controls

## Associated Plan
`plans/20260911_215500_ocr_crop_rotate_contrast_enhancement.md`

## Summary of Changes

### 1. Working Real-Time Image Rotation
- Replaced the static `Image.file(...)` rendering in `lib/presentation/screens/ocr/ocr_crop_screen.dart` with `RawImage(image: _decodedImage)` so that 90° clockwise rotations immediately and visibly update on screen.
- Added a prominent, labeled **"Rotate"** button with `Icons.rotate_90_degrees_cw` directly in the bottom editing toolbar.
- Preserved the full resolution rotated image when exporting for OCR processing, ensuring text lines are upright.

### 2. Live Document Enhancement Filters
- Created `lib/presentation/screens/ocr/utils/ocr_image_filter.dart` providing three enhancement modes:
  - **Original:** Natural colors.
  - **B&W Document:** High-contrast grayscale conversion that renders paper background pure white and ink deep black, eliminating shadows and low-contrast issues.
  - **Brighten:** Boosts exposure for underexposed captures.
- Live preview using `ColorFiltered` in the cropper.
- Filters are applied losslessly to the exported PNG so ML Kit receives clean, sharp pixels.

### 3. Portrait & Landscape Responsiveness
- Adapted `OcrCropScreen`, `OcrScanScreen`, and `OcrResultBottomSheet` to dynamically respond to screen orientation.
- In landscape mode, the cropper bottom toolbar becomes compact, preserving screen height for the cropping viewport.
- In `OcrScanScreen`, camera controls adjust margins and shutter size to prevent overflow in landscape mode.
- In `OcrResultBottomSheet`, added a screen height constraint (`0.92x`) ensuring smooth scrolling and keyboard avoidance on landscape screens.

### 4. Prominent Title & Description Interchange Button
- Upgraded the swap button in `OcrResultBottomSheet` into a styled, prominent button with `Icons.swap_vert`, distinct background, and haptic feedback.
- Allows users to flip Title and Description with one tap if text blocks were parsed in reverse order.

### 5. Localization
- Added keys for filter modes (`ocrFilterOriginal`, `ocrFilterBw`, `ocrFilterBrighten`), enhance controls (`ocrEnhanceLabel`), and rotate action (`ocrRotateCw`) in both `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`.
- Regenerated localizations via `flutter gen-l10n`.

### 6. Tests & Validation
- Added unit tests in `test/presentation/screens/ocr/ocr_image_filter_test.dart`.
- Ran `flutter test`: all 705 unit and widget tests passed.
- Ran `flutter analyze`: 0 issues found.
