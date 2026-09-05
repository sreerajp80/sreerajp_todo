# Change Log: Align Project Structure, Code, and Docs to Guidelines

**Date:** 2026-09-05  
**Plan Reference:** [plans/20260905_061500_align_guidelines_structure_code_docs.md](plans/20260905_061500_align_guidelines_structure_code_docs.md)

## Summary of Changes

Audited and aligned the repository structure, code, and documentation in `sreerajp_todo` against the Flutter guidelines in `docs/guidelines/`.

### 1. Rulebooks (`AGENTS.md` and `CLAUDE.md`)
- Added the mandatory `## Localization rules` section.
- Updated Hard Rule 10 and Always Rule 6 to mandate `Localization First` via `lib/l10n/*.arb` and `AppLocalizations`, removing the obsolete reference to `app_strings.dart`.
- Updated Android release build commands to include mandatory `--obfuscate` and `--split-debug-info=build/symbols/android-prod/` flags.
- Updated keystore path reference to standard relative path `android/key.properties` (with `android/<name>.jks`).
- Updated workflow rules section to forbid local system details (OS user name, computer/host name, drive-letter paths, etc.) in plans and change logs.

### 2. Documentation (`docs/` & `README.md`)
- `docs/release_process.md`:
  - Updated keystore signing path to relative `android/key.properties`.
  - Added `--obfuscate` and `--split-debug-info=build/symbols/android-prod/` flags to production build commands.
  - Added debug symbol archiving instructions.
  - Aligned the Gradle signing configuration snippet to use `rootProject.file("key.properties")`.
- `docs/flutter_build_flavors_guide.md`:
  - Added `--obfuscate` and `--split-debug-info=build/symbols/android-prod/` flags to production build commands.
- `docs/project_structure.md`:
  - Added `lib/l10n/` (ARB localization sources & `AppLocalizations`) and `lib/core/config/` (`app_config.dart`, `config_service.dart`) to the file tree.
  - Updated layer responsibility definitions to describe `lib/l10n/` and `lib/core/config/`, and removed stale reference to `app_strings.dart`.
- `docs/architecture.md`:
  - Updated source layout tree with `lib/core/config/` and `lib/l10n/`, and removed `app_strings`.
- `docs/workflow_rules.md`:
  - Explicitly required relative repository paths only and prohibited local system details in plans and change logs.
- `docs/unique_features_and_improvements.md`:
  - Replaced absolute drive-letter path reference with relative filename.
- `README.md`:
  - Replaced absolute machine path with `android/key.properties`.
  - Replaced absolute file URI link with relative path `docs/release_process.md`.
  - Aligned Android release build commands with production guidelines.

### 3. Code Configuration & Tests
- `lib/core/config/app_config.dart`:
  - Updated `AppConfig.fallback` version to `1.13.1` and build to `32` to match `pubspec.yaml`.
- `test/core/config/app_config_test.dart`:
  - Updated fallback unit test assertions to match `1.13.1` and `32`.

### 4. Cleaned Historical Machine Paths
- Replaced machine drive-letter paths in `plans/20260810_120000_unique-features-and-improvements-analysis.md`, `plans/20260810_195009_update_unique_features_doc.md`, `change_log/20260810_200130_update_unique_features_doc.md`, `flutter_todo_app_plan.md`, `prompts/phase1_project_setup.md`, and `prompts/phase9_build_release.md`.

## Verification

- `dart format lib/ test/`: passed.
- `flutter analyze`: passed with 0 issues.
- `flutter test`: all 660 unit, widget, and domain tests passed clean.
- Repository-wide grep: verified zero machine drive-letter paths remain in project files.
