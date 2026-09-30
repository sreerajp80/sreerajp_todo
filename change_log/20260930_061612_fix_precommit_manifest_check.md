# Fix the pre-commit manifest check for LAN-only Wi-Fi sync

**Plan:** `plans/20260930_061359_fix_precommit_manifest_check.md`

## What changed

- `.githooks/pre-commit.ps1`: rewrote the manifest check.
  - Before: the hook blocked the commit if the text `INTERNET` or `NETWORK_STATE`
    appeared anywhere in `android/app/src/main/AndroidManifest.xml`. This blocked every
    commit after `INTERNET` was allowed for local Wi-Fi sync, and it also matched the
    `ACCESS_NETWORK_STATE` entry that has `tools:node="remove"`.
  - Now: the hook reads the manifest as XML and checks each `<uses-permission>` and
    `<uses-permission-sdk-23>` element.
    - `INTERNET` is allowed.
    - These are blocked unless the entry has `tools:node="remove"`:
      `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CHANGE_NETWORK_STATE`,
      `CHANGE_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`, `NEARBY_WIFI_DEVICES`.
    - If the manifest is not valid XML, the commit is stopped.
    - When a commit is blocked, the hook prints each banned permission it found.
    - Text inside XML comments no longer causes false alarms.

No app code, tests or docs changed.

## Verification

Ran the new check with Windows PowerShell (the same shell the hook uses):

| Manifest | Result |
|----------|--------|
| Current manifest | Passed |
| Copy with `ACCESS_WIFI_STATE` added | Blocked, named `ACCESS_WIFI_STATE` |
| Copy with `tools:node="remove"` taken off `ACCESS_NETWORK_STATE` | Blocked, named `ACCESS_NETWORK_STATE` |
| Broken XML | Blocked, "could not be read as XML" |

The full hook (`flutter analyze`, offline dependency audit, manifest check, `flutter test`)
passed on the current tree.

## Not covered

The hook checks the source manifest only. Plugins can add permissions during the build, so
the release checklist in `docs/release_process.md` still checks the merged release manifest.
