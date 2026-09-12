# Plan: Fix Kotlin Incremental Compilation Across Different Drive Roots

**Status:** Completed

## Issue
During Android release build compilation, the Kotlin daemon fails with `java.lang.IllegalArgumentException: this and base files have different roots` and `Could not close incremental caches`. This occurs on Windows environments when the repository and dependencies in the pub cache reside on different drive roots or partitions. The Kotlin compiler's incremental cache converter (`RelocatableFileToPathConverter`) cannot compute relative paths across different roots.

## Proposed Fix
1. Update `android/gradle.properties` to disable Kotlin incremental compilation by adding `kotlin.incremental=false`.
2. This ensures full compilation per module without cross-drive relative path calculations for incremental cache storage.

## Files to Change
- `android/gradle.properties`
