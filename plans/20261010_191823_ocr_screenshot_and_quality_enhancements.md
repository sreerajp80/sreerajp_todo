# OCR: screenshot mode and better text extraction

**Status:** completed

## The issue

Text extraction on the OCR enhance screen is poor, even for clean English-only text.
Screenshots are the worst case. Reading the code shows these causes:

1. **Images are shrunk before OCR.** `processOcrImageIsolate` caps the longest edge at
   1800 px. A normal phone screenshot (1080 × 2400) is shrunk to 810 × 1800. Small UI
   text then has letters only about 10–12 px tall. Tesseract (the OCR engine) needs
   letters about 20–35 px tall to read well. Camera photos lose detail the same way: a
   full page at 1800 px is only about 150 dpi.
2. **No upscaling for screenshots.** Small text is only enlarged when the whole image is
   shorter than 220 px (a one-line crop). Screen text is never enlarged.
3. **Resizing uses simple "linear" interpolation**, which blurs thin letter strokes.
4. **No sharpening.** Anti-aliased screen text and slightly soft camera photos give soft
   letter edges.
5. **Dark-mode screenshots** (light text on dark background) need a manual "Invert" tap.
   The native side only tries inverted text when the whole image is very dark.
6. **Uneven light / shadows on photos.** The "B&W Document" filter uses one global
   contrast boost. A shadow over part of the page turns that part grey or black, and the
   text there is lost.
7. **The English model is the "fast" model** (`assets/tessdata/eng.traineddata`, 4 MB).
   The "best" model (about 15 MB) is noticeably more accurate. (Malayalam already uses
   the best model.) — see Optional step B.

## Plan for the fix

### A. Image pipeline (Dart) — `lib/data/services/isolate_ocr_enhancer.dart`

1. **Replace the 1800 px cap with a pixel budget** (about 8 MP for photos). A 4000 px
   camera master is kept at about 3260 × 2450 instead of 1800 px. Small images are not
   shrunk at all.
2. **New filter `screen` ("Screenshot")**, made for screen captures:
   - grayscale (by brightness, so coloured buttons and chips become plain grey),
   - **auto-invert** when the image is mostly dark (dark mode), so light text becomes
     dark text on light background,
   - level stretch (existing `normalizeOcrLevels`),
   - **upscale ×2** (less if the image is already big; kept inside a 12 MP budget, so
     long scrolling screenshots are safe) with **cubic** interpolation,
   - light sharpening.
3. **New filter `adaptiveBw` ("Shadow fix")** for photos with shadows or uneven light:
   a local (adaptive) black-and-white threshold (Sauvola method, computed fast with
   integral images). Each pixel is compared with its own neighbourhood, not the whole
   page, so text in a shadow stays readable.
4. **Improve existing filters:**
   - `enhance`: add level stretch and light sharpening.
   - `documentBw`: add light sharpening after the contrast lift.
5. **New "Sharpness" slider (0–100)** in the Fine Tune tab, using an unsharp mask. Default
   0 (filters add their own light sharpening).
6. **Use cubic interpolation** for every resize meant for OCR (preview thumbnail stays
   linear — it is only for display).
7. Small helper functions stay top-level and pure, so they can be unit tested:
   `isMostlyDark`, `sauvolaThreshold`, `unsharpMask`, `ocrScaleFactor`.

### B. Domain contract — `lib/domain/services/ocr_enhancer.dart`

- Add `screen` and `adaptiveBw` to `OcrEnhanceFilter`.
- Add `sharpness` (int, 0–100, default 0) to `OcrEnhanceParams` and `copyWith`.

### C. Screen — `lib/presentation/screens/ocr/ocr_enhance_screen.dart`

- Add the two new filter chips ("Screenshot", "Shadow fix").
- Add the Sharpness slider (0 to 100) to Fine Tune; the reset button also resets it.
- **Auto-pick the Screenshot filter** when the opened image is a PNG file (gallery
  screenshots are PNG; camera captures are JPEG). The user can still change it.

### D. Native OCR — `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`

- Ask Tesseract to use its adaptive binarizer (`thresholding_method` = 1, adaptive Otsu)
  instead of plain global Otsu. `setVariable` simply returns false if the bundled
  Tesseract does not know it, so this is safe.
- No other native logic changes.

### E. Localization — `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`

New keys, each with an `@key` description, in all three languages, then
`flutter gen-l10n`:

| Key | English | Malayalam | Sanskrit |
|-----|---------|-----------|----------|
| `ocrFilterScreen` | Screenshot | സ്ക്രീൻഷോട്ട് | पटलचित्रम् |
| `ocrFilterAdaptive` | Shadow fix | നിഴൽ നീക്കം | छायानिवारणम् |
| `ocrSharpnessLabel` | Sharpness | മൂർച്ച | तीक्ष्णता |

### F. Tests

- `test/data/services/isolate_ocr_enhancer_test.dart`:
  - a large image is no longer shrunk to 1800 px (pixel budget is used),
  - `screen` filter upscales a small screenshot and auto-inverts a dark one,
  - `screen` keeps a long scrolling screenshot inside the pixel budget,
  - `adaptiveBw` keeps dark text dark and paper white on a page with a shadow gradient,
  - `sharpness` increases edge contrast,
  - `isMostlyDark` true/false cases.
- `test/presentation/screens/ocr/ocr_enhance_screen_test.dart`:
  - new filter chips are shown and selecting one passes the right filter,
  - PNG input starts with the Screenshot filter; JPEG input starts with Original,
  - Sharpness slider value is passed to the enhancer and reset clears it.

### G. Docs

- Change log in `change_log/` after implementation.

### Optional step B — better English model (needs your separate OK)

Replace `assets/tessdata/eng.traineddata` (fast, 4 MB) with the Tesseract **best**
English model (about 15 MB, from the official `tesseract-ocr/tessdata_best` GitHub
repo, Apache-2.0). Bump `TESSDATA_VERSION` in `MainActivity.kt` so installed apps copy
the new file. This makes the APK about 11 MB bigger. It needs a file download, so I will
only do it if you say yes. (You can also download it yourself and drop it in.)

## Files to be changed

- `lib/domain/services/ocr_enhancer.dart`
- `lib/data/services/isolate_ocr_enhancer.dart`
- `lib/presentation/screens/ocr/ocr_enhance_screen.dart`
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`
- `lib/l10n/app_localizations*.dart` (generated by `flutter gen-l10n`)
- `test/data/services/isolate_ocr_enhancer_test.dart`
- `test/presentation/screens/ocr/ocr_enhance_screen_test.dart`
- New change log in `change_log/`
- Optional step B only: `assets/tessdata/eng.traineddata`, `MainActivity.kt`
  (`TESSDATA_VERSION`)

## Risks and notes

- Bigger images make OCR slower (maybe 1.5–2× on a full page). The pixel budgets keep
  memory safe on older phones.
- The native change cannot be tested on the host; it needs a check on a real device.
- Checks after the change: `dart format`, `flutter analyze` (0 issues), `flutter test`.
