# Release Process

Use this document for repositories that ship builds to QA, external testers, enterprise distribution, or public app stores.

If the repository is not release-tracked yet, keep this file short and mark the current release scope clearly.

## 1. Release Scope

- App: `<app name>`
- Release profile: `internal`, `beta`, `public`, or `not yet shipping`
- Supported release platforms:
  - `Android`
  - `iOS`
  - `<other>`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension` if applicable

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates release readiness and final sign-off | `<name/team>` |
| Engineering | Code freeze, fixes, validation | `<name/team>` |
| QA | Test execution and regression sign-off | `<name/team>` |
| Store or distribution owner | Uploads artifacts and manages release metadata | `<name/team>` |

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`
- Source of truth: `pubspec.yaml`
- Build-number increment rule: `<rule>`
- Git tag format: `vX.Y.Z`

## 4. Branch And Merge Policy

- Release branch strategy: `<main only / release branches / trunk-based>`
- Hotfix strategy: `<strategy>`
- Required checks before merge:
  - `<ci checks>`
  - `<review requirements>`

## 5. Environment And Flavor Matrix

| Flavor | Mode | Purpose | Example Command |
|--------|------|---------|-----------------|
| `dev` | `debug` | Local development | `flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev` |
| `dev` | `release` | Release-like QA | `flutter build apk --flavor dev --release --dart-define=FLUTTER_APP_FLAVOR=dev` |
| `prod` | `release` | Final release artifact | `flutter build appbundle --flavor prod --release --dart-define=FLUTTER_APP_FLAVOR=prod` |

Adjust the matrix if the project uses `staging`, `qa`, or no flavors.

## 6. Signing And Secret Handling

- Signing config location: `<environment variables / secrets manager / CI secret store>`
- Keystore or certificate ownership: `<owner>`
- Secret rotation process: `<brief process>`
- Rules:
  - Signing material must not live in source control.
  - Local signing helpers must not expose secrets in committed files.
  - CI logs must not print signing secrets.

## 7. Release Checklist

Complete these items before every release.

### Code And Quality

- [ ] Required CI checks passed.
- [ ] `dart format --output=none --set-exit-if-changed .` passed.
- [ ] `flutter analyze` passed.
- [ ] `flutter test` passed.
- [ ] Integration tests passed if applicable.
- [ ] No critical or release-blocking bugs remain open.

### Product And Documentation

- [ ] Version in `pubspec.yaml` was updated.
- [ ] Changelog or release notes were updated.
- [ ] User-visible behavior changes were documented.
- [ ] Required store metadata is ready.

### Security And Compliance

- [ ] Manifest and permission review completed.
- [ ] Secrets, keys, and backup settings reviewed if applicable.
- [ ] Sensitive-data flows revalidated if applicable.

### Artifact Validation

- [ ] Intended release artifact built successfully.
- [ ] Artifact installs and launches correctly.
- [ ] Flavor and environment are correct in the built artifact.
- [ ] Version name and build number are correct.

## 8. Android Release Steps

Adjust these steps to match the repository.

1. Pull the intended release commit.
2. Verify the version in `pubspec.yaml`.
3. Fetch dependencies.
4. Run format, analyze, and test checks.
5. Build the required Android artifacts.
6. Verify artifact naming, installability, and environment.
7. Upload to the intended distribution channel.
8. Tag the release in git if applicable.

### Common Commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --flavor prod --release --dart-define=FLUTTER_APP_FLAVOR=prod --split-per-abi
flutter build appbundle --flavor prod --release --dart-define=FLUTTER_APP_FLAVOR=prod
```

## 9. iOS Release Steps

Document the real process if iOS is supported.

1. Confirm signing and provisioning are valid.
2. Build the iOS release artifact.
3. Validate permissions, metadata, and environment config.
4. Upload through the approved pipeline.
5. Confirm TestFlight or App Store processing.

## 10. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| `<channel>` | `<apk/aab/ipa/etc.>` | `<audience>` | `<notes>` |
| `<channel>` | `<artifact>` | `<audience>` | `<notes>` |

## 11. Rollback And Hotfix Process

- Rollback trigger: `<what forces rollback>`
- Rollback method: `<store halt / phased rollout pause / hotfix release>`
- Hotfix branch naming: `<pattern>`
- Verification after rollback or hotfix:
  - `<check 1>`
  - `<check 2>`

## 12. Release Evidence

Store links or references to release evidence here.

- CI run: `<url or identifier>`
- Test report: `<url or identifier>`
- Built artifact: `<location>`
- Release notes: `<location>`
- Store submission or rollout record: `<location>`

## 13. Post-Release Checks

- [ ] Production crash and error monitoring reviewed.
- [ ] Analytics or telemetry sanity checked if applicable.
- [ ] User-reported issues triaged.
- [ ] Release tag created.
- [ ] Follow-up tasks recorded.
