# Flutter Build Flavors Guide

Use this as a reusable reference for Flutter projects that define Android product flavors such as `dev` and `prod`.

## Flavor Basics

A flavor usually represents an environment or release lane.

| Flavor | Typical Purpose | Typical Mode |
|--------|------------------|--------------|
| `dev` | Local development, QA, internal testing | `debug` |
| `prod` | Production builds, store submissions, public release | `release` |

Common combinations:

| Flavor | Mode | Typical Use |
|--------|------|-------------|
| `dev` | `debug` | Daily development and device testing |
| `dev` | `release` | Release-like QA build against non-production config |
| `prod` | `debug` | Rare, but useful when you need production configuration with debug tooling |
| `prod` | `release` | Real release artifact |

## Recommended Commands

Replace flavor names if your project uses names other than `dev` and `prod`.

Run the development flavor:

```bash
flutter run --flavor dev
```

Run the production flavor:

```bash
flutter run --flavor prod
```

Build a development debug APK:

```bash
flutter build apk --flavor dev --debug
```

Build production split APKs for mixed-device sharing:

```bash
flutter build apk --flavor prod --release --split-per-abi
```

Build a Play Store bundle:

```bash
flutter build appbundle --flavor prod --release
```

## Which Artifact To Use

Use split APKs when you distribute the app yourself.

Output files usually look like this:

- `app-armeabi-v7a-<flavor>-release.apk`
- `app-arm64-v8a-<flavor>-release.apk`
- `app-x86_64-<flavor>-release.apk`

Use an App Bundle when publishing to Google Play. Google Play serves optimized device-specific downloads from the `.aab`.

## Important Flag Distinction

`--target-platform` controls compilation targets. It does not automatically guarantee that a normal APK becomes ABI-specific.

Examples:

- `flutter build apk --flavor prod --release` usually creates one universal APK.
- `flutter build apk --flavor prod --release --target-platform android-arm64` can still produce a universal APK if packaging still includes other ABI libraries.
- `flutter build apk --flavor prod --release --split-per-abi` creates separate APKs per ABI.

If you need one APK that is truly arm64-only, use Gradle `abiFilters` or install the arm64 split APK from a `--split-per-abi` build.

## Recommended Release Matrix

For most Flutter Android projects:

- Local development: `flutter run --flavor dev`
- Internal debug APK: `flutter build apk --flavor dev --debug`
- Shareable release APKs: `flutter build apk --flavor prod --release --split-per-abi`
- Play Store submission: `flutter build appbundle --flavor prod --release`

## Optional Commands

Build a release-like QA build for the dev flavor:

```bash
flutter build apk --flavor dev --release --split-per-abi
```

Build a debug APK for the prod flavor:

```bash
flutter build apk --flavor prod --debug
```

## Notes For New Projects

To support this workflow, the Android project typically needs:

- product flavors in `android/app/build.gradle` or `android/app/build.gradle.kts`
- distinct application IDs or suffixes where side-by-side installs are needed
- environment-specific app names, icons, or configuration values
- release signing configured for production builds

If split APK builds fail, check whether custom APK naming logic is forcing all split outputs to the same filename.
