# Fix the OCR fallback note in the architecture doc

**Status:** completed

## Files to change

- `docs/architecture.md` (one line, in section "Platform Channels Or Native Integrations")

## The issue

`docs/architecture.md` line 303 describes the `in.sreerajp.todo/ocr` channel. It ends with:

> Where the channel is absent — host tests, and Windows — `NativeOcrService` falls back to ML Kit

This is no longer true. ML Kit was removed from the app. In
`lib/data/services/native_ocr_service.dart`, when the native channel is missing
(`MissingPluginException`), `extractTextFromImage` now throws
`OcrUnavailableException`. Tesseract is the only OCR engine. The doc also clashes
with the hard rule in `CLAUDE.md` that bans ML Kit.

Line 420 of the same doc mentions ML Kit too, but only as history ("before ML Kit
was removed"). That line is correct and stays as it is.

## The fix

Replace the last sentence of line 303 with:

> Where the channel is absent — host tests, and Windows — `NativeOcrService` throws `OcrUnavailableException`, because Tesseract is the only OCR engine; text reading is not available there

No code changes. No other files change.

## Checks

- Search `docs/` again for "falls back to ML Kit" to make sure no copy is left.
- No `flutter analyze` / `flutter test` run needed (docs-only change).
- Write a change log in `change_log/` after the edit.
