# Explain the DWARF warning and add a release check for it

Implements plan: `plans/20261011_205500_dwarf_warning_release_check.md`

## Why

Android release builds print "The generated ELF library contains unobfuscated DWARF
debugging information" once per CPU type. The Flutter SDK
(`packages/flutter_tools/lib/src/base/build.dart`) does not pass `--strip` to the Dart
compiler for Android on purpose; it leaves stripping to the Android Gradle Plugin (AGP). So
the warning is about `libapp.so` before packaging, not about the shipped file.

The real risk is that AGP could fail to strip on some build machine (for example, a missing
NDK). The warning prints either way, so nothing would show the problem. A check on the
final files closes that gap.

## What changed

Docs only. No build files or code.

`docs/release_process.md`:

- **§8 step 5:** added a note that the DWARF warning is expected on Android and why, and a
  reminder to run the release builds on their own (not at the same time as `flutter test`).
- **§8 new step 7:** a PowerShell check that opens every prod release APK and the `.aab`,
  reads each `lib/<abi>/libapp.so`, and reports `stripped` or `NOT STRIPPED - HALT` (by
  looking for the `.debug_info` section name). It says what to check if a file is not
  stripped.
- **§8 steps 7–14 renumbered to 8–15.** No other doc refers to these step numbers.
- **§7 Release Checklist → Artifact Validation:** new line for the stripped-`libapp.so`
  check, pointing to §8 step 7.

## Option not chosen

`--extra-gen-snapshot-options=--strip` would hide the warning, but goes against Flutter's
Android design and changes nothing in the shipped files.

## Checks

- Ran the new check on the current prod release build:
  - 3 APKs (arm64-v8a, armeabi-v7a, x86_64): all `stripped`.
  - Built the app bundle on its own (106.2 MB), then checked it: all 3 `libapp.so` files
    `stripped`.
- Positive control: the same search on the unstripped `libapp.so` from
  `merged_native_libs` finds `.debug_info`, so the check does catch an unstripped file.
- Size check (arm64): 16.8 MB before stripping, 10.9 MB in the APK.
- Re-read §7 and §8: steps numbered 1–15 in order, relative paths only.
- No `flutter analyze` / `flutter test` run needed (docs only).
