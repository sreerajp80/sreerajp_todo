# Document the web-only `http` transitive dependency

**Status:** completed

## Files to be changed

- `docs/dependencies.md`

No code, `pubspec.yaml` or `pubspec.lock` changes.

## What the issue is

The offline audit command in `docs/dependencies.md` §6 finds the `http` package in the
dependency tree. `docs/dependencies.md` §4 says `http` is banned in direct **and transitive**
dependencies, so on paper the project breaks its own rule.

Findings:

- `pubspec.lock` lists `http` as `dependency: transitive`. No file in `lib/` imports it.
- It comes from `image_cropper` → `image_cropper_platform_interface` (8.0.0), which declares
  `http: ^1.0.0` in its `pubspec.yaml`.
- Inside that package, `http` is imported by one file only:
  `lib/src/models/cropped_file/html.dart`. This is the **web** version of `CroppedFile`. It
  uses `http.readBytes()` to read a cropped image from a browser blob URL.
- The package picks the file with a conditional export (`cropped_file.dart`). Builds that
  have `dart:io` (Android, Windows, and later iOS, Linux, macOS) get `io.dart`. That file
  reads local files only and never imports `http`.
- This project does not build for web. So the `http` code is never compiled into the app,
  and the app never sends traffic through it.

The audit matches package *names*. It cannot tell which code is compiled in. Without a note,
every future audit will flag this again, and the §4 rule reads as if it is broken.

## Plan for the fix

Edit `docs/dependencies.md` only:

1. **§4 Prohibited Dependency Categories** — under the intro line, add a short
   "Known exceptions" note. It points to the new section below and says no other
   transitive exception is allowed without the same review.

2. **New subsection "Known transitive exceptions"** (placed after §4, before §5) with a
   small table:

   | Package | Pulled in by | Why it is allowed |
   |---|---|---|
   | `http` | `image_cropper` → `image_cropper_platform_interface` | Used only by the package's web `CroppedFile` (`cropped_file/html.dart`), picked by a conditional export. Android and desktop builds use `cropped_file/io.dart`, which has no network code. The app does not target web, so `http` is never compiled in. |

   Add a line saying this must be checked again when:
   - `image_cropper` or `image_cropper_platform_interface` is upgraded (check that `http`
     is still used only from the web file), or
   - a web build target is added (then `http` would be compiled in, and the exception no
     longer holds).

3. **§6 Dependency Audit Command** — change the last line so it says: zero matches are
   required, except the transitive packages listed in "Known transitive exceptions".
   Anything else that matches must be checked before the change is accepted.

Keep the existing section numbers (§5 and §6 stay the same) by making the new part a
subsection of §4 (`### 4.1 Known transitive exceptions`).

## Checks

- Docs only, so no `flutter analyze` or `flutter test` run is needed.
- Re-read the edited file to check headings and table formatting.
- Confirm the doc uses relative paths only and contains no local system details.

## After the change

Write a change log in `change_log/` that references this plan, and set this plan's status
to `completed`.
