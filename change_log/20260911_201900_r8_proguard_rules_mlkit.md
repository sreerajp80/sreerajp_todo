# Change Log: Add ProGuard Rules for R8 and ML Kit Text Recognition

**Date:** 2026-09-11
**Plan:** `plans/20260911_201900_r8_proguard_rules_mlkit.md`

## Summary of Changes
- Created `android/app/proguard-rules.pro` specifying:
  - Standard keep rules for the Flutter engine (`io.flutter.**`).
  - Keep rules for `sqflite` native plugin (`com.tekartik.sqflite.**`).
  - `-dontwarn` rules for optional ML Kit text recognition packages (`chinese`, `devanagari`, `japanese`, `korean`) that are not bundled in the default build.
- Updated `android/app/build.gradle.kts` in `buildTypes.release` to wire `proguardFiles` with `proguard-android-optimize.txt` and `proguard-rules.pro`.
- Resolves R8 minification failure during release APK builds (`:app:minifyProdReleaseWithR8`).

## Files Changed
- `android/app/proguard-rules.pro`
- `android/app/build.gradle.kts`
- `plans/20260911_201900_r8_proguard_rules_mlkit.md`

## Verification
- `flutter analyze` completed with 0 issues.
