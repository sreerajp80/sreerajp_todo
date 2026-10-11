# Plan — Make the project structure follow the guidelines strictly

**Status:** completed

**Date:** 2026-10-05

---

## 1. What the guidelines say

The structure rules come from:

- `docs/guidelines/guideline.md` §3 — the `lib/` layout. A layered layout (`core/`,
  `domain/`, `data/`, `application/`, `presentation/`) is allowed. `lib/core/config/` with
  `AppConfig` + `ConfigService` is a fixed path.
- `docs/guidelines/flutter_project_engineering_standard.md` §3.2 — no catch-all `utils/`
  folder; `test/` should mirror `lib/`.
- `docs/guidelines/flutter_project_engineering_standard.md` §3.3 — the root layout
  (includes `.github/workflows/`).
- `docs/guidelines/flutter_project_engineering_standard.md` §19.2 — the Production App
  Extension is on (see `docs/PROJECT_PROFILE.md`), so CI MUST build a release artifact for
  every declared platform (Android and Windows).
- `CLAUDE.md` — `core/` is pure Dart with zero Flutter imports; `presentation/` never imports
  `data/`; `.gitignore` must list `build/symbols/`.

---

## 2. What is wrong today (audit result)

### 2.1 `lib/core/` is not pure Dart

These files import Flutter (or Flutter-generated code), which breaks the `core/` rule:

| File | Problem | Users |
| --- | --- | --- |
| `lib/core/extensions/localization_extensions.dart` | `BuildContext` extension — UI code | 82 files, all in `presentation/` |
| `lib/core/l10n/sa_framework_localizations.dart` | Material/Cupertino delegates — UI code | `lib/app.dart` |
| `lib/core/errors/error_message_mapper.dart` | Uses `AppLocalizations` — UI text | 8 files, all in `presentation/` |
| `lib/core/platform/*.dart` (5 files) | `MethodChannel` wrappers — device I/O | `application/` (5), `presentation/` (1) |
| `lib/core/config/config_service.dart` | Uses `rootBundle` | Allowed: the guideline fixes this path |

### 2.2 `lib/core/utils/` is a catch-all folder

It holds 16 files with unrelated jobs: crypto, Windows DPAPI, file saving, network address
checks, OCR text parsing, and five business-rule files. One file
(`ocr_task_parser.dart`) even imports `domain/`, so `core/` depends on `domain/`, which is
the wrong direction.

### 2.3 Stray and dead code

- `lib/widgets/made_with_love.dart` is only a one-line re-export of
  `lib/presentation/shared/widgets/made_with_love.dart`. It creates a sixth top-level folder
  outside the five layers.
- `lib/core/errors/failures.dart` has zero users.

### 2.4 `test/` does not mirror `lib/`

Most tests sit flat in `test/core/`, `test/data/`, `test/presentation/` instead of the
matching sub-folder (for example `test/core/date_utils_test.dart` should be
`test/core/utils/date_utils_test.dart`; `test/data/todo_dao_test.dart` should be
`test/data/dao/todo_dao_test.dart`). `test/widgets/` mirrors the stray `lib/widgets/`.

### 2.5 Root layout gaps

- No `.github/workflows/` and no CI, although the Production App Extension makes CI release
  builds a MUST.
- `.gitignore` does not list `build/symbols/` by name (it is only covered by `/build/`).
- `flutter_todo_app_plan.md` (the original 1,400-line project plan) sits at the root. Docs
  belong in `docs/`.

---

## 3. The fix

### 3.1 Make `lib/core/` pure Dart (only `core/config/` keeps its guideline exception)

| Move from | Move to | Why this layer |
| --- | --- | --- |
| `core/extensions/localization_extensions.dart` | `presentation/shared/extensions/localization_extensions.dart` | Only the UI uses it |
| `core/l10n/sa_framework_localizations.dart` | `presentation/shared/l10n/sa_framework_localizations.dart` | UI localization delegates |
| `core/errors/error_message_mapper.dart` | `presentation/shared/error_message_mapper.dart` | Maps errors to UI text |
| `core/platform/*.dart` (5 files) | `data/platform/*.dart` | Device I/O is data-layer work |

To keep `presentation/` free of `data/` imports, the speech enums used by the voice sheet
(`SpeechUnavailableReason`, `SpeechEventType`, `SpeechErrorCode`, `SpeechEvent`) move out of
`speech_channel.dart` into a new pure-Dart file
`lib/domain/entities/speech_event.dart`. `speech_channel.dart` (in `data/platform/`) imports
them from there. The voice sheet then imports only the domain file.

### 3.2 Split `lib/core/utils/` into named folders

| Files | New home |
| --- | --- |
| `date_utils`, `duration_utils`, `date_format_rules`, `unicode_utils`, `indic_search_utils`, `rrule_display_utils` | stay in `core/utils/` (small helpers — allowed by `guideline.md` §3) |
| `app_lock_rules`, `focus_pulse_rules`, `ritual_rules`, `task_default_rules`, `time_tracking_rules` | `core/rules/` |
| `crypto_utils`, `win32_dpapi` | `core/security/` (next to `app_lock_service.dart`) |
| `atomic_saver` | `core/storage/` |
| `network_address_utils` | `core/network/` |
| `ocr_task_parser` | `domain/services/ocr_task_parser.dart` (it builds a domain entity, so it is domain logic; this also removes the `core → domain` import) |

The rule files stay in `core/` (not `domain/`) because `core/utils/duration_utils.dart`
depends on `time_tracking_rules.dart`, and `core/` must not import `domain/`.

### 3.3 Remove stray and dead code

- Delete `lib/widgets/made_with_love.dart` (and the empty `lib/widgets/` folder). The real
  widget stays at `lib/presentation/shared/widgets/made_with_love.dart`, which
  `guideline.md` §3 allows for layered apps.
- Delete `lib/core/errors/failures.dart` (no users).

### 3.4 Make `test/` mirror `lib/`

Move each test file (with `git mv`, so history is kept) into the folder that matches the file
it tests, for example:

- `test/core/*_test.dart` → `test/core/utils/`, `test/core/rules/`, `test/core/storage/`,
  `test/core/errors/`, and so on.
- `test/core/pending_notification_channel_test.dart` etc. → `test/data/platform/`.
- `test/core/l10n/…` → `test/presentation/shared/l10n/`.
- `test/data/*_dao_test.dart` → `test/data/dao/`; migration tests → `test/data/database/migrations/`;
  service tests → `test/data/services/` or `test/data/backup/`.
- `test/domain/todo_repository_test.dart` → `test/domain/repositories/`.
- `test/presentation/*_screen_test.dart` → `test/presentation/screens/<screen>/`; shared widget
  tests → `test/presentation/shared/widgets/` (including `test/widgets/made_with_love_test.dart`).
- `test/core/utils/ocr_task_parser_test.dart` → `test/domain/services/`.

Cross-cutting tests that check the whole app (`test/l10n/`, `test/helpers/`,
`icon_button_tooltips_compliance_test.dart`) stay where they are.

### 3.5 Root files

- Add `.github/workflows/ci.yml` with three jobs:
  1. `test` (Ubuntu): `flutter pub get`, `dart format --set-exit-if-changed`, `flutter analyze`,
     `flutter test`.
  2. `android` (Ubuntu, Java 17): prod-flavor release app bundle and split APKs with
     `--obfuscate --split-debug-info=build/symbols/android-prod-<version>/`. The keystore is
     rebuilt from GitHub repository secrets; nothing secret is written into the repo. Symbols
     are uploaded as a build artifact.
  3. `windows` (Windows runner): `flutter build windows --release --obfuscate
     --split-debug-info=build/symbols/windows-<version>/`.
  The workflow pins Flutter 3.44.8. It uses only GitHub's own build servers; the app itself
  still makes no internet traffic.
- `.gitignore`: add `build/symbols/` by name.
- Move `flutter_todo_app_plan.md` → `docs/sreerajp_todo_idea.md` (the `<app>_idea.md` type in
  `DOCS_FOLDER_GUIDELINE.md` §7) with `git mv`, and fix any links to it.
- Keep `prompts/`, `tool/` and `.githooks/` as they are (extra folders are allowed), and
  describe them in `docs/project_structure.md`.

### 3.6 Fix imports and docs

- Update every `import` that points at a moved file (`lib/`, `test/`, `integration_test/`).
- Update path mentions in `CLAUDE.md`, `AGENTS.md` (kept in sync), `docs/architecture.md`,
  `docs/project_structure.md`, `docs/security.md` and `README.md`. Add one line in
  `CLAUDE.md`/`AGENTS.md` that `core/config/config_service.dart` is the only allowed Flutter
  import in `core/` (required by `guideline.md` §1).
- Do not touch `docs/guidelines/` (submodule), generated files, or old `plans/` and
  `change_log/` files.

### 3.7 Verify

- `dart format lib/ test/ integration_test/`
- `flutter analyze` — 0 issues.
- `flutter test` — all pass.
- Check: `grep "package:flutter" lib/core` only finds `config_service.dart`;
  `grep "sreerajp_todo/data/" lib/presentation` finds nothing.

---

## 4. Files to change

**Moved (with `git mv`):**

- `lib/core/extensions/localization_extensions.dart`
- `lib/core/l10n/sa_framework_localizations.dart`
- `lib/core/errors/error_message_mapper.dart`
- `lib/core/platform/app_lock_channel.dart`, `pending_notification_channel.dart`,
  `running_notification_channel.dart`, `screen_wake_channel.dart`, `speech_channel.dart`
- `lib/core/utils/app_lock_rules.dart`, `focus_pulse_rules.dart`, `ritual_rules.dart`,
  `task_default_rules.dart`, `time_tracking_rules.dart`, `crypto_utils.dart`,
  `win32_dpapi.dart`, `atomic_saver.dart`, `network_address_utils.dart`,
  `ocr_task_parser.dart`
- About 70 test files under `test/` (see §3.4)
- `flutter_todo_app_plan.md` → `docs/sreerajp_todo_idea.md`

**New:**

- `lib/domain/entities/speech_event.dart`
- `.github/workflows/ci.yml`

**Deleted:**

- `lib/widgets/made_with_love.dart`
- `lib/core/errors/failures.dart`

**Edited (import / path updates):**

- About 120 Dart files in `lib/`, `test/`, `integration_test/` that import moved files
- `.gitignore`
- `CLAUDE.md`, `AGENTS.md`, `README.md`
- `docs/architecture.md`, `docs/project_structure.md`, `docs/security.md`

**Change log:** `change_log/<timestamp>_project_structure_compliance.md`

---

## 5. Risks

- Large but mechanical change: only file locations and imports change, no behaviour. The
  analyzer and full test run will catch any missed import.
- The CI Android job needs these GitHub secrets before it can sign:
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD`. You add these yourself in GitHub; I will not handle them.
- The Windows CI build with SQLCipher has not been tried on a clean runner. If it fails, it
  will need a follow-up fix.
