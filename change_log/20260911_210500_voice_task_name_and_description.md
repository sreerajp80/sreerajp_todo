# Change Log: Voice Task Creation with Name and Description

## Reference Plan
`plans/20260911_210500_voice_task_name_and_description.md`

## Overview
Added the ability to speak both a task name (title) and a task description using natural speech in English and Malayalam, and create the task directly with voice. Also added dedicated microphone input buttons inside the task creation and edit screen.

## Changes Made

1. **Voice Parsing and Lexicons (`lib/core/voice/`)**:
   - Updated `VoiceParseResult` to include an optional `description` string and added `VoiceField.description`.
   - Added description trigger words and phrases in `voice_lexicon_en.dart` (`description`, `with description`, `desc`, `note`, `notes`, `details`).
   - Added description trigger stems and words in `voice_lexicon_ml.dart` (`വിവരണം`, `വിവരണത്തോടെ`, `വിശദാംശം`, `വിശദാംശങ്ങൾ`, `കുറിപ്പ്`).
   - Updated `VoiceCommandParser` to detect description markers or newline breaks, splitting spoken sentences into title and description segments while preserving dates, times, durations, and priorities. NFC normalization is applied to both title and description.

2. **Localization (`lib/l10n/`)**:
   - Added localized strings for description chips, direct task creation, duplicate title errors, and field dictation tooltips in both English (`app_en.arb`) and Malayalam (`app_ml.arb`).

3. **Voice Command Sheet (`lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart`)**:
   - Added description preview chip in `_UnderstoodChips`.
   - Added direct task creation: tapping "Create task" saves the todo immediately into SQLite via `TodoRepository` with full Day-Lock and NFC-normalized title uniqueness checks.
   - Added an option to open the editor with pre-filled fields if the user wants to adjust details manually.
   - Added `returnResult: true` mode so other screens can open the voice sheet as a voice picker.

4. **Task Create / Edit Screen (`lib/presentation/screens/create_edit_todo/`)**:
   - Added microphone action button to the Details card header to fill title, description, priority, and target time in one spoken sentence.
   - Added microphone action button to the Title field to dictate the task title.
   - Added microphone action button to the Description field to dictate notes and details.

5. **Tests (`test/`)**:
   - Added unit tests in `test/core/voice/voice_command_parser_en_test.dart` and `test/core/voice/voice_command_parser_ml_test.dart` verifying bilingual description extraction and edge cases.
   - Added widget tests in `test/presentation/voice_command_sheet_test.dart` verifying description chip rendering, direct saving into the repository, and returning parse results.
   - Updated `test/presentation/create_edit_todo_screen_test.dart` to support preferences provider overrides.

## Verification
- Ran `dart format lib/ test/`.
- Ran `flutter analyze`: 0 issues found.
- Ran all 698 tests across the entire test suite (`flutter test`): 100% passed.
