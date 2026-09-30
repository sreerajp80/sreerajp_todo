# Remove Google ML Kit: ZXing QR scanner, Tesseract-only OCR

**Status:** completed

## Issue

Google ML Kit comes into the app through two packages:

1. `google_mlkit_text_recognition`: the backup OCR engine. Native Tesseract already does
   all OCR on Android, and it is the only engine that reads Malayalam. ML Kit runs only when
   the Tesseract channel is missing: in host tests, or on Windows, where ML Kit does not
   work either. So in practice it is unused code.
2. `mobile_scanner`: the AirQR camera scanner. On Android it decodes QR codes with ML Kit's
   barcode scanner.

ML Kit brings Google Play Services code and a log uploader (`datatransport`) that sends
usage events to Google. We switched the uploader off in the last change
(`plans/20260928_104111_allow_lan_only_network_block_telemetry.md`). Removing ML Kit
completely is cleaner and makes the APK smaller.

The user's own QR reader project also decodes with `mobile_scanner` (ML Kit), so it has no
Google-free decoder we can reuse. The user chose **ZXing core** instead. ZXing is an open
source (Apache 2.0) Java library. It decodes QR codes with plain maths, has no network
code, no telemetry and no Play Services. Note: its package name is `com.google.zxing`
because it was first written at Google, but today it is community-maintained.

The user also asked to add the other four unlisted packages to the approved list.

## Plan for the fix

### Part A: OCR without ML Kit (data layer)

- Delete `lib/data/services/mlkit_ocr_service.dart`.
- Delete `lib/data/services/ocr_image_preprocessor.dart` and its test. Only the ML Kit
  service used it. Tesseract has its own preparation on the Kotlin side.
- `lib/data/services/native_ocr_service.dart`: remove `fallbackService`. When the
  Tesseract channel is missing (`MissingPluginException`), throw a new
  `OcrUnavailableException` instead.
- `lib/core/errors/exceptions.dart`: add `OcrUnavailableException`.
- `lib/application/providers.dart`: remove `ocrImagePreprocessorProvider` and the ML Kit
  fallback. `ocrServiceProvider` becomes `const NativeOcrService()`.
- `lib/presentation/screens/ocr/ocr_enhance_screen.dart`: when OCR fails with
  `OcrUnavailableException`, show a short localized message ("Text reading is not
  available on this device") instead of failing silently.
- `test/data/services/ocr_service_test.dart`: remove the ML Kit tests
  (`assembleRecognizedText`, two-pass recognition). Change the fallback test so it expects
  `OcrUnavailableException`.

### Part B: ZXing QR scanner (replaces `mobile_scanner`)

**How it works:** the `camera` package (already used by the OCR screen) streams camera
frames. For each frame, Dart sends only the brightness plane (the "Y" plane of the YUV
image) to Kotlin. Kotlin decodes it with ZXing on a background thread. While a decode is
running, new frames are skipped, so the camera never backs up.

**Android (Kotlin):**

- `android/app/build.gradle.kts`: add `implementation("com.google.zxing:core:3.5.3")`, with
  a comment that it is pure Java with no network code.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/QrFrameDecoder.kt` (new): a pure
  Kotlin object. It takes (bytes, width, height, rowStride), builds a
  `PlanarYUVLuminanceSource`, uses `HybridBinarizer` + `QRCodeReader` (QR only, UTF-8),
  and returns the text, or `null` when no code is found. It also tries the inverted
  image, so light-on-dark codes are read too.
- `MainActivity.kt`: add a method channel `in.sreerajp.todo/qr_decoder` with one method,
  `decodeFrame`. It runs `QrFrameDecoder` on a single background thread and replies on the
  main thread.
- `android/app/src/test/kotlin/.../QrFrameDecoderTest.kt` (new, JUnit, test only): make a
  QR code with ZXing's own `QRCodeWriter`, turn it into a brightness plane (also one with
  extra row padding), and check that it decodes. A blank frame must return `null`.

**Domain / data / application (Dart):**

- `lib/domain/services/qr_decoder_service.dart` (new): interface
  `Future<String?> decodeFrame({bytes, width, height, rowStride})`. Same pattern as
  `OcrService`.
- `lib/data/services/native_qr_decoder_service.dart` (new): calls the method channel. It
  throws `QrScannerUnavailableException` (new, in `exceptions.dart`) when the channel is
  missing, for example on Windows.
- `lib/application/providers.dart`: add `qrDecoderServiceProvider`.

**Presentation:**

- `lib/presentation/screens/air_qr_scan_screen.dart`: rewrite the camera part.
  - Use `CameraController` (back camera, `ResolutionPreset.high`, `ImageFormatGroup.yuv420`,
    no audio) with `startImageStream`, and `CameraPreview` for the picture.
  - Skip frames while one is being decoded.
  - Torch button uses `setFlashMode(FlashMode.torch / off)`. It is hidden if the camera has
    no flash.
  - Stop the stream on pause, when leaving the screen, and while the preview sheet is
    open. Start it again on resume.
  - Keep all AirQR logic exactly as it is: frame reassembly, direct payload, preview
    sheet, the returned result and the progress overlay.
  - Error states: camera permission denied, camera failed to start, and "QR scanning is
    available on Android only" (Windows).
  - Localize every user-visible string in this screen (titles, hints, progress text,
    snack bars, error messages, torch tooltips) in `app_en.arb`, `app_ml.arb` and
    `app_sa.arb` with `@` descriptions, reusing existing keys where they fit. Today most
    of this screen's text is hard-coded English, which breaks the localization rule.
- Run `flutter gen-l10n`.

**Tests (Dart):**

- `test/data/services/native_qr_decoder_service_test.dart` (new): with a mocked channel,
  check that the arguments are passed correctly, that text and `null` come back, and that
  a missing channel throws `QrScannerUnavailableException`.
- A widget test for `AirQrScanScreen`: when the decoder is unavailable, it shows the
  localized "Android only" message. (The live camera cannot run in widget tests.)

### Part C: Remove the packages and clean up the manifest

- `pubspec.yaml`: remove `google_mlkit_text_recognition` and `mobile_scanner`. Run
  `flutter pub get`.
- `android/app/src/main/AndroidManifest.xml`: remove the `TransportBackendDiscovery` /
  `CctBackendFactory` block and its comment. Nothing brings that service in any more.
  Keep `tools:node="remove"` for `ACCESS_NETWORK_STATE` as a guard.
- Build the prod release APK. Check that the merged manifest has **no** `com.google.mlkit`,
  `com.google.android.gms`, `datatransport` or `CctBackendFactory` entries, and still has
  `INTERNET` only as a network permission. If a `camera` plugin still brings any Google
  service in, report it and stop.

### Part D: Docs and approved list

- `CLAUDE.md` and `AGENTS.md` (kept in sync): add `camera`, `qr_flutter`,
  `shared_preferences` and `com.google.zxing:core` (Android Gradle, not a pub package) to
  the approved list. Add a rule: "No Google ML Kit, Play Services or Firebase code, not
  even through a plugin."
  - The user said "the other 4". `mobile_scanner` and ML Kit are being removed, and ZXing
    is new, so the approved additions are `camera`, `qr_flutter`, `shared_preferences` and
    ZXing core.
- `docs/dependencies.md`: remove the ML Kit and `mobile_scanner` rows. Add rows for
  ZXing core and any of the other three that are missing.
- `docs/security.md`, `docs/features.md`, `docs/release_process.md`, `README.md`,
  `docs/architecture.md`, `docs/project_structure.md`,
  `docs/unique_features_and_improvements.md`: remove the ML Kit wording. Say that OCR is
  Tesseract only and that QR scanning uses ZXing. Update the release audit to check that no
  `mlkit`, `gms` or `datatransport` entries are in the merged manifest.

## Files to change

- `pubspec.yaml`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/QrFrameDecoder.kt` (new)
- `android/app/src/test/kotlin/in/sreerajp/sreerajp_todo/QrFrameDecoderTest.kt` (new)
- `lib/core/errors/exceptions.dart`
- `lib/domain/services/qr_decoder_service.dart` (new)
- `lib/data/services/native_qr_decoder_service.dart` (new)
- `lib/data/services/native_ocr_service.dart`
- `lib/data/services/mlkit_ocr_service.dart` (delete)
- `lib/data/services/ocr_image_preprocessor.dart` (delete)
- `lib/application/providers.dart`
- `lib/presentation/screens/air_qr_scan_screen.dart`
- `lib/presentation/screens/ocr/ocr_enhance_screen.dart`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` and the generated `app_localizations*.dart`
- `test/data/services/ocr_service_test.dart`
- `test/data/services/ocr_image_preprocessor_test.dart` (delete)
- `test/data/services/native_qr_decoder_service_test.dart` (new)
- `test/presentation/air_qr_scan_screen_test.dart` (new)
- `CLAUDE.md`, `AGENTS.md`
- `docs/dependencies.md`, `docs/security.md`, `docs/features.md`,
  `docs/release_process.md`, `docs/architecture.md`, `docs/project_structure.md`,
  `docs/unique_features_and_improvements.md`, `README.md`

## How it will be checked

1. `dart format`, `flutter analyze` (0 issues), `flutter test` (all pass).
2. Kotlin unit tests: `.\gradlew :app:testDevDebugUnitTest` in `android/`.
3. Prod release APK builds. The merged manifest has no ML Kit, Play Services or
   datatransport entries. Compare the APK size with before (arm64 was 66.6 MB).
4. On a real phone (the user does this): AirQR send from one phone and receive on another,
   in normal light and with the torch; a single-code (direct payload) scan; an OCR scan in
   English and Malayalam.

## Risks

- ZXing is less tolerant than ML Kit of blurry, tilted or very small codes. AirQR codes are
  large and shown on a bright screen, so this should be fine. The on-device test will
  confirm it.
- Sending each brightness plane over the method channel costs some time (about 1–2 MB
  per frame at 720p). Skipping frames while busy keeps the app smooth. If the frame rate is
  too low, a later change can crop to the centre target box before sending.

## Out of scope

- `shared_preferences` is imported directly in `lib/application/`. Moving it behind a
  data-layer store is a separate change.
