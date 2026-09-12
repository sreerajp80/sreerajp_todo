# Plan — Bring OCR to parity with SreerajP Journal Vault

**Status:** Approved — in progress

### Decisions (answered 2026-09-12)

1. **App size** — ship the same "best" `eng` + `mal` models as the Journal Vault (~16.6 MB).
2. **Crop editor** — replace the ToDo app's custom crop screen with `image_cropper`
   (uCrop) for exact parity. This widens the scope: see section 2a.
3. **`image` package** — approved; add it to the approved list in `CLAUDE.md`,
   `AGENTS.md` and `docs/dependencies.md`.
4. **Platforms** — OCR stays Android-only. Confirmed.

---

## 1. The issue

The ToDo app already has an OCR task scanner. It reads text with **Google ML Kit,
Latin script only**:

- `lib/presentation/screens/ocr/ocr_scan_screen.dart:81` —
  `TextRecognizer(script: TextRecognitionScript.latin)`

That means **Malayalam text cannot be scanned at all**, even though the app ships
Malayalam as a first-class language. It is also weaker on English: no image
preparation, no retry with different page layouts, no low-confidence word
filtering.

The Journal Vault app solves all of this. It runs **native Tesseract 5
(Tesseract4Android) on-device** with bundled `eng` + `mal` language models, and
falls back to ML Kit only when the native channel is missing (host tests).

Both apps stay 100% offline. Tesseract runs fully on-device; nothing leaves the
phone.

### Side-by-side

| Area | ToDo today | Journal Vault |
|------|-----------|---------------|
| Engine | ML Kit, Latin only | Native Tesseract `eng+mal`, ML Kit fallback |
| Malayalam | Not possible | Yes (bundled `mal.traineddata`) |
| Where recognition runs | Inline inside the screen widget | `OcrService` behind a Riverpod provider |
| Image prep before OCR | None | Upscale short edge to 1200 px, grayscale, contrast |
| Page layout retries | One pass | 3 page-segmentation modes, best score wins |
| Light-on-dark text | Dropped | Detected by brightness, re-read inverted |
| Edge-touching crops | Text can be lost | White quiet-zone padding added |
| Junk words | Kept | Confidence floors, script-aware |
| Multi-column pages | Read out of order | Re-ordered by geometry |
| Cancelling a slow scan | Not possible | `cancelRequests` drops queued jobs |
| Filters | Baked into the saved PNG (good) | Same idea, plus level normalisation and invert |

### What the ToDo app already does as well or better

Its crop screen (`lib/presentation/screens/ocr/ocr_crop_screen.dart`) is a custom
in-app editor that bakes crop, rotate, filter, brightness and contrast into a
lossless PNG on the GPU. The Journal Vault hands this to `image_cropper` (uCrop)
plus a Dart `image` isolate. **I recommend keeping the ToDo crop screen**, and
only teaching it the two enhancement ideas the Journal Vault has that it lacks
(level normalisation, invert). See "Decisions needed" below.

---

## 2. Scope of this change

Port the **recognition engine and its accuracy work**. Keep the ToDo app's own
camera screen, crop editor, result sheet, task parser and routes.

### Files to create

| File | Purpose |
|------|---------|
| `lib/domain/services/ocr_service.dart` | `OcrService` contract: `extractTextFromImage`, `cancelRequests` |
| `lib/data/services/native_ocr_service.dart` | Tesseract `MethodChannel` client, falls back to ML Kit |
| `lib/data/services/mlkit_ocr_service.dart` | ML Kit fallback, now `TextRecognitionScript.latin` for the fallback path only |
| `lib/data/services/ocr_image_preprocessor.dart` | Isolate: upscale, grayscale, contrast before OCR |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/OcrReadingOrder.kt` | Column/band reading-order sort (pure arithmetic, unit-testable) |
| `android/app/src/test/kotlin/in/sreerajp/sreerajp_todo/OcrReadingOrderTest.kt` | JUnit test for the above |
| `assets/tessdata/eng.traineddata` | English model (~4 MB), copied from the Journal Vault |
| `assets/tessdata/mal.traineddata` | Malayalam model (~12 MB), copied from the Journal Vault |
| `test/data/services/ocr_service_test.dart` | Channel mock, fallback, cancel |
| `test/data/services/ocr_image_preprocessor_test.dart` | Prepare/skip/failure paths |

### Files to change

| File | Change |
|------|--------|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` | Add the `in.sreerajp.todo/ocr` channel: `extractText`, `cancelOcr`; single-thread executor; `ensureTessData`; quiet-zone padding; invert; mean luminance; multi-PSM scoring; confidence filtering |
| `android/app/build.gradle.kts` | Add `cz.adaptech.tesseract4android:tesseract4android:4.9.0` |
| `pubspec.yaml` | Add `image: ^4.5.4`; register `assets/tessdata/` |
| `lib/application/providers.dart` | Add `ocrImagePreprocessorProvider`, `ocrServiceProvider` |
| `lib/presentation/screens/ocr/ocr_scan_screen.dart` | Stop calling `TextRecognizer` directly; call `ref.read(ocrServiceProvider)`; cancel the request on dispose; add an English / Malayalam / Both selector |
| `lib/presentation/screens/ocr/utils/ocr_text_sorter.dart` | Keep for the ML Kit fallback only (native side already returns ordered text) |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | New keys for the language selector and its `@key` descriptions |
| `docs/dependencies.md` | Record `image` and the Tesseract native library, with the offline justification |
| `docs/architecture.md` | Note the new `domain/services` + `data/services` OCR slice |

### Layer placement (per CLAUDE.md)

- `domain/services/ocr_service.dart` — abstract contract only, no Flutter, no plugins.
- `data/services/*` — the ML Kit and platform-channel implementations.
- `lib/application/providers.dart` — the providers the screen consumes.
- `presentation/` keeps zero direct plugin calls.

---

## 3. Decisions needed before I start

1. **App size.** The two language models add about **16.6 MB** to the APK
   (`eng` 4 MB, `mal` 12.5 MB). Dropping to the smaller `mal` "fast" model would
   save roughly 10 MB but costs accuracy. Ship the same "best" models as the
   Journal Vault?

2. **Crop editor.** Keep the ToDo app's own crop screen (my recommendation), or
   replace it with `image_cropper`/uCrop so the two apps match exactly? Replacing
   it means adding `image_cropper` and `image_picker`, neither of which is on the
   approved package list in CLAUDE.md, and losing the in-app filter preview.

3. **Approved package list.** `image: ^4.5.4` is not currently on the approved
   list. It is pure Dart, offline, no network. I will add it to the list in
   `CLAUDE.md`, `AGENTS.md` and `docs/dependencies.md` as part of this change
   unless you would rather approve it separately.

4. **Desktop (Windows).** The native channel is Android-only. On Windows the app
   will fall back to ML Kit, which is also unavailable there, so OCR stays an
   Android-only feature — same as the Journal Vault. Confirm that is fine.

---

## 4. Work order

1. Copy `assets/tessdata/` and register it in `pubspec.yaml`.
2. Add the Tesseract dependency to `android/app/build.gradle.kts`.
3. Add `OcrReadingOrder.kt` plus its JUnit test.
4. Add the OCR channel and all recognition helpers to `MainActivity.kt`.
5. Add the Dart contract, the two implementations and the preprocessor.
6. Wire the providers.
7. Switch `ocr_scan_screen.dart` onto the provider; add cancel-on-dispose and the
   language selector; add the ARB keys.
8. Add the Dart unit tests.
9. Update `docs/dependencies.md`, `docs/architecture.md`, `CLAUDE.md`, `AGENTS.md`.
10. Run `dart format`, `flutter analyze` (must be 0 issues), `flutter test`.
11. Write the change log to `change_log/`.

---

## 5. Risks

- **Build size** grows by ~16.6 MB. Unavoidable for offline Malayalam OCR.
- **First scan after install** copies the models to internal storage once; it is
  a little slower. The `.model_version` marker means it happens once per model
  change, not once per launch.
- **Native memory.** Tesseract holds one `TessBaseAPI` alive. It is recycled in
  `onDestroy`, and recognition is serialised on a single-thread executor so two
  scans can never run at once.
- **Existing tests.** `test/presentation/ocr/*` and `test/presentation/screens/ocr/*`
  assume the current inline ML Kit path; they will be updated to mock
  `ocrServiceProvider` instead.

---

## 6. Definition of done

- Malayalam and English text both scan correctly on a device.
- `flutter analyze` reports 0 issues.
- `flutter test` passes, including the new service tests.
- The Gradle JUnit reading-order test passes.
- No network permission added; `AndroidManifest.xml` unchanged.
- Change log written under `change_log/`.
