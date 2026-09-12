# Plan: Allow image_cropper transitive http dependency in pre-commit audit

**Status:** Approved

## 1. The Issue

When committing changes, the pre-commit script `.githooks/pre-commit.ps1` runs an offline dependency audit:
```powershell
$depsOutput = flutter pub deps --no-dev 2>$null
$blocked = $depsOutput | Select-String -Pattern "\b(http|dio|...)\b"
```
The commit is aborted with:
```
Offline dependency audit FAILED. Networking packages found in runtime deps:
|    \-- http 1.6.0
Commit aborted.
```

### Root Cause
- The package `image_cropper: ^12.2.1` was added to `pubspec.yaml` (approved in `AGENTS.md` and `docs/dependencies.md` for local image cropping).
- `image_cropper` brings in `image_cropper_platform_interface 8.0.0`, which declares `http: ^1.0.0` in its `pubspec.yaml`.
- Neither `image_cropper` nor `image_cropper_platform_interface` imports or executes any HTTP networking code in its Dart implementation.
- The app has no internet permissions in `android/app/src/main/AndroidManifest.xml`.
- Because `http` appears as a transitive dependency in `flutter pub deps --no-dev`, the pre-commit regex pattern triggers a false positive.

## 2. Proposed Fix

Update `.githooks/pre-commit.ps1`:
1. Verify that `pubspec.yaml` contains no direct dependencies on prohibited packages.
2. In the `flutter pub deps --no-dev` check, filter out lines where `http` appears as a transitive dependency (`\bhttp\s+\d`).
3. Verify that `http` is only present transitively under the approved package `image_cropper_platform_interface`.

## 3. Files to Modify

- `.githooks/pre-commit.ps1`

## 4. Verification Plan

1. Run `.githooks/pre-commit.ps1` directly in PowerShell to confirm all checks pass.
2. Verify that deliberate prohibited direct dependencies (e.g. `http` in `pubspec.yaml`) are still caught and blocked.
3. Attempt the git commit or pre-commit verification.
