# Voice Task Creation with Name and Description

**Status:** completed

## 1. Issue

The user wants to accept both the task name (title) and description through voice, and create a todo using voice.

Currently:
1. The voice command parser (`lib/core/voice/voice_command_parser.dart`) only extracts title, date, time, duration, and priority. It does not parse or recognize a task description. If a user speaks a description (such as "Buy groceries description milk and eggs"), the entire sentence is lumped into the title.
2. `VoiceParseResult` does not have a `description` field or a `VoiceField.description` enum value.
3. The voice command sheet (`lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart`) does not display a preview for description.
4. When a user taps "Create task" in the voice sheet, the sheet does not save the task directly; it redirects to the full create/edit screen, requiring an extra screen transition and save tap to finish creating the task.
5. In the task creation screen (`lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart`), there are no voice dictation buttons on the Title or Description fields.

## 2. Proposed Fix

### A. Voice Command Parser & Lexicon (`core/voice/`)
1. **Lexicons (`voice_lexicon_en.dart`, `voice_lexicon_ml.dart`)**:
   - Add English description indicators: `description`, `with description`, `desc`, `with desc`, `note`, `with note`, `notes`, `details`, `with details`.
   - Add Malayalam description indicators: `വിവരണം` (vivaranam), `വിവരണത്തോടെ` (vivaranathode), `വിശദാംശം` (visadamsham), `വിശദാംശങ്ങൾ` (visadamshangal), `കുറിപ്പ്` (kurippu).
2. **Parser (`voice_command_parser.dart`)**:
   - Detect description indicators or newline breaks (`\n`) in the input.
   - Separate input tokens into title tokens and description tokens.
   - Keep extracting dates, times of day, durations, and priorities wherever they appear.
   - Clean and NFC-normalize both `title` and `description`.
   - Guarantee that `title` is never blank (if no title tokens precede the description indicator, fallback cleanly).
3. **Parse Result (`voice_parse_result.dart`)**:
   - Add `VoiceField.description` to `VoiceField`.
   - Add `final String? description` to `VoiceParseResult`.

### B. Voice Task Sheet (`presentation/screens/daily_list/widgets/voice_command_sheet.dart`)
1. Show understood `Description` alongside Title and other chips so the user clearly sees both fields.
2. Provide direct todo creation:
   - When tapping "Create task", directly validate and create the `TodoEntity` in the database via `dailyTodoProvider(date).notifier.createTodo(...)`.
   - Respect Day-Lock, terminal status, NFC normalization, and title uniqueness per day.
   - If a duplicate title exists, display an inline error message so the user can amend the speech or open the editor.
3. Provide an "Edit details" button (`Icons.edit_note_outlined` or OutlinedButton) to open the full `CreateEditTodoScreen` with prefilled values if the user wants to adjust subtasks, recurrence, or prerequisites.

### C. Create / Edit Screen Voice Input (`presentation/screens/create_edit_todo/`)
1. In the "Details" card header of `CreateEditTodoScreen`, add a voice input button alongside the OCR button so users can populate both title and description using voice.
2. In `TitleAutocompleteField` and the description field, provide a voice mic button to dictate directly into that specific field.

### D. Localization (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`)
- Add user-visible strings in simple English and Malayalam for:
  - `voiceDescriptionHeading`: "Description" / "വിവരണം"
  - `voiceEditDetails`: "Edit in form" / "ഫോമിൽ തിരുത്തുക"
  - `voiceDuplicateTitle`: "A task with this title already exists on this day." / "ഈ ദിവസത്തിൽ ഇതേ പേരിൽ ഒരു ടാസ്ക് നിലവിലുണ്ട്."
  - `voiceDictateTooltip`: "Dictate with voice" / "ശബ്ദം വഴി നൽകുക"

## 3. Files to Change

| File | Change |
|---|---|
| `lib/core/voice/voice_parse_result.dart` | Add `VoiceField.description` and `final String? description;` |
| `lib/core/voice/voice_lexicon_en.dart` | Add English description keywords (`description`, `note`, `details`, etc.) |
| `lib/core/voice/voice_lexicon_ml.dart` | Add Malayalam description keywords (`വിവരണം`, `കുറിപ്പ്`, etc.) |
| `lib/core/voice/voice_command_parser.dart` | Parse title and description separately, keeping existing passes intact |
| `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart` | Display parsed description, support direct task creation and edit-in-form |
| `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` | Add voice action button to Details card header, and mic button on fields |
| `lib/presentation/screens/create_edit_todo/widgets/title_autocomplete_field.dart` | Add mic action to dictate title |
| `lib/l10n/app_en.arb` | Add English strings |
| `lib/l10n/app_ml.arb` | Add Malayalam strings |
| `test/core/voice/voice_command_parser_en_test.dart` | Add unit tests for English description parsing |
| `test/core/voice/voice_command_parser_ml_test.dart` | Add unit tests for Malayalam description parsing |
| `test/presentation/voice_command_sheet_test.dart` | Add widget tests for description preview and creation |

## 4. Verification Plan

1. Run unit tests for parser:
   `flutter test test/core/voice/`
2. Run widget tests for voice sheet:
   `flutter test test/presentation/voice_command_sheet_test.dart`
3. Run all project tests:
   `flutter test`
4. Run static analysis:
   `flutter analyze` (must be 0 issues)
