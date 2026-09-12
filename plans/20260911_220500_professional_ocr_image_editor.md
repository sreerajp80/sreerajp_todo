# Plan: Professional OCR Image Editor & Camera Experience

**Status:** Pending Approval

## Overview
To make the OCR experience industry-leading ("the best"), this plan upgrades the post-capture editing experience into a full-featured Document & Image Pre-Processor before OCR is run:
1. **Interactive Tooling Suite:**
   - **Crop & Frame:** 8-point interactive handles, full image shortcut, reset crop, and a quick aspect framing guide.
   - **Rotation Suite:** 90° Clockwise and 90° Counter-Clockwise rotation with instantaneous live canvas updates.
   - **Document Preset Filters:**
     - *Original:* Untouched photo.
     - *Magic B&W:* High-contrast document binarization (deep black text, bright white paper).
     - *Grayscale:* Clean monochrome tone without harsh black clipping.
     - *Brighten:* High exposure boost for eliminating hand/phone shadows.
   - **Manual Fine-Tuning:** Live sliders for Brightness (-50 to +50) and Contrast (0.5x to 2.5x) with instant preview.
2. **Zoom & Detail Inspection:**
   - 1x / 1.5x / 2x zoom view toggle to inspect fine handwriting or small printed text before cropping.
3. **Camera Polish:**
   - Smooth transition into the editor, high-resolution still capture, and clear framing guide.
4. **User-Driven OCR Trigger:**
   - OCR text extraction only occurs when the user taps the prominent primary button ("Extract Text (OCR)" / "സ്കാൻ ചെയ്യുക").

---

## Files to Change

1. `lib/presentation/screens/ocr/utils/ocr_image_filter.dart` [MODIFY]
   - Add custom dynamic matrix generator `generateMatrix({double brightness, double contrast, bool isGrayscale})`.
   - Add `OcrFilterMode.grayscale`.

2. `lib/presentation/screens/ocr/ocr_crop_screen.dart` [MODIFY]
   - Introduce an editor toolbar with tabs:
     - **Crop & Rotate:** Rotate CW, Rotate CCW, Full Frame, Reset.
     - **Enhance Filters:** Original, Magic B&W, Grayscale, Brighten.
     - **Fine Tune:** Live Brightness and Contrast sliders.
   - Add 1x / 1.5x / 2x zoom toggle to inspect small text.
   - Losslessly render and encode the user's customized image before passing it to ML Kit.

3. `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb` [MODIFY]
   - Add localization strings:
     - `ocrFilterGrayscale` ("Grayscale" / "ഗ്രേസ്കെയിൽ")
     - `ocrRotateCcw` ("Rotate Left" / "ഇടത്തോട്ട് തിരിക്കുക")
     - `ocrTabCrop` ("Crop & Rotate" / "ക്രോപ്പ് & തിരിക്കൽ")
     - `ocrTabFilters` ("Filters" / "ഫിൽട്ടറുകൾ")
     - `ocrTabTune` ("Fine Tune" / "ക്രമീകരിക്കുക")
     - `ocrContrastLabel` ("Contrast" / "കോൺട്രാസ്റ്റ്")
     - `ocrExtractText` ("Extract Text" / "ടെക്സ്റ്റ് കണ്ടെത്തുക")
   - Run `flutter gen-l10n`.

4. `test/presentation/screens/ocr/ocr_image_filter_test.dart` [MODIFY]
   - Add tests for custom matrix generator and new grayscale mode.

---

## Verification Plan

### Automated Tests
- `flutter test test/presentation/screens/ocr/ocr_image_filter_test.dart`
- `flutter test`
- `flutter analyze`

### Manual Verification
- Test all tool tabs: Crop & Rotate (CW and CCW), Filters (Magic B&W, Grayscale, Brighten), and Fine Tune sliders (Brightness and Contrast).
- Verify real-time visual updates on screen.
- Verify that tapping "Extract Text" runs OCR on the tuned image and correctly parses Title and Description.
