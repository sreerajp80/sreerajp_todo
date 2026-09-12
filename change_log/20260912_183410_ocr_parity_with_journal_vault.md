# Change log — OCR brought to parity with SreerajP Journal Vault

**Plan:** `plans/20260912_180422_ocr_parity_with_journal_vault.md`
**Date:** 2026-09-12

---

## Why

The OCR task scanner read text with Google ML Kit locked to Latin script, so
**Malayalam could not be scanned at all**, even though the app ships Malayalam as
a first-class language. Recognition also ran straight inside the screen widget,
with no image preparation and a single recognition pass.

The Journal Vault app already solved this with native Tesseract 5 and bundled
`eng` + `mal` language models. This change ports that engine and its accuracy
work across.

Everything still runs on the device. No network permission was added and none is
needed.

---

## What changed

### New: native Tesseract OCR (Android)

- Added `cz.adaptech.tesseract4android:tesseract4android:4.9.0` to
  `android/app/build.gradle.kts`.
- Bundled the English and Malayalam language models in `assets/tessdata/`
  (about 16.6 MB together) and registered the folder in `pubspec.yaml`.
- Added the `in.sreerajp.todo/ocr` method channel to `MainActivity.kt` with two
  methods: `extractText` and `cancelOcr`.

The recognition work in `MainActivity.kt` includes:

- `ensureTessData` copies the models out of assets into app-internal storage on
  first use, and re-copies them only when the shipped set changes.
- A white quiet-zone border is drawn around the image, so a tight crop whose
  letters touch the edge is not thrown away as a page frame.
- A dark-dominant image is measured and also read inverted, which is the only
  way light lettering on a dark band is ever seen.
- Three page-segmentation modes are tried and scored; the best reading wins, and
  a clean page stops after its first pass.
- Words are filtered by confidence with two floors: a low one for words in the
  page's own script, a high one for a foreign-script word on a Malayalam page.
  That drops printed ornaments without deleting real, low-scoring Malayalam.
- Recognition runs on a single-thread executor, so two scans can never run at
  once. `onDestroy` recycles the Tesseract instance.

`OcrReadingOrder.kt` (new) puts recognised lines back into reading order on
multi-column pages. It is plain arithmetic and is covered by a new JUnit test,
`android/app/src/test/kotlin/in/sreerajp/sreerajp_todo/OcrReadingOrderTest.kt`.

### New: service layer for OCR

Recognition no longer happens inside a widget.

| Layer | File | Role |
|-------|------|------|
| domain | `lib/domain/services/ocr_service.dart` | Text recognition contract |
| domain | `lib/domain/services/ocr_enhancer.dart` | Filter presets, params, result |
| domain | `lib/domain/services/image_edit_service.dart` | Crop-and-rotate contract |
| data | `lib/data/services/native_ocr_service.dart` | Tesseract channel client |
| data | `lib/data/services/mlkit_ocr_service.dart` | ML Kit fallback |
| data | `lib/data/services/ocr_image_preprocessor.dart` | Enlarge, grayscale, contrast |
| data | `lib/data/services/isolate_ocr_enhancer.dart` | Pixel work in a background isolate |
| data | `lib/data/services/cropper_image_edit_service.dart` | uCrop editor |

The domain contracts stay free of plugin types. `ImageEditService` takes plain
32-bit ARGB colour values rather than Flutter `Color` objects for that reason.

Four providers were added to `lib/application/providers.dart`:
`ocrImagePreprocessorProvider`, `ocrServiceProvider`, `ocrEnhancerProvider` and
`imageEditServiceProvider`.

`NativeOcrService` falls back to `MlKitOcrService` when the platform channel is
missing — host tests, and any platform without the native side.

### Replaced: crop screen becomes the enhance screen

`lib/presentation/screens/ocr/ocr_crop_screen.dart` has been replaced by
`lib/presentation/screens/ocr/ocr_enhance_screen.dart`. The new screen:

- shows the recognised text live, updating as the photo is adjusted;
- lets the reader pick the recognition language — English + Malayalam, Malayalam
  only, or English only;
- rotates, inverts, applies filter presets, and adjusts brightness and contrast,
  all baked into a lossless PNG by the isolate enhancer;
- opens the native uCrop editor for cropping, writing lossless PNG so the crop
  step cannot blur thin marks before OCR sees them;
- cancels any recognition still queued when it closes, and deletes its temporary
  files;
- pops with the recognised text.

`ocr_scan_screen.dart` now pushes this screen and parses the text it returns,
instead of running `TextRecognizer` itself.

### Removed

- `lib/presentation/screens/ocr/ocr_crop_screen.dart`
- `lib/presentation/screens/ocr/utils/ocr_image_filter.dart` — preview-only
  colour matrices, superseded by the real pixel filters in the enhancer.
- `lib/presentation/screens/ocr/utils/ocr_text_sorter.dart` — replaced by
  `assembleRecognizedText` for the ML Kit path, and by the native reading-order
  sort for Tesseract.
- Their two test files.

### Other files

- `android/app/src/main/AndroidManifest.xml` — declares the uCrop activity. No
  screen orientation is set on it, so the editor follows the device the way the
  rest of this app does. No permission was added; the file still has exactly
  five, and no `INTERNET`.
- `pubspec.yaml` — added `image_cropper: ^12.2.1` and `image: ^4.5.4`.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` — twelve new keys for the enhance
  screen and the language picker, each with an `@key` description on the English
  side. Existing OCR keys were reused wherever one already fitted.
- `CLAUDE.md`, `AGENTS.md` — `image` and `image_cropper` added to the approved
  package list.
- `docs/dependencies.md`, `docs/architecture.md`, `docs/project_structure.md` —
  record the new packages, the `in.sreerajp.todo/ocr` channel, and the new
  `services/` folders in the domain and data layers.

---

## Tests

New:

- `test/data/services/ocr_service_test.dart` — the native channel contract,
  request ids, cancellation, the ML Kit fallback, the two-pass ML Kit path, and
  line assembly.
- `test/data/services/ocr_image_preprocessor_test.dart` — scaling rules,
  grayscale output, and the undecodable-file case.
- `test/data/services/isolate_ocr_enhancer_test.dart` — rotation, filter presets,
  and level normalisation.
- `android/app/src/test/kotlin/in/sreerajp/sreerajp_todo/OcrReadingOrderTest.kt`
  — column detection and reading order.

Results:

- `flutter analyze` — 0 issues.
- `flutter test` — all tests pass.

---

## Notes and trade-offs

- **App size grows by about 16.6 MB.** That is the cost of offline Malayalam
  recognition; the models cannot be downloaded, because the app never uses the
  network.
- **First scan after an install or a model change is slower**, because the
  models are copied to internal storage once. The `.model_version` marker file
  means this happens once per model set, not once per launch.
- **OCR is Android-only.** The native channel does not exist on Windows, and ML
  Kit is not available there either, so the scanner remains an Android feature.
- The Gradle JUnit test needs a Gradle run to execute; it was not run as part of
  this change.
