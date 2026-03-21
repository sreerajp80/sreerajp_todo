# Phase 9 — Build & Release

## Objective
Produce signed, distributable builds for Android (APK + AAB) and Windows (portable folder), with final offline verification on physical devices with network disabled.

## Pre-Requisites
- Phases 1–8 complete (all features, tests passing, performance profiled).
- Read `CLAUDE.md` — build rules, signing, offline enforcement.
- Read `docs/release_process.md` — full release checklist (§7), Android release steps (§8), Windows release steps (§9), signing and secret handling (§6).
- Read `docs/security.md` — platform security controls (§9 — Android manifest, Windows network capabilities), offline enforcement, permissions (§10).
- Read `docs/flutter_project_engineering_standard.md` — Definition of Done (§14 — all three profiles), artifact selection (§5.4), CI standard (§10).

---

## Tasks

### 1. Version Management

Set in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
Semantic versioning. Build number can be auto-incremented in CI later.

### 2. Android Build

#### Configure signing:
- Generate a release keystore (if not already done):
  ```powershell
  keytool -genkey -v -keystore L:\Android\key.properties.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sreerajp
  ```
- Create `key.properties` at `L:\Android\key.properties` (**one level above project root, never committed to Git**):
  ```properties
  storePassword=<password>
  keyPassword=<password>
  keyAlias=sreerajp
  storeFile=L:\\Android\\key.properties.jks
  ```
- Configure `android/app/build.gradle` to read from `key.properties`:
  ```groovy
  def keystoreProperties = new Properties()
  def keystorePropertiesFile = rootProject.file('../../key.properties')
  if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
  }

  android {
      signingConfigs {
          release {
              keyAlias keystoreProperties['keyAlias']
              keyPassword keystoreProperties['keyPassword']
              storeFile file(keystoreProperties['storeFile'])
              storePassword keystoreProperties['storePassword']
          }
      }
      buildTypes {
          release {
              signingConfig signingConfigs.release
          }
      }
  }
  ```

#### Set application ID and version:
- `applicationId`: `in.sreerajp.sreerajp_todo`
- `minSdkVersion`: 21 (Android 5.0 Lollipop)
- `targetSdkVersion`: latest stable (34+)
- `compileSdkVersion`: latest stable

#### Build:
```powershell
# Debug APK (for testing)
flutter build apk --debug

# Release APK
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

#### Verify INTERNET permission absent from merged manifest:
```powershell
Select-String -Path "build\app\intermediates\merged_manifests\release\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
# Expected: ZERO matches
```
**If any matches found: HALT. Investigate which transitive dependency added the permission. Remove it before proceeding.**

#### Test on physical device:
1. Install the release APK on a physical Android device.
2. **Disable Wi-Fi AND mobile data** (airplane mode).
3. Launch the app.
4. Create a todo, start/stop timer, change status, view statistics.
5. **Verify the app functions normally with zero network access.**
6. Verify no error messages, warnings, or degraded functionality.

### 3. Windows Build

#### Build:
```powershell
flutter build windows --release
```

#### Verify sqlite3.dll bundled:
```powershell
Test-Path "build\windows\x64\runner\Release\sqlite3.dll"
# Expected: True
```

#### Windows release packaging:
- **v1.0 is a portable folder**: `build\windows\x64\runner\Release\`
- No MSIX installer for v1.0 (deferred).
- Copy the entire `Release` folder to distribute.

#### Verify no network capabilities:
- Check that no `Package.appxmanifest` declares `internetClient`, `internetClientServer`, or `privateNetworkClientServer`.
- If using MSIX in future: these capabilities must be absent.

#### Test on clean Windows environment:
1. Copy the `Release` folder to a clean Windows 10 machine (or VM).
2. **Disable the network adapter.**
3. Run the `.exe`.
4. Create a todo, start/stop timer, change status, view statistics.
5. **Verify the app functions normally with zero network access.**
6. Verify no firewall prompts or network-related errors.

### 4. Final Checklist

#### Code quality:
```powershell
# Run analyzer
flutter analyze
# Expected: zero errors, zero warnings

# Format code
dart format lib/ test/ integration_test/

# Run all tests
flutter test
# Expected: all pass

# Run integration tests
flutter test integration_test/app_test.dart
# Expected: all pass
```

#### Offline enforcement:
```powershell
# Dep audit
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio|chopper|retrofit|amplitude|mixpanel|datadog"
# Expected: zero matches

# Manifest check
Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
# Expected: zero matches

# Merged manifest check (after release build)
Select-String -Path "build\app\intermediates\merged_manifests\release\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
# Expected: zero matches
```

#### Asset verification:
- All fonts bundled in `assets/fonts/`.
- No `Image.network()` or `NetworkImage` in codebase:
  ```powershell
  Select-String -Path "lib\**\*.dart" -Pattern "Image\.network|NetworkImage" -Recurse
  # Expected: zero matches
  ```

### 5. Release Artifacts

Final release artifacts:
- `build/app/outputs/flutter-apk/app-release.apk` — Android APK
- `build/app/outputs/bundle/release/app-release.aab` — Android App Bundle
- `build/windows/x64/runner/Release/` — Windows portable folder

### 6. README

Update the project `README.md` with:
- App name and description.
- Screenshots (daily list, statistics, time tracking).
- Feature list.
- Installation instructions (Android APK sideload, Windows portable).
- Build instructions.
- Offline guarantee statement.

---

## Deliverables
- [ ] Signed release APK built successfully
- [ ] Signed release AAB built successfully
- [ ] Merged Android manifest confirmed: ZERO network permissions
- [ ] APK tested on physical device with network disabled — works fully
- [ ] Windows release built successfully
- [ ] `sqlite3.dll` bundled in Windows release
- [ ] Windows `.exe` tested with network adapter disabled — works fully
- [ ] `flutter analyze` — zero errors
- [ ] All tests passing
- [ ] Offline dep audit — zero matches
- [ ] No `Image.network()` / `NetworkImage` in codebase
- [ ] README updated
