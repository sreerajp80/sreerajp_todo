# Change Log: Fix Kotlin Incremental Compilation Across Different Drive Roots

**Date:** 2026-09-11
**Plan:** `plans/20260911_201500_fix_kotlin_incremental_different_roots.md`

## Summary of Changes
- Added `kotlin.incremental=false` to `android/gradle.properties` to disable Kotlin incremental compilation.
- Resolves Kotlin compiler daemon failure with `java.lang.IllegalArgumentException: this and base files have different roots` and incremental cache closing errors when project and dependency caches reside on different drive roots on Windows.

## Files Changed
- `android/gradle.properties`
- `plans/20260911_201500_fix_kotlin_incremental_different_roots.md`

## Verification
- `flutter analyze` completed with 0 issues.
