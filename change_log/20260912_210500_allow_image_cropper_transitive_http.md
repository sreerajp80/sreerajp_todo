# Change Log: Allow image_cropper transitive http dependency in pre-commit audit

**Reference plan:** `plans/20260912_210500_allow_image_cropper_transitive_http.md`

## Summary

Updated `.githooks/pre-commit.ps1` to prevent false-positive commit failures from `image_cropper`'s unused transitive `http` dependency, while adding strict direct dependency verification in `pubspec.yaml`.

## Details of Changes

- **`.githooks/pre-commit.ps1`**:
  - Added an explicit check on `pubspec.yaml` direct dependencies to ensure no prohibited networking or telemetry packages are added directly.
  - Filtered out the harmless transitive `http` dependency introduced by `image_cropper_platform_interface` from the `flutter pub deps --no-dev` scan.
  - Preserved all other offline checks: strict blocking of any other prohibited networking/telemetry packages, Android manifest permission check, `flutter analyze`, and unit/widget test suite execution.
