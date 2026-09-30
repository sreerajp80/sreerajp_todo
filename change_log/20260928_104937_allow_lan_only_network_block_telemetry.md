# Allow local Wi-Fi sync only, and block Google telemetry

Implements plan: `plans/20260928_104111_allow_lan_only_network_block_telemetry.md`

## Why

The merged release manifest had `INTERNET` and `ACCESS_NETWORK_STATE`, added by Google
ML Kit (OCR and QR scan). ML Kit also shipped a log uploader (`datatransport` with the
`CctBackendFactory` backend) that sends usage events to Google. At the same time, Wi-Fi
sync really needs `INTERNET`, because Android asks for it for any socket.

The project rule changes from "no INTERNET permission" to **"no internet traffic"**.

## What changed

### Android

- `android/app/src/main/AndroidManifest.xml`
  - Added the `tools` namespace.
  - Declared `INTERNET` ourselves, with a comment: it is for local Wi-Fi sync only.
  - Removed `ACCESS_NETWORK_STATE` with `tools:node="remove"`.
  - Removed the ML Kit `CctBackendFactory` meta-data from `TransportBackendDiscovery`
    with `tools:node="remove"`, so usage events are dropped on the device. The scheduler
    service and receiver are kept.

### Code

- `lib/core/utils/network_address_utils.dart` (new): `isLocalNetworkAddress()` accepts
  only IPv4 private (`10/8`, `172.16/12`, `192.168/16`), link-local (`169.254/16`) and
  loopback (`127/8`) addresses. Host names, IPv6 and bad input are refused.
- `lib/core/errors/exceptions.dart`: added `NonLocalAddressException`.
- `lib/data/services/p2p_wifi_sync_service.dart`:
  - `connectAndSyncAsPeer` throws `NonLocalAddressException` before opening a socket if
    the host address is not local.
  - The host server drops any incoming connection from a non-local address.
  - The existing localized `p2pSyncFailedMessage` shows the error, so no ARB change was
    needed.

### Tests

- `test/core/utils/network_address_utils_test.dart` (new): local, public and malformed
  addresses.
- `test/data/services/p2p_wifi_sync_service_test.dart`: connecting to a public address or
  a host name throws `NonLocalAddressException`.

### Docs

- `CLAUDE.md`, `AGENTS.md`: Hard rule 1 is now "No Internet Traffic". The project table,
  Security rules and "Never" items 11 and 14 were updated to match. The two files are
  still in sync.
- `docs/security.md`: in-transit section, Android and Windows controls, permission table,
  voice section wording, test table, audit list and a new open risk.
- `docs/release_process.md`: fixed the merged-manifest path. The audit now expects
  `INTERNET` and checks that `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE` and
  `CctBackendFactory` are absent. Added a socket-code check, a Wi-Fi sync / OCR / QR smoke
  test step, a Windows firewall note and a Data safety note.
- `docs/features.md`, `docs/architecture.md`, `docs/dependencies.md`,
  `docs/project_structure.md`, `docs/unique_features_and_improvements.md`, `README.md`:
  replaced "zero INTERNET permission" claims with the new rule.

## Verification

- `dart format`: clean.
- `flutter analyze`: no issues.
- `flutter test`: all 839 tests pass.
- `flutter build apk --flavor prod --release --split-per-abi`: built. In the merged
  manifest (main and all three ABI manifests):
  - `INTERNET` is present,
  - `ACCESS_NETWORK_STATE` is absent,
  - `CctBackendFactory` is absent.

## Still to do by hand

- On a real phone: run one OCR scan, one QR scan, and one Wi-Fi sync between two devices,
  to confirm nothing broke.

## Not changed (out of scope)

- Packages not on the approved list: `shared_preferences`, `qr_flutter`,
  `mobile_scanner`, `camera`, `google_mlkit_text_recognition`.
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` (max SDK 28) added by plugins.
