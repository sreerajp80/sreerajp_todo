# Allow local Wi-Fi sync only, and block Google telemetry

**Status:** completed

## Issue

The project rules say the app has no `INTERNET` permission. The source manifest
(`android/app/src/main/AndroidManifest.xml`) follows that rule. But the **merged** release
manifest (the final one inside the APK) contains:

- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`

These come from plugins, not from our own manifest:

- `google_mlkit_text_recognition` (OCR) and `mobile_scanner` (QR scan) pull in Google ML Kit.
  ML Kit brings `com.google.android.datatransport` with the `CctBackendFactory` backend. That
  backend **uploads ML Kit usage logs to Google** when the phone is online. This is real
  internet traffic, and it breaks the privacy promise.
- The same libraries add `INTERNET` and `ACCESS_NETWORK_STATE`.

At the same time, **P2P Wi-Fi sync really needs `INTERNET`**. On Android, any socket, even
one that only talks to another phone on the same Wi-Fi, needs this permission. Today sync
only works because ML Kit adds the permission by accident.

Decision (from the user): keep Wi-Fi sync, and change the rule from "no INTERNET
permission" to **"no internet traffic"**. Only the local network is used, and only when the
user starts a Wi-Fi sync.

## Plan for the fix

### 1. Android manifest

Edit `android/app/src/main/AndroidManifest.xml`:

- Add the `xmlns:tools` namespace.
- Declare `INTERNET` ourselves, with a comment that says it exists **only** for local
  Wi-Fi sync between the user's own devices.
- Remove `ACCESS_NETWORK_STATE` from the merged manifest with `tools:node="remove"`. Our
  code does not need it.
- Turn off the ML Kit log upload. Remove the
  `backend:com.google.android.datatransport.cct.CctBackendFactory` meta-data from the
  `TransportBackendDiscovery` service with `tools:node="remove"`. With no backend, ML Kit
  log events are dropped on the device and never sent.
  - We do **not** remove the datatransport scheduler service or receiver. Removing them can
    crash the app when the library tries to schedule a job.

### 2. Dart guard in Wi-Fi sync (defence in depth)

The permission now allows any socket, so the sync code itself must refuse anything that is
not local.

- `lib/core/utils/network_address_utils.dart` (new, core layer, pure Dart):
  `isLocalNetworkAddress(String ip)`. It returns true only for IPv4 private and local ranges:
  `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `169.254.0.0/16` (link-local) and
  `127.0.0.0/8` (loopback). Everything else, including host names, returns false.
- `lib/core/errors/exceptions.dart`: add `NonLocalAddressException`.
- `lib/data/services/p2p_wifi_sync_service.dart`:
  - `connectAndSyncAsPeer` checks `hostIp` first. If it is not local, it throws
    `NonLocalAddressException` and never opens a socket.
  - The host server closes, right away, any incoming connection whose remote address is
    not local.
- The screen already shows any sync error through the localized
  `p2pSyncFailedMessage`, so no new ARB keys are needed.

### 3. Tests

- `test/core/utils/network_address_utils_test.dart` (new): private, link-local and
  loopback addresses pass. Public addresses (for example `8.8.8.8`, `172.32.0.1`,
  `192.169.0.1`), host names and bad input fail.
- `test/data/p2p_wifi_sync_service_test.dart`: add a test that connecting to a public
  address throws `NonLocalAddressException`.

### 4. Change the rule in the docs

Replace "zero network permissions / fully offline" with "no internet traffic". The new
rule says:

- `INTERNET` is allowed **only** for user-started Wi-Fi sync on the local network.
- `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE` and all other network permissions stay banned.
- No network packages, cloud SDKs, analytics, telemetry or crash reporting. Library
  telemetry backends (such as the ML Kit `CctBackendFactory`) must be removed in the
  manifest.
- Dart code may open sockets only to local-network addresses, and only in the Wi-Fi sync
  service.

Files:

- `CLAUDE.md` and `AGENTS.md`: project table, Hard rule 1, Security rules, and "Never" items
  11 and 14. Keep both files in sync.
- `docs/security.md`: network section, permission list, section 10 wording ("still holds no
  network permission"), test and audit tables.
- `docs/release_process.md`: fix the merged-manifest path (the real path is
  `build/app/intermediates/merged_manifest/prodRelease/processProdReleaseMainManifest/AndroidManifest.xml`).
  Change the checks: `INTERNET` is allowed, `ACCESS_NETWORK_STATE` must be absent, and
  `CctBackendFactory` must be absent.
- `docs/features.md`: section 2 guarantee and the "Staying offline" paragraph.
- `docs/architecture.md`, `docs/project_structure.md`, `docs/dependencies.md`,
  `docs/unique_features_and_improvements.md`, `README.md`: update the "zero INTERNET
  permission" claims so they match the new rule.
- Historical files (`docs/implementation_plan.md`, `docs/implementation_progress.md`, old
  plans and change logs) are **not** changed. They record the past.

## Files to change

- `android/app/src/main/AndroidManifest.xml`
- `lib/core/utils/network_address_utils.dart` (new)
- `lib/core/errors/exceptions.dart`
- `lib/data/services/p2p_wifi_sync_service.dart`
- `test/core/utils/network_address_utils_test.dart` (new)
- `test/data/p2p_wifi_sync_service_test.dart`
- `CLAUDE.md`, `AGENTS.md`
- `docs/security.md`, `docs/release_process.md`, `docs/features.md`, `docs/architecture.md`,
  `docs/project_structure.md`, `docs/dependencies.md`,
  `docs/unique_features_and_improvements.md`
- `README.md`

## How it will be checked

1. `dart format`, `flutter analyze` (0 issues) and `flutter test` (all pass).
2. Build the prod release APK. In the merged manifest, check that:
   - `INTERNET` is present,
   - `ACCESS_NETWORK_STATE` is absent,
   - `CctBackendFactory` is absent.
3. On a real phone (the user does this): OCR scan, QR scan and Wi-Fi sync between two
   devices still work.

## Out of scope (noted for later)

- `shared_preferences`, `qr_flutter`, `mobile_scanner`, `camera` and
  `google_mlkit_text_recognition` are not on the approved package list in `CLAUDE.md`.
- `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` (max SDK 28) are added by plugins.
  They may not be needed.
