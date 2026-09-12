# Plan: Add ProGuard Rules for R8 and ML Kit Text Recognition

**Status:** Completed

## Issue
Running the production release build (`flutter build apk --flavor prod --release --split-per-abi`) fails during the `:app:minifyProdReleaseWithR8` task.
R8 reports missing classes for optional language models in `google_mlkit_text_recognition` (`chinese`, `devanagari`, `japanese`, `korean`) that are not packaged in the standard build:
```
ERROR: R8: Missing class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder ...
```
Additionally, `android/app/proguard-rules.pro` does not exist yet to provide R8 keep and suppression rules as specified in `docs/flutter_build_flavors_guide.md`.

## Proposed Fix
1. Create `android/app/proguard-rules.pro` with:
   - Flutter engine keep rules (`io.flutter.**`).
   - `sqflite` plugin keep rules (`com.tekartik.sqflite.**`).
   - `-dontwarn` suppression rules for the unbundled ML Kit text recognition language packages (`chinese`, `devanagari`, `japanese`, `korean`).
2. Update `android/app/build.gradle.kts` in `buildTypes.release` to reference `proguard-rules.pro` via `proguardFiles`.

## Files to Change
- `android/app/proguard-rules.pro`
- `android/app/build.gradle.kts`
