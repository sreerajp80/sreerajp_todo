# Align Project Structure, Code, and Docs to Guidelines

**Status:** completed

## The ask

Ensure the project structure, code, and documentation in `sreerajp_todo` adhere properly to the Flutter guidelines in `docs/guidelines`.

## The issue today

An audit of the repository against `docs/guidelines` (`AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`, `guideline.md`, and `flutter_project_engineering_standard.md`) reveals the following gaps:

1. **`AGENTS.md` and `CLAUDE.md` rulebook gaps:**
   - Missing mandatory `## Localization rules` section required by updated guidelines.
   - Hard rule 10 and "Always" rule 6 still reference `lib/core/constants/app_strings.dart` which was migrated to `lib/l10n/*.arb` (`AppLocalizations`).
   - Android release build commands omit mandatory `--obfuscate` and `--split-debug-info=build/symbols/android-prod/` flags required by `guideline.md §2.4`.
   - Keystore location references an absolute machine drive-letter path instead of the standard relative path `android/key.properties` (with `android/<name>.jks`).
   - Workflow rules section does not yet include the explicit prohibition of local system details (OS username, computer/host name, drive-letter paths) as defined in the updated guidelines.

2. **Documentation gaps (`docs/`):**
   - `docs/release_process.md`: References absolute machine drive-letter paths for keystore and properties, shows outdated Gradle snippet, and omits obfuscation and debug symbol flags from production commands.
   - `docs/flutter_build_flavors_guide.md`: Production build commands omit `--obfuscate` and `--split-debug-info=build/symbols/android-prod/`.
   - `docs/project_structure.md`: Missing `lib/l10n/` and `lib/core/config/` in tree layout, references obsolete `app_strings.dart`.
   - `docs/architecture.md`: Source tree omits `lib/core/config/` and `lib/l10n/`, references obsolete `app_strings.dart`.
   - `docs/workflow_rules.md`: Needs the explicit prohibition of local system details in plans and change logs.
   - `docs/unique_features_and_improvements.md`: Contains an absolute drive-letter path reference.

3. **`README.md` gaps:**
   - Mentions an absolute machine drive-letter path for release signing.
   - Contains an absolute file URI link to `docs/release_process.md`.
   - Release build commands lack flavor and obfuscation flags.

4. **Code configuration:**
   - `lib/core/config/app_config.dart`: `AppConfig.fallback` has an outdated version string (`1.5.6`) that does not match `pubspec.yaml` (`1.13.1`).

5. **Historical plans / change logs containing local machine paths:**
   - `plans/20260810_120000_unique-features-and-improvements-analysis.md`
   - `plans/20260810_195009_update_unique_features_doc.md`
   - `change_log/20260810_200130_update_unique_features_doc.md`
   - These contain absolute drive-letter paths that contradict the strict relative-path and no-local-system-details policy.

## Decisions

1. **Update `AGENTS.md` and `CLAUDE.md`:**
   - Add the mandatory `## Localization rules` section.
   - Update rule 10 and "Always" rule to point to `lib/l10n/*.arb` via `AppLocalizations`.
   - Update release commands to include `--obfuscate` and `--split-debug-info=build/symbols/android-prod/`.
   - Update keystore description to point to `android/key.properties`.
   - Update workflow rules to forbid local system details.

2. **Update `docs/release_process.md` and `docs/flutter_build_flavors_guide.md`:**
   - Fix keystore paths to relative `android/key.properties` and `android/release-keystore.jks`.
   - Add `--obfuscate` and `--split-debug-info=build/symbols/android-prod/` to production commands.
   - Add symbol archive reminder.
   - Align Gradle snippet with `android/app/build.gradle.kts`.

3. **Update `docs/project_structure.md` and `docs/architecture.md`:**
   - Add `lib/l10n/` and `lib/core/config/` to directory trees and layer descriptions.
   - Remove references to non-existent `app_strings.dart`.

4. **Update `docs/workflow_rules.md`:**
   - Explicitly require relative paths only and forbid local system details.

5. **Update `README.md`:**
   - Clean up absolute path and file URI links.
   - Align build commands with production guidelines.

6. **Clean up absolute path occurrences in docs, plans, and change logs:**
   - Remove absolute drive-letter paths and replace with relative paths.

7. **Update `lib/core/config/app_config.dart`:**
   - Align `AppConfig.fallback` with the current app version.

8. **Verification:**
   - Run `dart format`, `flutter analyze`, and `flutter test`.

## Files to change

- `AGENTS.md`
- `CLAUDE.md`
- `docs/release_process.md`
- `docs/flutter_build_flavors_guide.md`
- `docs/project_structure.md`
- `docs/architecture.md`
- `docs/workflow_rules.md`
- `docs/unique_features_and_improvements.md`
- `README.md`
- `lib/core/config/app_config.dart`
- `plans/20260810_120000_unique-features-and-improvements-analysis.md`
- `plans/20260810_195009_update_unique_features_doc.md`
- `change_log/20260810_200130_update_unique_features_doc.md`

## The plan

1. Edit `AGENTS.md` and `CLAUDE.md` to add localization rules, update build commands with obfuscation flags, update keystore paths, and refresh workflow rules.
2. Edit `docs/release_process.md` and `docs/flutter_build_flavors_guide.md` to add obfuscation flags, relative keystore configuration, and symbol archiving instructions.
3. Edit `docs/project_structure.md` and `docs/architecture.md` to reflect `lib/l10n/`, `lib/core/config/`, and remove `app_strings.dart`.
4. Edit `docs/workflow_rules.md` to include the strict prohibition against local system details.
5. Edit `docs/unique_features_and_improvements.md` to remove drive-letter path references.
6. Edit `README.md` to remove drive-letter paths, fix absolute link, and align build commands.
7. Edit `lib/core/config/app_config.dart` to update fallback version to 1.13.1+32.
8. Edit historical plans and change log to eliminate absolute drive-letter paths.
9. Format code with `dart format`.
10. Run `flutter analyze` and `flutter test`.
11. Mark plan completed and write change log to `change_log/`.

## Verification plan

### Automated Tests
- Run `flutter analyze` (must have 0 issues).
- Run `flutter test` (all tests must pass).
- Run grep checks across `docs/`, `plans/`, `change_log/`, and root files to ensure zero absolute drive-letter paths (`C:\`, `L:\`, etc.) and zero local system details remain.
