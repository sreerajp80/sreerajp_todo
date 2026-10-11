# OCR: extract text only on button tap

Implements plan: `plans/20261010_190000_ocr_extract_text_button.md`

## What changed

### `lib/presentation/screens/ocr/ocr_enhance_screen.dart`

- Text recognition (OCR) no longer runs by itself. It used to run when the photo was
  prepared, after every edit, and after every language change.
- Added an icon-only **Extract text** button (`Icons.document_scanner`, key
  `ocr-enhance-extract-btn`) in the app bar, before "Use Text". It has a localized
  tooltip and no label. It is disabled while the photo is being prepared, while an
  enhancement is running, or while OCR is running.
- Tapping it (`_extractText()`) first applies any edit still waiting in the 250 ms
  debounce timer, waits for the enhancement to finish, then reads the text from the
  final image with the selected language.
- Every edit (rotate, crop, filter, brightness, contrast, reset, invert, language)
  now calls `_clearRecognizedText()`. This cancels any OCR run in progress, clears the
  text and word count, and disables "Use Text" until the user extracts again.
- Added an enhancement generation counter, so a late older enhancement can no longer
  overwrite the result of a newer one.
- Text panel: before extraction it shows a hint to tap the scan button, and the word
  count badge is hidden. After an extraction with no text, the existing "Nothing read
  yet" message is shown.
- Renamed `_runLiveOcr` to `_runOcr` and updated the class doc comment.

### Localization

- New keys in `lib/l10n/app_en.arb` (with `@` descriptions), `lib/l10n/app_ml.arb`
  and `lib/l10n/app_sa.arb`:
  - `ocrExtractTextTooltip` — "Extract text"
  - `ocrEnhanceExtractHint` — "Finish editing, then tap the scan button to read the
    text."
- Regenerated `lib/l10n/app_localizations*.dart` with `flutter gen-l10n`.

### `test/presentation/screens/ocr/ocr_enhance_screen_test.dart`

- The fake OCR service now counts calls.
- New tests:
  - OCR does not run on open or after edits; "Use Text" stays disabled.
  - The extract button has a tooltip, runs OCR once, shows the text and enables
    "Use Text".
  - An edit after extraction clears the text and disables "Use Text" without running
    OCR again.

## Checks

- `dart format` — done.
- `flutter analyze` — no issues.
- `flutter test` — all 849 tests passed.
