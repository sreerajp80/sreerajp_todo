# Document the web-only `http` transitive dependency

Implements plan: `plans/20261011_195301_document_http_transitive_dependency.md`

## Why

The offline audit found `http` in the dependency tree. It is a transitive dependency of
`image_cropper` (through `image_cropper_platform_interface` 8.0.0). The package uses it only
in its web `CroppedFile` file, which a conditional export picks only on web. Android and
desktop builds use the `dart:io` version, which has no network code. The app does not target
web, so `http` is never compiled in. The docs said `http` was banned even as a transitive
dependency, so this needed to be written down.

## What changed

Docs only. No code, `pubspec.yaml` or `pubspec.lock` changes.

`docs/dependencies.md`:

- **§4 Prohibited Dependency Categories:** the intro now says the only allowed exceptions
  are the transitive packages in §4.1. Any new exception needs the same check.
- **New §4.1 Known transitive exceptions:** a table with one entry for `http`. It names the
  package that brings it in and explains why it is never compiled in. It also says when to
  check again: on an `image_cropper` upgrade, or if a web target is added.
- **§6 Dependency Audit Command:** "zero matches" now allows the §4.1 exceptions. Any other
  match must be checked.

## Checks

- Re-read the edited sections. Headings and the table are correct, and section numbers 5
  and 6 did not change.
- No `flutter analyze` or `flutter test` run was needed (docs only).
- The edited files use relative paths only and contain no local system details.
