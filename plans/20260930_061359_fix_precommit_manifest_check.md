# Fix the pre-commit manifest check for LAN-only Wi-Fi sync

**Status:** completed

## Files to change

- `.githooks/pre-commit.ps1` (the manifest check section only)

No app code, tests, or docs change. The shell wrapper `.githooks/pre-commit` stays as it is.

## The issue

The pre-commit hook stops every commit with this message:

> AndroidManifest.xml contains network permissions. Commit aborted.

The hook searches `android/app/src/main/AndroidManifest.xml` for the text
`INTERNET` or `NETWORK_STATE`. If either word appears anywhere, it blocks the commit.

The project rules changed in
`change_log/20260928_104937_allow_lan_only_network_block_telemetry.md`:

- `INTERNET` is now allowed, only so Wi-Fi sync can reach the user's own devices on the
  local network.
- `ACCESS_NETWORK_STATE` is still banned. The manifest now has an entry with
  `tools:node="remove"` that strips it from the final app, in case a plugin adds it.

Both of these lines are correct, but both contain the words the hook looks for. The hook
was not updated when the rules changed, so it now blocks good commits.

## The fix

Replace the simple text search with a check that reads the manifest as XML and looks at
each `<uses-permission>` (and `<uses-permission-sdk-23>`) element:

1. **Allowed:** `android.permission.INTERNET`.
2. **Allowed:** any network permission that has `tools:node="remove"`. This entry takes the
   permission out of the final app, so it is a safety guard, not a request.
3. **Blocked:** any other network permission that is not removed. The blocked list is:
   - `android.permission.ACCESS_NETWORK_STATE`
   - `android.permission.ACCESS_WIFI_STATE`
   - `android.permission.CHANGE_NETWORK_STATE`
   - `android.permission.CHANGE_WIFI_STATE`
   - `android.permission.CHANGE_WIFI_MULTICAST_STATE`
   - `android.permission.NEARBY_WIFI_DEVICES`
4. If the manifest cannot be read as XML, the hook stops the commit and says so (fail safe).
5. On failure, the hook prints the name of each blocked permission it found, so the reason
   is clear.

The XML parser in PowerShell ignores comments. So the word "INTERNET" inside a manifest
comment will no longer cause a false alarm either.

The success message stays `Manifest check passed.` The heading changes to say it checks for
banned network permissions.

### Limits (not in scope)

- The hook checks the source manifest only, not the merged release manifest. Plugins can
  add permissions during the build. Checking the merged manifest needs a full build, which
  is too slow for a pre-commit hook. The release checklist in `docs/release_process.md`
  already covers the merged manifest check.

## How to verify

1. Run the hook directly: `powershell -ExecutionPolicy Bypass -NoProfile -File .githooks/pre-commit.ps1`.
   The manifest step must print `Manifest check passed.`
2. Test the check against temporary copies of the manifest in the scratch folder (not the
   real file):
   - add `ACCESS_WIFI_STATE` without `tools:node="remove"` → must fail and name it;
   - remove `tools:node="remove"` from `ACCESS_NETWORK_STATE` → must fail and name it;
   - the current manifest → must pass.
3. Write a change log in `change_log/` after the change.
