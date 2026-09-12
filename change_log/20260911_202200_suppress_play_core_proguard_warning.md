# Change Log: Suppress Play Core Warnings in ProGuard / R8

**Date:** 2026-09-11
**Plan:** `plans/20260911_202200_suppress_play_core_proguard_warning.md`

## Summary of Changes
- Added `-dontwarn com.google.android.play.core.**` to `android/app/proguard-rules.pro`.
- Resolves R8 minification failure during production release build caused by Flutter engine references to optional Play Core deferred component classes that are not present in this offline build.

## Files Changed
- `android/app/proguard-rules.pro`
- `plans/20260911_202200_suppress_play_core_proguard_warning.md`

## Verification
- `flutter analyze` completed with 0 issues.
