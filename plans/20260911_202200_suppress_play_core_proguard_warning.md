# Plan: Suppress Play Core Warnings in ProGuard / R8

**Status:** Completed

## Issue
During Android production release build (`:app:minifyProdReleaseWithR8`), R8 fails because Flutter's engine references Google Play Core classes (`com.google.android.play.core.**`) used for deferred component splitting (`FlutterPlayStoreSplitApplication`, `PlayStoreDeferredComponentManager`):
```
ERROR: R8: Missing class com.google.android.play.core.splitcompat.SplitCompatApplication ...
Missing class com.google.android.play.core.splitinstall.SplitInstallManager ...
```
Because the application is fully offline and does not use Play Store deferred components or include the Play Core library, R8 halts without an explicit `-dontwarn` suppression rule.

## Proposed Fix
1. Add `-dontwarn com.google.android.play.core.**` to `android/app/proguard-rules.pro`.

## Files to Change
- `android/app/proguard-rules.pro`
