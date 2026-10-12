# Release Process — SreerajP ToDo

This document defines the release runbook, signing configuration, build commands, versioning policy, and release checklist for SreerajP ToDo. Read this before building, signing, or distributing a release.

Read [AGENTS.md](../AGENTS.md) and [CLAUDE.md](../CLAUDE.md) first. For shared reference standards, see [guidelines/release_process.md](guidelines/release_process.md) and [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).

---

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

---

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Coordinates release readiness and final sign-off | SreerajP (single developer) |
| Engineering | Code freeze, fixes, validation | SreerajP |
| QA | Test execution and regression sign-off | SreerajP |

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`
- Source of truth: `pubspec.yaml`
- Build-number increment rule: Manual for v1.0; auto-incremented in CI if set up later.
- Git tag format: `vX.Y.Z`
- Initial release: `1.0.0+1` (Current release baseline: `2.1.0+45`)

---

## 4. Branch And Merge Policy

- Release branch strategy: `main only` (single developer, trunk-based).
- Hotfix strategy: Fix on main, tag, rebuild.
- Required checks before merge:
  - `flutter analyze` — zero errors.
  - `flutter test` — all pass.
  - Offline dep audit — zero matches.
  - Manifest check — `INTERNET` is the only network permission, and no ML Kit, Play Services or `datatransport` entries.

---

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
| `prod` + `release` | `flutter build apk --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/ --split-per-abi` | Shareable release APKs |
| `prod` + `release` | `flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/` | Play Store submission |

A release-like QA build of the `dev` flavor:

```powershell
flutter build apk --flavor dev --release --split-per-abi
```

Which artifact to use:

- **Split APKs** (`--split-per-abi`) for direct install. The output files are
  `app-armeabi-v7a-<flavor>-release.apk`, `app-arm64-v8a-<flavor>-release.apk` and
  `app-x86_64-<flavor>-release.apk`.
- **App Bundle** (`.aab`) for Google Play. Play serves device-specific downloads from it.
- `--target-platform` only controls compile targets. It does not make a normal APK
  ABI-specific. Use `--split-per-abi` (or Gradle `abiFilters`) for a true per-ABI APK.
- If split APK builds fail, check that custom APK naming logic in
  `android/app/build.gradle.kts` does not give every split the same file name.

Windows builds do not use flavors. For the general flavor reference, see
[guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).

---

## 6. Signing And Secret Handling

- Signing config location: `android/key.properties` (inside `android/`, never committed).
- Keystore file: `android/release-keystore.jks` (or custom name referenced by `key.properties`).
- Keystore ownership: SreerajP (single developer).
- Rules:
  - Signing material must not live in source control (`key.properties` and `.jks` files are in `.gitignore`).
  - The `key.properties` path is referenced from `android/app/build.gradle.kts` via `rootProject.file("key.properties")`.
  - CI and local logs must not print signing secrets.
  - Always archive `build/symbols/` immediately after production builds for crash stack trace de-obfuscation.

### Keystore Generation

```powershell
keytool -genkey -v -keystore android/release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sreerajp
```

### Gradle Signing Configuration

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

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

---

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
- [ ] Merged release manifest clean — `INTERNET` (for local Wi-Fi sync only) is expected; nothing below may match:
  ```powershell
  Select-String -Path "build\app\intermediates\merged_manifest\prodRelease\processProdReleaseMainManifest\AndroidManifest.xml" -Pattern "ACCESS_NETWORK_STATE|ACCESS_WIFI_STATE|CHANGE_WIFI|EXTERNAL_STORAGE|EXACT_ALARM|com\.google\.mlkit|com\.google\.android\.gms|datatransport|firebase"
  # Expected: ZERO matches.
  ```
- [ ] Only Wi-Fi sync opens sockets, and it checks every address with `isLocalNetworkAddress()`:
  ```powershell
  Select-String -Path "lib\**\*.dart" -Pattern "Socket\.connect|ServerSocket\.bind|RawDatagramSocket|HttpClient" -Recurse
  # Expected: matches in lib\data\services\p2p_wifi_sync_service.dart only.
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

### Play Store Readiness (Mandatory Gate)

- [ ] Full §10 gate completed for this release.
- [ ] Language splitting disabled in App Bundle (`bundle.language.enableSplit = false`, §10.3).
- [ ] `targetSdkVersion` meets Play's current target API level policy (re-checked, not assumed).
- [ ] `versionCode` strictly greater than every previously uploaded build.
- [ ] App Bundle built; Play App Signing enabled; native debug symbols uploaded.
- [ ] Permissions justified; sensitive-permission declarations completed in the console.
- [ ] Privacy policy URL live; Data safety form matches actual behavior; content rating done.
- [ ] Store listing assets ready at the required sizes (icon, feature graphic, screenshots).
- [ ] English and Malayalam listings complete with localized screenshots.
- [ ] Internal-testing upload done and pre-launch report clean.
- [ ] Staged rollout percentage chosen and vitals monitoring planned.

### Artifact Validation

- [ ] Android release APK built successfully.
- [ ] Android release AAB built successfully.
- [ ] `libapp.so` in every release APK and in the AAB is stripped (no DWARF debug info) — see §8 step 7. The "unobfuscated DWARF" build warning is expected and is not a failure by itself.
- [ ] Windows release built successfully.
- [ ] `sqlite3.dll` bundled in Windows release folder.
- [ ] Version name and build number are correct in built artifacts.

---

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
   flutter build apk --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/ --split-per-abi
   flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/
   ```
   Run these two builds one after the other, never at the same time as `flutter test`.

   Expected warning, once per CPU type: `The generated ELF library contains unobfuscated DWARF debugging information.`
   On Android, Flutter does not strip debug info (DWARF) from `libapp.so` (the compiled Dart
   code) itself. It leaves that to the Android Gradle Plugin, which strips the file while
   packaging. The warning is about the file before packaging. Step 7 confirms that the
   shipped file is stripped.
6. Archive debug symbols immediately to secure storage:
   ```powershell
   # Archive build/symbols/android-prod/ alongside release notes
   ```
7. Verify that the shipped Dart library (`libapp.so`) in every APK and in the app bundle has no debug info:
   ```powershell
   Add-Type -AssemblyName System.IO.Compression.FileSystem
   $archives = @(Get-ChildItem "build\app\outputs\flutter-apk\*-prod-release.apk") + @(Get-ChildItem "build\app\outputs\bundle\prodRelease\*.aab")
   foreach ($archive in $archives) {
       $zip = [System.IO.Compression.ZipFile]::OpenRead($archive.FullName)
       try {
           foreach ($entry in $zip.Entries | Where-Object { $_.FullName -like '*lib/*/libapp.so' }) {
               $stream = $entry.Open(); $buffer = New-Object System.IO.MemoryStream
               $stream.CopyTo($buffer); $stream.Dispose()
               $text = [System.Text.Encoding]::ASCII.GetString($buffer.ToArray())
               $status = if ($text.Contains('.debug_info')) { 'NOT STRIPPED - HALT' } else { 'stripped' }
               '{0} {1}: {2}' -f $archive.Name, $entry.FullName, $status
           }
       } finally { $zip.Dispose() }
   }
   # Expected: every line ends with "stripped" (3 APKs + 3 lines for the .aab).
   # If any line says NOT STRIPPED: HALT. Check that the NDK version Flutter uses
   # (flutter.ndkVersion) is installed, and look for an AGP "Unable to strip" warning
   # in the build output.
   ```
8. Verify the merged manifest has no extra network permission, no unused storage or exact-alarm permission, and no Google ML Kit, Play Services or telemetry entries:
   ```powershell
   Select-String -Path "build\app\intermediates\merged_manifest\prodRelease\processProdReleaseMainManifest\AndroidManifest.xml" -Pattern "ACCESS_NETWORK_STATE|ACCESS_WIFI_STATE|CHANGE_WIFI|EXTERNAL_STORAGE|EXACT_ALARM|com\.google\.mlkit|com\.google\.android\.gms|datatransport|firebase"
   # Expected: ZERO matches. If any found: HALT and investigate.
   # INTERNET is expected: it is used only by Wi-Fi sync on the local network.
   ```
9. Install the release APK on a physical device.
10. **Disable Wi-Fi AND mobile data** (airplane mode).
11. Launch the app and perform a full smoke test: create todo, start/stop timer, change status, view statistics, export/import backup.
12. Verify the app functions normally with zero network access.
13. Turn Wi-Fi back on (no mobile data) and run one Wi-Fi sync between two devices, plus one OCR scan and one QR scan.
14. Complete the Google Play readiness gate (§10) before uploading to Play.
15. Tag the release in git: `git tag v2.1.0`.

### Release Artifacts

- `build/app/outputs/flutter-apk/app-armeabi-v7a-prod-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-prod-release.apk`
- `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

---

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
8. Verify the app functions normally with zero network access and no firewall prompts. (Starting Wi-Fi sync as host may show a Windows firewall prompt. That is expected, and it is for the local network only.)

### Release Artifacts

- `build\windows\x64\runner\Release\` (entire folder)

---

## 10. Google Play Store Readiness (Mandatory Gate)

Every app is built to be publishable on Google Play. This gate MUST pass **before the first upload** and MUST be re-checked before every production release. Items marked *(one-time)* are set up once and only re-verified afterwards.

### 10.1 Application identity and versioning

| Item | Requirement |
|---|---|
| `applicationId` *(one-time)* | Reverse-DNS, owned domain, lowercase, permanent. For SreerajP ToDo: `in.sreerajp.sreerajp_todo` (`in.sreerajp.sreerajp_todo.dev` for dev flavor). It can never be changed after the first publish. |
| `versionCode` | Strictly increasing integer on every upload, never reused — even for a rejected or rolled-back build. |
| `versionName` | Matches `pubspec.yaml` (`<version>+<build>` → `versionName+versionCode`). |
| App name | Set in `android/app/src/main/AndroidManifest.xml` via a localized `@string/app_name`, matching the store listing. |
| Package visibility | If the app queries other packages, declare `<queries>` — Play rejects silent package enumeration. |

### 10.2 API level, ABI, and compatibility

- `targetSdkVersion` MUST meet Play's current target API level policy (currently targeting SDK 35).
- `compileSdkVersion` ≥ `targetSdkVersion` (targeting SDK 35).
- `minSdkVersion` is a deliberate, documented product decision — 21 (Android 5.0) recorded in `docs/architecture.md`.
- 64-bit native code is mandatory: ship an App Bundle (`prodRelease/app-prod-release.aab`), or split APKs including `arm64-v8a`.
- 16 KB page-size compliance is required for Android 15+ devices.
- Edge-to-edge behavior verified when targeting SDK 35+.

### 10.3 Signing and upload

- Ship an **Android App Bundle (`.aab`)**, not an APK, to Play.
- **Language splitting MUST be disabled** (`bundle { language { enableSplit = false } }` in `android/app/build.gradle.kts`). Without this, Play downloads only the phone's system language, breaking the in-app language picker when switching to Malayalam or Sanskrit.
- **Play App Signing** MUST be enabled *(one-time)*. Keep the upload key backed up offline; losing the upload key is recoverable through Play support, losing a pre-App-Signing release key is not.
- Signing config points at `android/key.properties` (see `docs/guidelines/guideline.md §2`) and is **never** committed.
- `flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/` — all three flags, always.
- Upload the native debug symbols (`build/symbols/android-prod/`) to Play so crash traces de-obfuscate, and archive them alongside the release evidence.

### 10.4 Manifest, permissions, and policy declarations

- Every permission in the merged manifest is justified and used. The full list is:
  - `CAMERA` (OCR scanning and AirQR sync)
  - `RECORD_AUDIO` (on-device speech-to-text voice input)
  - `POST_NOTIFICATIONS` (running-timer and pending-task reminder notifications)
  - `RECEIVE_BOOT_COMPLETED` (schedule reminder alarms again after a phone restart)
  - `INTERNET` (Wi-Fi sync on the local network only)
  - `<applicationId>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (added by AndroidX core; internal to the app, expected)

  See `docs/security.md` §10 for details. Remove anything inherited from a dependency that the app does not need (`tools:node="remove"`). `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` (added by the camera plugin) are removed this way. Reminders use inexact alarms, so `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` must not be declared.
- Sensitive permissions require an in-console declaration: camera and microphone declarations explain offline, user-initiated usage.
- `android:debuggable=false`, `android:allowBackup="false"`, `usesCleartextTraffic=false`.
- No accidental `android:exported="true"`.
- No network permission except `INTERNET` (local Wi-Fi sync). No `ACCESS_NETWORK_STATE`, no `ACCESS_WIFI_STATE`, and no ML Kit, Play Services or `datatransport` entries.
- Play Data safety form: no data is collected or shared. Wi-Fi sync moves data only between the user's own devices on the local network.

### 10.5 Store account declarations

- **Privacy policy URL** — reachable, public, app-specific. Required for every app, whether or not it collects data.
- **Data safety form** — completed and matching what the app actually does (100% offline, zero data collected or shared).
- **Content rating questionnaire** — completed.
- **Target audience and content** — declared.
- **Ads declaration** — No ads.

### 10.6 Store listing assets

| Asset | Requirement |
|---|---|
| App icon | 512 × 512 PNG, 32-bit, no alpha-dependent design |
| Feature graphic | 1024 × 500 PNG/JPG |
| Phone screenshots | 2–8, PNG/JPG, 16:9 or 9:16, min 320 px, max 3840 px on the longest side |
| Tablet screenshots | Required if the app is distributed to tablets (7-inch and 10-inch sets) |
| Short description | ≤ 80 characters |
| Full description | ≤ 4000 characters |
| App title | ≤ 30 characters, no keyword stuffing, no store badges or price in the title |

### 10.7 Localization of the listing

The app itself ships English, Malayalam, and Sanskrit (`docs/guidelines/flutter_project_engineering_standard.md §8`).

- The Play listing MUST be provided in **English** and in **Malayalam** (`ml-IN`), including localized screenshots.
- **Sanskrit is not an available Play listing language.** It is shipped *inside* the app only; do not attempt to add it as a store locale, and do not drop it from the app because the store cannot list it.
- Screenshots MUST show real app UI in the language of that listing — not English screenshots under the Malayalam listing.

### 10.8 Pre-launch verification

- Upload to **internal testing** first; run the Play Console **pre-launch report** and resolve all crashes, ANRs, and flagged accessibility and security items.
- Verify the app installs, launches, and completes its primary flow from a Play-served build (not just a locally installed APK), in all three languages.
- Android vitals thresholds reviewed after each rollout (crash rate, ANR rate).
- Production rollout starts as a **staged rollout** (e.g. 10% → 50% → 100%) with vitals checked at each step.

---

## 11. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Local sideload (Android) | APK | Personal use | Install via `adb install` or file manager |
| Local copy (Windows) | Portable folder | Personal use | Copy `Release` folder to target machine |

No public store distribution in v1.0.

---

## 12. Rollback And Hotfix Process

- Rollback trigger: Critical bug discovered after release (data loss, encryption failure, crash on launch).
- Rollback method: Revert to previous git tag, rebuild, and reinstall.
- Hotfix strategy: Fix on main, tag, rebuild.
- Verification after rollback or hotfix:
  - Full smoke test on both platforms with network disabled.
  - Offline dep audit and manifest check.

---

## 13. Release Evidence

- CI run: Not applicable (no CI in v1.0; manual build process).
- Test report: `flutter test` output in terminal.
- Built artifact: Local build output directories.
- Release tag: `git tag vX.Y.Z`

---

## 14. Post-Release Checks

- [ ] App launches and functions on both platforms with network disabled.
- [ ] Backup export/import works end-to-end.
- [ ] No network-related errors or warnings observed.
- [ ] Release tag created in git.
- [ ] Follow-up tasks recorded for the next version.
