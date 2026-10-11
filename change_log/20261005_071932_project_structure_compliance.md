# Change log — Project structure follows the guidelines

**Date:** 2026-10-05

**Plan:** [plans/20261005_070445_project_structure_compliance.md](../plans/20261005_070445_project_structure_compliance.md)

---

## 1. Summary

The project layout now follows `docs/guidelines/guideline.md` §3,
`docs/guidelines/flutter_project_engineering_standard.md` §3.2, §3.3 and §19.2, and the layer
rules in `CLAUDE.md`. Only file locations, imports and docs changed. App behaviour did not change.

---

## 2. `lib/` changes

### 2.1 `lib/core/` is now pure Dart

Only `lib/core/config/config_service.dart` still imports Flutter. The guideline fixes its path.

| From | To |
| --- | --- |
| `lib/core/extensions/localization_extensions.dart` | `lib/presentation/shared/extensions/localization_extensions.dart` |
| `lib/core/l10n/sa_framework_localizations.dart` | `lib/presentation/shared/l10n/sa_framework_localizations.dart` |
| `lib/core/errors/error_message_mapper.dart` | `lib/presentation/shared/error_message_mapper.dart` |
| `lib/core/platform/*.dart` (5 channel files) | `lib/data/platform/*.dart` |

The speech types (`SpeechUnavailableReason`, `SpeechEventType`, `SpeechErrorCode`,
`SpeechEvent`) moved out of `speech_channel.dart` into the new pure-Dart file
`lib/domain/entities/speech_event.dart`. `speech_channel.dart` re-exports them, so its
existing users still work. The voice sheet now imports only the domain file, so
`presentation/` still never imports `data/`. The `@immutable` marker was dropped from
`SpeechEvent` because it came from Flutter. The class is still immutable: it has a `const`
constructor and only `final` fields.

### 2.2 `lib/core/utils/` split into named folders

| Files | New home |
| --- | --- |
| `app_lock_rules`, `focus_pulse_rules`, `ritual_rules`, `task_default_rules`, `time_tracking_rules` | `lib/core/rules/` |
| `crypto_utils`, `win32_dpapi` | `lib/core/security/` |
| `atomic_saver` | `lib/core/storage/` |
| `network_address_utils` | `lib/core/network/` |
| `ocr_task_parser` | `lib/domain/services/` (removes the old `core → domain` import) |

Small helpers stay in `lib/core/utils/`: `date_utils`, `duration_utils`, `date_format_rules`,
`unicode_utils`, `indic_search_utils`, `rrule_display_utils`.

### 2.3 Removed

- `lib/widgets/made_with_love.dart`: it only re-exported
  `lib/presentation/shared/widgets/made_with_love.dart`.
- `lib/core/errors/failures.dart`: no users.

---

## 3. `test/` now mirrors `lib/`

About 75 test files moved with `git mv`. A test for `lib/<path>/<name>.dart` now lives at
`test/<path>/<name>_test.dart`. The relative imports of the shared test helpers were updated to
match. These tests check the whole app and stay where they were: `test/l10n/`,
`test/helpers/` and `test/presentation/icon_button_tooltips_compliance_test.dart`.
`test/data/services/ocr_service_test.dart` also stays, because it tests the data-layer engine
(`native_ocr_service.dart`).

---

## 4. Root files

- New `.github/workflows/ci.yml`:
  - a `test` job: format check, `flutter analyze`, `flutter test`;
  - an `android` job: prod app bundle and split APKs with `--obfuscate` and
    `--split-debug-info`;
  - a `windows` job: release build with `--obfuscate` and `--split-debug-info`.

  It pins Flutter 3.44.8 and uploads build outputs and debug symbols as artifacts. The Android
  job runs only when the four keystore secrets are set in the repository settings. It rebuilds
  the keystore from those secrets and deletes it after the build.
- `.gitignore`: lists `build/symbols/` by name.
- `flutter_todo_app_plan.md` moved to `docs/sreerajp_todo_idea.md`. The links in `prompts/`
  were updated.
- `analysis_options.yaml`: the Flutter tool added an `analyzer: exclude:` block for `build/`,
  `android/` and `windows/` while it ran `flutter analyze`. This block was kept.

---

## 5. Docs

- `CLAUDE.md` and `AGENTS.md` (kept in sync):
  - The `core/` rule now names the single `config_service.dart` exception and says where
    platform channels and l10n helpers now live.
  - `.github/workflows/` was added to "Where things live".
- `docs/architecture.md`: the `lib/` and `test/` trees, the `core/` ownership row, and the
  folder column for the rules and channel classes were updated.
- `docs/project_structure.md`:
  - The tree was updated. It now includes `.github/workflows/`, `prompts/`,
    `PROJECT_PROFILE.md` and `sreerajp_todo_idea.md`, and drops `lib/widgets/` and
    `test/widgets/`.
  - The layer and test notes were updated.
- `docs/features.md` and `docs/security.md`: the paths of the moved helper files were updated.

---

## 6. Verification

- `dart format --set-exit-if-changed lib/ test/ integration_test/`: no changes.
- `flutter analyze`: no issues.
- `flutter test`: all 833 tests passed.
- `grep "package:flutter" lib/core` finds only `config_service.dart`.
- `grep "sreerajp_todo/data/" lib/presentation` finds nothing.
- `grep "sreerajp_todo/domain/" lib/core` finds nothing.

---

## 7. Follow-ups

- Add the Android signing secrets in the GitHub repository settings so that the Android CI job
  runs.
- The Windows CI build with SQLCipher has not run on a clean runner yet. Check the first run.
