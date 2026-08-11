# Implementation Plan - Fix ARB Missing Metadata Diagnostics

**Status:** Proposed

## Problem / Requirement
The IDE linter flagged 180+ diagnostic `info` messages in `lib/l10n/app_en.arb` stating:
`The message with key "<key>" does not have metadata defined.`

In Flutter's localization system, `app_en.arb` is designated as the `template-arb-file`. The ARB specification and Flutter l10n guidelines recommend defining `@<key>` metadata objects (with a `"description"` attribute) for every message key in template ARB files. Adding these metadata definitions removes all linter info warnings and provides clear context for localization translators.

## Proposed Files to Change

### Modified Files
- `lib/l10n/app_en.arb`: Add `@<key>` metadata objects containing `"description"` attributes for all localized message keys that currently lack metadata.

## Detailed Approach
Each key without metadata in `lib/l10n/app_en.arb` will receive a corresponding `@<key>` metadata object immediately following its key-value definition.

For example:
```json
  "dailyList": "My ToDos",
  "@dailyList": { "description": "Title for daily todo list screen." },
```

All 180+ keys identified in `@[current_problems]` will be updated with concise, descriptive metadata objects.

## Verification Plan

### Automated Verification
1. `dart run build_runner build --delete-conflicting-outputs` / `flutter gen-l10n` (via `flutter analyze`).
2. `flutter analyze` — verify zero warnings or errors.
3. `flutter test` — ensure all unit and widget tests pass.
