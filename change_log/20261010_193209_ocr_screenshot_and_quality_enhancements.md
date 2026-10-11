# OCR: screenshot mode and better text extraction

Implements plan: `plans/20261010_191823_ocr_screenshot_and_quality_enhancements.md`
(including optional step B).

## What changed

### `lib/domain/services/ocr_enhancer.dart`

- New filters in `OcrEnhanceFilter`: `screen` and `adaptiveBw`.
- New `sharpness` field (0–100, default 0) in `OcrEnhanceParams` and `copyWith`.

### `lib/data/services/isolate_ocr_enhancer.dart`

- **No more 1800 px cap.** Images are now limited by a pixel budget instead:
  8 MP for photos (`kOcrPhotoPixelBudget`) and 12 MP for screenshots
  (`kOcrScreenPixelBudget`). Small images are no longer shrunk.
- Resizing now happens **before** the filters and uses **cubic** interpolation, which
  keeps thin strokes sharper. The preview thumbnail still uses linear (display only).
- New helper `ocrScaleFactor`: shrinks images over budget, enlarges screenshots ×2
  (less if the budget is reached, so long scrolling screenshots stay safe), and still
  enlarges short one- or two-line crops. Enlargements under 1.2× are skipped.
- New **Screenshot** filter: grayscale → auto-invert when mostly dark (dark mode,
  `isMostlyDark`) → level stretch → light sharpening.
- New **Shadow fix** filter: grayscale → Sauvola local threshold (`sauvolaBinarize`).
  The local mean and spread are measured on a reduced copy with integral images, so
  memory stays small even for large photos.
- New `unsharpMask` helper. The **Enhance** filter now also stretches levels and
  sharpens lightly; **B&W Document** sharpens lightly after its contrast lift.
- The user's **Sharpness** value (0–100) is applied last, as an unsharp mask.

### `lib/presentation/screens/ocr/ocr_enhance_screen.dart`

- Two new filter chips: "Screenshot" (`ocr-filter-screen-chip`) and "Shadow fix"
  (`ocr-filter-adaptive-chip`).
- New Sharpness slider (0 to 100, key `ocr-sharpness-slider`) in Fine Tune. The reset
  button now also resets sharpness. `_buildAdjustSlider` takes an optional `min`.
- A PNG image (a gallery screenshot) now opens with the Screenshot filter already
  selected. JPEG camera captures still open with Original.

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`

- Tesseract is asked to use adaptive Otsu thresholding (`thresholding_method` = 1).
  Older Tesseract builds ignore the setting.
- `TESSDATA_VERSION` bumped to `2026-10-10-eng-mal-best`, so installed apps copy the
  new English model on next use.

### `assets/tessdata/eng.traineddata` (optional step B)

- Replaced the "fast" English model (about 4 MB) with the official Tesseract **best**
  English model from `tesseract-ocr/tessdata_best` (15,400,601 bytes, Apache-2.0).
  The APK grows by about 11 MB.

### Localization

- New keys in `lib/l10n/app_en.arb` (with `@` descriptions), `app_ml.arb` and
  `app_sa.arb`: `ocrFilterScreen`, `ocrFilterAdaptive`, `ocrSharpnessLabel`.
- Regenerated `lib/l10n/app_localizations*.dart` with `flutter gen-l10n`.

### Tests

- `test/data/services/isolate_ocr_enhancer_test.dart`: large photo kept above the old
  cap; Screenshot filter enlarges and flips dark mode; light screenshot stays the right
  way round; Shadow fix finds ink on both the bright and the shadowed side; sharpness
  firms up an edge; `ocrScaleFactor` and `isMostlyDark` cases.
- `test/presentation/screens/ocr/ocr_enhance_screen_test.dart`: PNG starts on the
  Screenshot filter, JPEG on Original; the new chips pass their filter; the sharpness
  slider value is passed on and reset clears it.

## Checks

- `dart format` — done.
- `flutter analyze` — no issues.
- `flutter test` — all 864 tests passed.
- Not tested here: the native Tesseract setting and the new English model. These need a
  check on a real Android device.

## Notes

- OCR on a full page may be slower than before (bigger images are read).
- Seen but not changed: `docs/architecture.md` still says `NativeOcrService` falls back to
  ML Kit. The code no longer does that (it throws `OcrUnavailableException`).
