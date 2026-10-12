# Change Log: Toolchain upgrade to Flutter 3.47.6, AGP 9.4.1 and Gradle 9.8.0

Implements plan: [plans/20261011_072244_toolchain_upgrade_flutter_3_47_agp_9.md](../plans/20261011_072244_toolchain_upgrade_flutter_3_47_agp_9.md)
(including its freezed 4 addendum).

## Version changes

| Item | Before | After |
|------|--------|-------|
| Flutter SDK | 3.44.8 | 3.47.6 |
| Dart SDK | 3.12.2 | 3.13.5 |
| Android Gradle Plugin | 8.11.1 | 9.4.1 |
| Gradle wrapper | 8.14 | 9.8.0 |
| freezed / freezed_annotation | 2.5.8 / 2.4.4 | 4.0.2 / 3.1.0 |
| build_runner | 2.5.4 | 2.16.2 |
| json_serializable / json_annotation | 6.9.5 / 4.9.0 | 6.14.1 / 4.12.0 |

Kotlin Gradle Plugin stays at 2.2.20 (the build does not require a change yet).

## What changed

### Android build
- `android/settings.gradle.kts`: AGP `8.11.1` → `9.4.1`.
- `android/gradle/wrapper/gradle-wrapper.properties`: Gradle `8.14` → `9.8.0`.
- `android/app/build.gradle.kts`:
  - Removed `kotlinOptions { }` (AGP 9 rejects it). Added a top-level
    `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }` block.
  - `generateBuildMetadata` now runs the two Dart scripts through an injected
    `ExecOperations` service instead of `project.exec { }`, which Gradle 9 removed. Task
    inputs and outputs are unchanged.

### Dart packages and code generation
- `pubspec.yaml`: Dart SDK constraint `^3.13.5`; freezed, freezed_annotation, build_runner,
  json_serializable and json_annotation raised as in the table. `pubspec.lock` updated.
  No other package was upgraded.
- Why: Dart 3.13 no longer allows `final` on redirecting factory constructor parameters.
  freezed 2.x generates that code (158 analyzer errors). freezed 4.0.0 removed it.
- The 19 `@freezed` classes are now declared `abstract class` (required since freezed 3.0):
  in `lib/application/` (`daily_todo_state.dart`, `statistics_state.dart`,
  `time_tracking_state.dart`, `voice_capture_state.dart`) and `lib/domain/entities/`
  (`backup_log_entity.dart`, `daily_intention_entity.dart`, `daily_reflection_entity.dart`,
  `recurrence_rule_entity.dart`, `spaced_repetition_item_entity.dart`,
  `statistics_models.dart`, `sub_task_item.dart`, `time_segment_entity.dart`,
  `todo_entity.dart`, `todo_history_entity.dart`, `todo_search_result.dart`).
- All `*.freezed.dart` files regenerated with `build_runner`. The generated l10n files got
  one blank line from the new `gen-l10n`.

### Formatting
- `dart format` on Dart 3.13 uses a new style for method chains. 56 files under `lib/`,
  `test/` and `integration_test/` were reformatted (line breaks only, no logic change), so the
  CI format check passes with the new SDK.

### CI and docs
- `.github/workflows/ci.yml`: `FLUTTER_VERSION` → `3.47.6`.
- `CLAUDE.md`, `AGENTS.md`: Flutter / Dart versions updated; dependency rule changed from
  "Stay on AGP 8.x" to "Stay on AGP 9.x (with Gradle 9.x)".
- `README.md`, `docs/features.md`, `docs/project_structure.md`: version references updated.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all 864 tests passed.
- `flutter build apk --flavor dev --debug`: built; `generateBuildMetadata` ran correctly.
- `flutter build windows --release`: built.
- The prod release build was not run (it needs the local release keystore).

## Known follow-ups (not done here)

- Flutter warns that support for Kotlin 2.2.20 will soon be dropped (asks for at least
  2.3.20), and that the app should migrate to Built-in Kotlin.
- The move to the `material_ui` / `cupertino_ui` packages for Flutter 3.47.
- `docs/sreerajp_todo_idea.md` (original point-in-time spec) and
  `docs/unique_features_and_improvements.md` still mention Flutter 3.44.8.
- `flutter pub get` prints a hint to turn on Windows Developer Mode for plugin symlinks.
