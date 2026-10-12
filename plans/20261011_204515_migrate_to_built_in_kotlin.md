# Migrate the Android app to built-in Kotlin

**Status:** completed

## Files to be changed

- `android/app/build.gradle.kts` — remove the `kotlin-android` plugin line.
- `android/gradle.properties` — set `android.builtInKotlin=true`.
- `docs/guidelines/flutter_build_flavors_guide.md` — update the notes that say to keep
  `builtInKotlin=false`.

No Dart code, manifest or `pubspec.yaml` changes.

## What the issue is

Every Android build prints this warning:

> Your Android app project ... applies the Kotlin Gradle Plugin, which will cause build
> failures in future versions of Flutter. Please migrate your app to Built-in Kotlin.

"Built-in Kotlin" means the Android Gradle Plugin (AGP 9+) compiles Kotlin by itself. The
separate Kotlin Gradle Plugin (KGP) no longer needs to be applied to the app. Flutter still
supports the old way for now, but its migration guide says that support will be removed in a
future version. So a later Flutter upgrade could break the Android build.

### Current state

- AGP 9.4.1 and Flutter 3.47.6. The guide needs AGP 9+ and Flutter 3.47+, so the project
  qualifies.
- `android/app/build.gradle.kts` still applies `id("kotlin-android")`. This is what the
  warning is about.
- `android/gradle.properties` has `android.builtInKotlin=false` (added by the Flutter
  migrator).
- Already done: the project has no `kotlinOptions { }` block and already uses the top-level
  `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }` block. This is step C of
  the guide, so it does not change.

### Plugin check

The guide warns that an Android plugin which still applies KGP itself will break the build
once built-in Kotlin is on. I checked the build files of every Android plugin the app uses:

| Plugin | Ready? |
|---|---|
| `android_file_picker` 2.0.1 | Yes. It applies KGP only when `builtInKotlin` is off |
| `camera_android_camerax` 0.7.5+1 | Yes. Does not apply KGP; already uses `kotlin { compilerOptions }` |
| `shared_preferences_android` 2.4.28 | Yes. Same as above |
| `image_cropper`, `sqflite_sqlcipher`, `flutter_plugin_android_lifecycle`, `jni`, `jni_flutter`, `integration_test` | Yes. They do not use KGP |
| `path_provider_android` 2.3.1 | Yes. No Android build file (uses `jni`) |

No plugin blocks the change.

## Plan for the fix

1. **`android/app/build.gradle.kts`:** remove `id("kotlin-android")` from `plugins { }`.
   Keep the comment about plugin order, adjusted to say the Flutter plugin must come after
   the Android plugin. Keep the `kotlin { compilerOptions { } }` block and its `JvmTarget`
   import as they are.
2. **`android/gradle.properties`:** change `android.builtInKotlin=false` to
   `android.builtInKotlin=true`, and update the comment above it.
3. **Keep** `id("org.jetbrains.kotlin.android") version "2.4.10" apply false` in
   `android/settings.gradle.kts`. With built-in Kotlin, AGP uses the Kotlin version found on
   the build classpath. This line keeps the project on Kotlin 2.4.10 (from the recent
   upgrade). Without it, AGP would fall back to its own older bundled Kotlin version.
4. **Keep** `android.newDsl=false` and `kotlin.incremental=false` unchanged. They are
   separate topics. `newDsl` is a different, later migration and the build does not warn
   about it.
5. **`docs/guidelines/flutter_build_flavors_guide.md`:** rewrite the note that says to keep
   `builtInKotlin=false`. It will say that since Flutter 3.47 the app uses
   `android.builtInKotlin=true`, the app's `plugins { }` block must not apply
   `kotlin-android`, and the settings file still declares the KGP version
   (`apply false`) to choose the Kotlin version. Also add a short line on checking Android
   plugins before turning it on.

## Checks

- Run `flutter clean`, then build each of these on its own (not at the same time as tests;
  see the last change log):
  - `flutter build apk --flavor dev --debug`
  - `flutter build apk --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/ --split-per-abi`
- Confirm the built-in Kotlin warning is gone from the build output.
- Run the release manifest check again (expect zero banned matches, same permission list).
- `flutter analyze` and `flutter test`.
- Windows build is not affected (Gradle only), so no Windows rebuild is needed.
- Manual test on a device (I cannot do this): the app starts, and the features with
  Kotlin code in `MainActivity.kt` / `AlarmReceiver.kt` still work. That means the app lock,
  the database key (app opens with existing data), speech-to-text, the running-timer
  notification, reminders, and keep-screen-on.

## Risks and rollback

- If the build fails, the likely cause is a plugin or a Kotlin version mismatch. Rollback
  is simple: put back `id("kotlin-android")` and set `android.builtInKotlin=false`. I would
  report the error and not try other fixes without asking you.
- Runtime risk is low. The same Kotlin version compiles the same code; only the plugin that
  drives the compiler changes.

## After the change

Write a change log in `change_log/` that references this plan, and set this plan's status
to `completed`.
