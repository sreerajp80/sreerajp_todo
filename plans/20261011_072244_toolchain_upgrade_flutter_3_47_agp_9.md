# Plan: Upgrade toolchain to Flutter 3.47.6, AGP 9.4.1 and Gradle 9.8.0

**Status:** completed

## What the issue is

The project is pinned to an older toolchain:

| Item | Now | Target |
|------|-----|--------|
| Flutter SDK | 3.44.8 (docs and CI) | 3.47.6 |
| Dart SDK | 3.12.2 | 3.13.5 (comes with Flutter 3.47.6) |
| Android Gradle Plugin (AGP) | 8.11.1 | 9.4.1 |
| Gradle wrapper | 8.14 | 9.8.0 |

Flutter 3.47.6 is already installed on the development machine, so only the project files,
CI and docs need to change.

Moving to AGP 9 and Gradle 9 breaks two things in `android/app/build.gradle.kts`:

1. AGP 9 **rejects** the `kotlinOptions { }` block. The build fails until it is replaced
   with the top-level `kotlin { compilerOptions { } }` block.
2. Gradle 9 has **removed** `project.exec { }`. The `generateBuildMetadata` task uses it twice
   to run the Dart scripts that create `app_version.g.dart` and `build_date.g.dart`. It must
   use an injected `ExecOperations` service instead.

Also, `CLAUDE.md` and `AGENTS.md` have the hard rule "Stay on AGP **8.x**". This upgrade
breaks that rule on purpose, so the rule must be changed to AGP 9.x.

## Files to be changed

| File | Change |
|------|--------|
| `android/settings.gradle.kts` | `com.android.application` version `8.11.1` → `9.4.1`. Kotlin plugin (`2.2.20`) stays unless the build says AGP 9.4.1 needs a newer one; if so, raise it to the lowest version the error asks for and note it in the change log. |
| `android/gradle/wrapper/gradle-wrapper.properties` | `gradle-8.14-all.zip` → `gradle-9.8.0-all.zip`. |
| `android/app/build.gradle.kts` | Replace `kotlinOptions { jvmTarget = ... }` with `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }` (plus the `JvmTarget` import). Replace both `project.exec { }` calls with an `ExecOperations` service (for example a small `interface InjectedExecOps { @get:Inject val execOps: ExecOperations }` obtained with `project.objects.newInstance<InjectedExecOps>()`, then `execOps.exec { ... }`). Task inputs/outputs stay the same. |
| `android/gradle.properties` | Keep `android.builtInKotlin=false` and `android.newDsl=false` (the guideline says keep them until Flutter's template drops them). No change expected. |
| `pubspec.yaml` | Dart SDK constraint `^3.12.2` → `^3.13.5`. Then `flutter pub get` (updates `pubspec.lock`). |
| `.github/workflows/ci.yml` | `FLUTTER_VERSION: '3.44.8'` → `'3.47.6'`. |
| `CLAUDE.md`, `AGENTS.md` | Flutter `3.44.8` → `3.47.6`, Dart `3.12.2` → `3.13.5`, rule "Stay on AGP **8.x**" → "Stay on AGP **9.x**". Kept in sync. |
| `README.md` | Flutter / Dart badges and the version lines (3 places). |
| `docs/features.md` | Flutter / Dart version line. |
| `docs/project_structure.md` | "AGP 8.x" → "AGP 9.x". |

Files under `docs/guidelines/` are shared guidelines with example versions only; they are not
changed.

## Plan for the fix

1. Edit the Gradle files as listed above (settings, wrapper, app build script).
2. Update `pubspec.yaml` Dart constraint, run `flutter pub get`.
3. Run `flutter clean`, then:
   - `flutter analyze` (must be 0 issues),
   - `flutter test`,
   - `flutter build apk --flavor dev --debug` (checks the toolchain and the
     `generateBuildMetadata` task),
   - `flutter build windows --release` (Windows is not affected by AGP, but checks the
     new Flutter SDK).
   A prod release build needs the local keystore; I will run
   `flutter build appbundle --flavor prod --release` only if you want me to.
4. If the build reports that a plugin or the Kotlin plugin version is too old for AGP 9.4.1,
   fix only what the error asks for, and list it in the change log.
5. Update CI, `CLAUDE.md`, `AGENTS.md`, `README.md`, `docs/features.md`,
   `docs/project_structure.md`.
6. Write the change log in `change_log/` and set this plan to `completed`.

## Not in this plan (separate change if wanted)

The shared guideline also lists, for apps crossing Flutter 3.47, a move from
`package:flutter/material.dart` to the new `material_ui` / `cupertino_ui` packages
(`dart fix --apply --code=migrate_design_widgets`). That touches almost every widget file,
so it is left out to keep this upgrade to the toolchain only. The old imports still work in
3.47. It can be done as a follow-up plan.

The Android-only toolchain move does not change iOS/macOS, which are not active platforms.

## Addendum (found during implementation): freezed must move to 4.x

### What happened

Steps 1–2 are done (Gradle files, wrapper, `pubspec.yaml` Dart constraint). After that,
`flutter analyze` reports **158 errors**, all inside generated `*.freezed.dart` files:

> Can't have modifier 'final' here (extraneous_modifier)

Dart 3.13 (bundled with Flutter 3.47.6) no longer accepts `final` on the parameters of a
redirecting factory constructor. `freezed 2.5.8` (the last 2.x release) generates exactly
that code. The freezed changelog says version **4.0.0** dropped `final` "due to Dart 3.13".
So the app cannot build on Flutter 3.47.6 without moving to freezed 4.

### Extra files to change

| File | Change |
|------|--------|
| `pubspec.yaml` | `freezed` `^2.5.7` → `^4.0.2`, `freezed_annotation` `^2.4.4` → `^3.1.0`, `build_runner` `^2.4.14` → `^2.16.2`, `json_serializable` `^6.9.0` → `^6.14.1`, `json_annotation` `^4.9.0` → `^4.12.0`. A dry run shows these resolve with no conflicts. |
| 19 `@freezed` classes in `lib/domain/entities/`, `lib/application/` state files | Since freezed 3.0, every freezed class must be `abstract` (or `sealed`). All 19 are single-constructor data classes, so each `class X with _$X` becomes `abstract class X with _$X`. No other source change is expected. |
| All `*.freezed.dart` / `*.g.dart` | Regenerated by `dart run build_runner build --delete-conflicting-outputs` (never edited by hand). |

The 19 classes: `DailyTodoState`, `UndoEntry`, `StatisticsState`, `TimeTrackingState`,
`VoiceCaptureState`, `BackupLogEntity`, `DailyIntentionEntity`, `DailyReflectionEntity`,
`RecurrenceRuleEntity`, `SpacedRepetitionItemEntity`, `DayStats`, `TodoTimeStats`,
`TitleTimePoint`, `SummaryStats`, `SubTaskItem`, `TimeSegmentEntity`, `TodoEntity`,
`TodoHistoryEntity`, `TodoSearchResult`.

Other packages (Riverpod, go_router, file_picker, fl_chart and so on) are **not** upgraded.

### Steps

1. Update the five package constraints and run `flutter pub get`.
2. Add `abstract` to the 19 class declarations.
3. Run `build_runner`, then `flutter analyze` and `flutter test`. If freezed 4 or the newer
   `json_serializable` causes other errors, fix only those and list them in the change log.
4. Continue with step 3 onward of the original plan (builds, CI, docs, change log).

### Windows build note

`flutter pub get` now also prints "Building with plugins requires symlink support. Please
enable Developer Mode". Package fetching still succeeds, but the Windows desktop build needs
Windows Developer Mode turned on. That is a system setting, so the developer must turn it on;
it is not a project file change.
