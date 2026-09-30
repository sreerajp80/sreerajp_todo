# Remove Google ML Kit: ZXing QR scanner, Tesseract-only OCR

Implements plan: `plans/20260928_110104_remove_ml_kit_zxing_qr_scanner.md`

## Why

Google ML Kit came in through `google_mlkit_text_recognition` (a backup OCR engine that was
almost never used) and `mobile_scanner` (the AirQR camera scanner). ML Kit brought Play
Services code and a usage-log uploader to Google. Both are now gone. OCR uses Tesseract
only, and QR codes are decoded on the device with ZXing core.

## What changed

### Part A: OCR without ML Kit

- Deleted `lib/data/services/mlkit_ocr_service.dart`,
  `lib/data/services/ocr_image_preprocessor.dart` and
  `test/data/services/ocr_image_preprocessor_test.dart`.
- `lib/data/services/native_ocr_service.dart`: no fallback engine. A missing Tesseract
  channel now throws `OcrUnavailableException`.
- `lib/core/errors/exceptions.dart`: added `OcrUnavailableException` and
  `QrScannerUnavailableException`.
- `lib/application/providers.dart`: removed `ocrImagePreprocessorProvider`;
  `ocrServiceProvider` is `const NativeOcrService()`.
- `lib/presentation/screens/ocr/ocr_enhance_screen.dart`: shows the localized
  `ocrUnavailableMessage` when OCR is not available (it failed silently before).
- `test/data/services/ocr_service_test.dart`: removed the ML Kit tests; the fallback test
  now expects `OcrUnavailableException`.

### Part B: ZXing QR scanner

- `android/app/build.gradle.kts`: added `com.google.zxing:core:3.5.3`.
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/QrFrameDecoder.kt` (new): decodes
  the brightness plane of one frame with `PlanarYUVLuminanceSource`, `HybridBinarizer` and
  `QRCodeReader` (QR only, UTF-8). It also tries the inverted image.
- `MainActivity.kt`: new channel `in.sreerajp.todo/qr_decoder` (`decodeFrame`), run on its
  own background thread, shut down in `onDestroy`.
- `android/app/src/test/kotlin/in/sreerajp/sreerajp_todo/QrFrameDecoderTest.kt` (new):
  6 JUnit tests (plain text, Malayalam/Sanskrit text, row padding, inverted code, blank
  frame, frame too small).
- `lib/domain/services/qr_decoder_service.dart` (new) and
  `lib/data/services/native_qr_decoder_service.dart` (new); `qrDecoderServiceProvider`
  added to `providers.dart`.
- `lib/presentation/screens/air_qr_scan_screen.dart`: rewritten on the `camera` frame
  stream (`ImageFormatGroup.yuv420`). Frames are skipped while one is being decoded. It has
  a torch button (`FlashMode.torch`), stops and restarts the camera with the app
  lifecycle, and shows error states for permission denied, camera failure and "Android
  only". The AirQR logic (frame joining, direct payload, preview sheet, returned result,
  progress overlay) is unchanged. All screen text is now localized.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`: 13 new keys (`ocrUnavailableMessage`,
  `airQrScan*`), each with an `@` description in English. The existing
  `airQrScanTitle` and `airQrPayloadFormatError` are reused. Generated files were
  refreshed with `flutter gen-l10n`.
- New tests: `test/data/services/native_qr_decoder_service_test.dart` (4 tests) and
  `test/presentation/air_qr_scan_screen_test.dart` (Android-only message).

### Part C: Packages and manifest

- `pubspec.yaml`: removed `mobile_scanner` and `google_mlkit_text_recognition`.
- `android/app/src/main/AndroidManifest.xml`: removed the `TransportBackendDiscovery` /
  `CctBackendFactory` block (nothing brings it in any more). `ACCESS_NETWORK_STATE` stays
  removed as a guard.

### Part D: Docs

- `CLAUDE.md`, `AGENTS.md`:
  - Hard rule 1 now says there must be no Google ML Kit, Play Services or Firebase code,
    even through a plugin.
  - The security rule's manifest check was updated.
  - `camera`, `qr_flutter`, `shared_preferences` and the Gradle library
    `com.google.zxing:core` were added to the approved list. The two approved-list lines
    are now identical.
- `docs/dependencies.md`:
  - Removed the ML Kit and `mobile_scanner` rows.
  - Added rows for ZXing core and `tesseract4android` (both Gradle).
  - Updated the `camera` row.
- `docs/security.md`, `docs/release_process.md`: the audit now checks for no
  `com.google.mlkit`, `com.google.android.gms`, `datatransport` or `firebase` entries.
- `docs/features.md`, `docs/architecture.md` (new `qr_decoder` channel entry),
  `docs/project_structure.md`, `docs/unique_features_and_improvements.md`, `README.md`:
  replaced the ML Kit and `mobile_scanner` wording.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all 831 tests pass. The count is lower than before because the ML Kit
  and preprocessor tests were removed.
  - A first run failed two language-quality tests. The Sanskrit word "शक्या" contains a
    blocked Hindi marker, and "FPS" was left untranslated in Malayalam and Sanskrit. Both
    were reworded, and the tests pass.
- Kotlin unit tests (`:app:testDevDebugUnitTest`): `QrFrameDecoderTest` 6/6 and
  `OcrReadingOrderTest` 8/8 pass.
- Prod release APK built:
  - arm64 APK: 66.6 MB → 48.5 MB.
  - armeabi-v7a APK: 55.6 MB → 43.2 MB.
  - x86_64 APK: 70.8 MB → 51.1 MB.
- Merged manifest: `INTERNET` is still the only network permission. There are zero
  `com.google`, `mlkit`, `datatransport` or `firebase` matches.
- APK contents: no ML Kit, Play Services, Firebase or datatransport files or classes.

## Still to do by hand

On a real phone:
- Send AirQR from one phone and receive on another, in normal light and with the torch.
- Scan a single-code (direct payload) QR.
- Run an OCR scan in English and in Malayalam.

## Notes

- The three deleted files were removed with `git rm`, so their deletions are already
  staged.
- `READ_EXTERNAL_STORAGE` is still added by a plugin (out of scope, noted in the earlier
  change).
