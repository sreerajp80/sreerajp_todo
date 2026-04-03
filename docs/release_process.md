# Release Process

## 1. Release Scope

- App: `SreerajP ToDo`
- Release profile: `personal use` (not yet shipping to public app stores)
- Supported release platforms:
  - `Android` (APK + AAB)
  - `Windows` (portable folder)
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates release readiness and final sign-off | SreerajP (single developer) |
| Engineering | Code freeze, fixes, validation | SreerajP |
| QA | Test execution and regression sign-off | SreerajP |

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`
- Source of truth: `pubspec.yaml`
- Build-number increment rule: Manual for v1.0; auto-incremented in CI if set up later.
- Git tag format: `vX.Y.Z`
- Initial release: `1.0.0+1`

## 4. Branch And Merge Policy

- Release branch strategy: `main only` (single developer, trunk-based).
- Hotfix strategy: Fix on main, tag, rebuild.
- Required checks before merge:
  - `flutter analyze` — zero errors.
  - `flutter test` — all pass.
  - Offline dep audit — zero matches.
  - Manifest check — zero network permissions.

## 5. Environment And Flavor Matrix

Two Android build flavors are defined: `dev` and `prod`.

| Flavor | Application ID | App Name | Purpose |
|--------|---------------|----------|---------|
| `dev` | `in.sreerajp.sreerajp_todo.dev` | SreerajP ToDo Dev | Local development, QA, internal testing |
| `prod` | `in.sreerajp.sreerajp_todo` | SreerajP ToDo | Production builds, store submissions |

| Flavor + Mode | Command | Typical Use |
|---------------|---------|-------------|
| `dev` + `debug` | `flutter run --flavor dev` | Daily development and device testing |
| `dev` + `release` | `flutter build apk --flavor dev --release` | Release-like QA build |
| `prod` + `release` | `flutter build apk --flavor prod --release --split-per-abi` | Shareable release APKs |
| `prod` + `release` | `flutter build appbundle --flavor prod --release` | Play Store submission |

Windows builds do not use flavors. For detailed flavor usage, see `docs/flutter_build_flavors_guide.md`.

## 6. Signing And Secret Handling

- Signing config location: `L:\Android\key.properties` (one level above the project root).
- Keystore file: `L:\Android\key.properties.jks`
- Keystore ownership: SreerajP (single developer).
- Rules:
  - Signing material must not live in source control (`key.properties` and `.jks` files are in `.gitignore`).
  - The `key.properties` path is referenced from `android/app/build.gradle.kts` via a relative path (`../../key.properties`).
  - CI logs must not print signing secrets.

### Keystore Generation

```powershell
keytool -genkey -v -keystore L:\Android\key.properties.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sreerajp
```

### Gradle Signing Configuration

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("../../key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## 7. Release Checklist

Complete these items before every release.

### Code And Quality

- [ ] `flutter analyze` passed (zero errors, zero warnings).
- [ ] `dart format --output=none --set-exit-if-changed .` passed.
- [ ] `flutter test` passed (all unit and widget tests).
- [ ] Integration tests passed (`flutter test integration_test/app_test.dart`).
- [ ] No critical or release-blocking bugs remain open.

### Offline Enforcement

- [ ] Offline dep audit passed — zero networking matches:
  ```powershell
  flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio|chopper|retrofit|amplitude|mixpanel|datadog"
  ```
- [ ] Source manifest clean — zero network permissions:
  ```powershell
  Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
  ```
- [ ] Merged release manifest clean — zero network permissions:
  ```powershell
  Select-String -Path "build\app\intermediates\merged_manifests\prodRelease\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
  ```
- [ ] No `Image.network()` or `NetworkImage` in codebase:
  ```powershell
  Select-String -Path "lib\**\*.dart" -Pattern "Image\.network|NetworkImage" -Recurse
  ```

### Product And Documentation

- [ ] Version in `pubspec.yaml` was updated.
- [ ] Generated build metadata refreshed (`flutter build` does this on Android; run `.\tool\refresh_build_metadata.ps1` before Windows builds).
- [ ] `README.md` updated with screenshots and feature list.

### Security

- [ ] Manifest and permission review completed.
- [ ] Signing material is NOT in source control.
- [ ] Backup export/import round-trip test passed.

### Artifact Validation

- [ ] Android release APK built successfully.
- [ ] Android release AAB built successfully.
- [ ] Windows release built successfully.
- [ ] `sqlite3.dll` bundled in Windows release folder.
- [ ] Version name and build number are correct in built artifacts.

## 8. Android Release Steps

1. Pull the intended release commit on `main`.
2. Verify the version in `pubspec.yaml`. Android builds auto-refresh the generated About-screen metadata.
3. Fetch dependencies: `flutter pub get`.
4. Run pre-release checks:
   ```powershell
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   ```
5. Build the release artifacts:
   ```powershell
   flutter build apk --flavor prod --release --split-per-abi
   flutter build appbundle --flavor prod --release
   ```
6. Verify INTERNET permission is absent from the merged manifest:
   ```powershell
   Select-String -Path "build\app\intermediates\merged_manifests\prodRelease\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
   # Expected: ZERO matches. If any found: HALT and investigate.
   ```
7. Install the release APK on a physical device.
8. **Disable Wi-Fi AND mobile data** (airplane mode).
9. Launch the app and perform a full smoke test: create todo, start/stop timer, change status, view statistics, export/import backup.
10. Verify the app functions normally with zero network access.
11. Tag the release in git: `git tag v1.0.0`.

### Release Artifacts

- `build/app/outputs/flutter-apk/app-armeabi-v7a-prod-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-prod-release.apk`
- `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

## 9. Windows Release Steps

1. Refresh the generated About-screen metadata:
   ```powershell
   .\tool\refresh_build_metadata.ps1
   ```
2. Build the Windows release:
   ```powershell
   flutter build windows --release
   ```
3. Verify `sqlite3.dll` is bundled:
   ```powershell
   Test-Path "build\windows\x64\runner\Release\sqlite3.dll"
   # Expected: True
   ```
4. v1.0 is a **portable folder**: `build\windows\x64\runner\Release\`. No MSIX installer.
5. Copy the entire `Release` folder to a clean Windows 10 machine (or VM).
6. **Disable the network adapter.**
7. Run the `.exe` and perform a full smoke test.
8. Verify the app functions normally with zero network access and no firewall prompts.

### Release Artifacts

- `build\windows\x64\runner\Release\` (entire folder)

## 10. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Local sideload (Android) | APK | Personal use | Install via `adb install` or file manager |
| Local copy (Windows) | Portable folder | Personal use | Copy `Release` folder to target machine |

No public store distribution in v1.0.

## 11. Rollback And Hotfix Process

- Rollback trigger: Critical bug discovered after release (data loss, encryption failure, crash on launch).
- Rollback method: Revert to previous git tag, rebuild, and reinstall.
- Hotfix branch naming: Not applicable (main-only workflow, single developer).
- Verification after rollback or hotfix:
  - Full smoke test on both platforms with network disabled.
  - Offline dep audit and manifest check.

## 12. Release Evidence

- CI run: Not applicable (no CI in v1.0; manual build process).
- Test report: `flutter test` output in terminal.
- Built artifact: Local build output directories.
- Release tag: `git tag vX.Y.Z`

## 13. Post-Release Checks

- [ ] App launches and functions on both platforms with network disabled.
- [ ] Backup export/import works end-to-end.
- [ ] No network-related errors or warnings observed.
- [ ] Release tag created in git.
- [ ] Follow-up tasks recorded for the next version.



