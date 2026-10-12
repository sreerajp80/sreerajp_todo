# Explain the DWARF warning and add a release check for it

**Status:** completed

## Files to be changed

- `docs/release_process.md` — add a note and a check after the release build step
  (§8 "Android Release Steps", steps 5–6), and a matching line in the §7 "Release Checklist" (Artifact Validation).

No build files, no code. (See "Option not chosen" below.)

## What the issue is

`flutter build apk --flavor prod --release --obfuscate --split-debug-info=...` prints, once
per CPU type:

> Warning: The generated ELF library contains unobfuscated DWARF debugging information.

"DWARF" is the debug information that maps machine code back to Dart source (file names,
line numbers). With `--obfuscate`, we do not want readable names inside the shipped app.

### What I found

1. **Who prints it:** Flutter's Dart compiler (`gen_snapshot`). It prints it when it writes
   `libapp.so` (the compiled Dart code) with debug info inside and was not given `--strip`.
2. **Why there is no `--strip`:** in the Flutter SDK, `packages/flutter_tools/lib/src/base/build.dart`
   adds `--strip` for desktop builds, but for Android it skips it on purpose, with the
   comment "When building for Android, we let AGP handle stripping of debug symbols." So
   Flutter expects the Android build tools (AGP) to strip the file later.
3. **Does AGP strip it? Yes.** I checked the arm64 build from the last release build:

   | File | Size | Debug info inside? |
   |---|---|---|
   | `libapp.so` before stripping (`merged_native_libs`) | 16.8 MB | Yes |
   | `libapp.so` after `stripProdReleaseDebugSymbols` | 10.9 MB | No |
   | `libapp.so` inside the final `app-arm64-v8a-prod-release.apk` | 10.9 MB | No |

4. **Symbols are still kept for crash reports:** `build/symbols/android-prod/` has
   `app.android-arm.symbols`, `app.android-arm64.symbols` and `app.android-x64.symbols`,
   as the release process requires.

**Conclusion:** the warning is about a temporary file, not about what ships. The shipped APK
has no DWARF data. It is expected Flutter behaviour on Android, and no build change is
needed. The real risk is different: if AGP ever cannot strip (for example, the Android NDK
is missing on a build machine), the APK would ship with debug info and nobody would notice,
because the warning prints in both cases. So the useful fix is a check on the final file.

## Plan for the fix

In `docs/release_process.md`:

1. After step 5 (build release artifacts), add a short note: the DWARF warning is
   expected on Android. Flutter leaves stripping to AGP, so the warning refers to the
   unstripped file before packaging.
2. Add a new check step after step 6 (archive symbols): "Verify the shipped Dart library is
   stripped". A PowerShell command that, for each split APK, reads `lib/<abi>/libapp.so`
   from the APK and searches it for the `.debug_info` section name. It does the same for
   the app bundle (`base/lib/<abi>/libapp.so` in the `.aab`). Expected: no match in any of
   them. If a match is found: HALT. Check that the NDK version in `flutter.ndkVersion` is
   installed, and look for an AGP "Unable to strip" warning in the build output.
3. Renumber the later steps in §8 (current 7–14 become 8–15) and fix any references to
   those step numbers in the file.
4. Add the same check as one line in the §7 Release Checklist, under "Artifact Validation".

## Option not chosen

Passing `--extra-gen-snapshot-options=--strip` to the build would hide the warning. I do not
recommend it:
- It goes against how Flutter is designed to work on Android.
- It changes the release build command in several docs and CI for no change in the shipped
  APK.
- It would hide the warning without proving that the final file is stripped. The new check
  does prove it.

## Checks

- Run the new PowerShell check against the current release APKs. Expected: no match.
- Build the app bundle once
  (`flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod/`),
  on its own, and run the check on it too. Expected: no match.
- Re-read the edited doc: steps numbered in order, references updated, relative paths only.
- No `flutter analyze` / `flutter test` needed (docs only).

## After the change

Write a change log in `change_log/` that references this plan, and set this plan's status
to `completed`.
