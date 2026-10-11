# Fix the OCR fallback note in the architecture doc

Implements plan: `plans/20261010_210045_architecture_ocr_fallback_doc_fix.md`

## What changed

- `docs/architecture.md`, section "Platform Channels Or Native Integrations", the
  `in.sreerajp.todo/ocr` entry. The last sentence said that `NativeOcrService` falls
  back to ML Kit when the native channel is absent (host tests and Windows). It now
  says the service throws `OcrUnavailableException`, because Tesseract is the only OCR
  engine and text reading is not available there.

## Why

ML Kit was removed from the app. The code in
`lib/data/services/native_ocr_service.dart` throws `OcrUnavailableException` on a
`MissingPluginException`. The old text did not match the code, and it clashed with the
project rule that bans ML Kit.

## Checks

- Searched `docs/` for "falls back to ML Kit": no matches left.
- The other ML Kit mentions in the docs (bans, release checks, and the "before ML Kit
  was removed" note) are correct and were left as they are.
- Docs-only change, so `flutter analyze` and `flutter test` were not run.
