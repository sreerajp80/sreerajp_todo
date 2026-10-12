# Migrate the Android app to built-in Kotlin

Implements plan: `plans/20261011_204515_migrate_to_built_in_kotlin.md`

## Why

Every Android build warned that the app applies the Kotlin Gradle Plugin, and that this
will cause build failures in a future Flutter version. On AGP 9+ with Flutter 3.47+, AGP
compiles Kotlin by itself ("built-in Kotlin"), so the app no longer needs the plugin.

## What changed

- `android/app/build.gradle.kts`: removed `id("kotlin-android")` from `plugins { }`, and
  updated the comment about plugin order. The `kotlin { compilerOptions { } }` block and the
  `JvmTarget` import did not change.
- `android/gradle.properties`: `android.builtInKotlin=false` → `true`, with a new comment.
  `android.newDsl=false` and `kotlin.incremental=false` did not change.
- `android/settings.gradle.kts`: not changed. It still declares
  `org.jetbrains.kotlin.android` 2.4.10 with `apply false`, so the build keeps using
  Kotlin 2.4.10.
- `docs/guidelines/flutter_build_flavors_guide.md`: replaced the note that said to keep
  `builtInKotlin=false`. It now explains the built-in Kotlin setup, why the KGP version line
  stays in the settings file, how to check plugins first, and how to roll back.

## Checks

- Before the change, every Android plugin was checked. None of them always applies KGP
  (`android_file_picker` skips it when built-in Kotlin is on; the others never apply it).
- `flutter clean`, then `flutter build apk --flavor dev --debug`: built, no Kotlin warning.
- `flutter build apk --flavor prod --release --obfuscate ... --split-per-abi`: built, no
  Kotlin warning. Each build was run on its own.
- Resolved `kotlin-stdlib` for the prod release is 2.4.10, so the Kotlin version did not
  change.
- Release manifest check: zero banned matches, same permission list as before.
- `flutter analyze`: no issues. `flutter test`: all 864 tests passed.

## Still to do (manual, on a device)

Install the release build and check the features that have their own Kotlin code: the app
opens with existing data (database key), app lock, speech-to-text, the running-timer
notification, reminders (also after a restart), and keep-screen-on.
