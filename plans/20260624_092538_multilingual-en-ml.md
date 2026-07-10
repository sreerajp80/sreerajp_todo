# Plan: Multilingual support (English + Malayalam), device-language driven

**Date:** 2026-06-24
**Author:** Claude (Opus 4.8)
**Status:** AWAITING APPROVAL

---

## 1. What the user wants

- Add multilingual support to **SreerajP ToDo**.
- Two languages **right now**: **English (`en`)** and **Malayalam (`ml`)**.
- Language is selected **automatically from the device language** — no in-app language
  switcher. If the device is set to Malayalam, the app shows Malayalam; otherwise it
  falls back to English. (English is the fallback for every unsupported locale.)

## 2. The issue / current state

- All user-visible text lives in `lib/core/constants/app_strings.dart` as a single
  `AppStrings` class of **static `const` strings** + a few interpolation helper methods
  and nested helper classes (`_BackupStrings`, `_SettingsStrings`, `_PermissionsStrings`,
  `_AboutStrings`, `_StatisticsStrings`, `_ErrorStrings`).
- These are referenced in **469 places across 39 files** (37 `lib/` + tests).
- There is **no localization infrastructure**: `MaterialApp.router` in `lib/app.dart` sets
  no `localizationsDelegates`, no `supportedLocales`, no `locale`.
- `flutter_localizations` and `intl: ^0.20.2` are already in `pubspec.yaml` — good, no new
  package needed (stays fully offline; no networking deps added).
- Because the strings are `static const`, they cannot vary by locale on their own. We need a
  real localization layer resolved from `BuildContext`.
- A few usages have **no `BuildContext`** and need special handling:
  - `lib/core/errors/error_message_mapper.dart` — pure function mapping exceptions → text.
  - `lib/application/statistics_notifier.dart` — stores an error message string in state
    (3 sites, all `AppStrings.errors.generic`).

## 3. Chosen approach (recommended): Flutter `gen_l10n` (ARB files)

Use Flutter's first-party, offline localization codegen (`gen_l10n`) — the idiomatic
approach that the framework's locale resolution (device-language → supported → fallback)
is built for.

### Mechanics
- Add `flutter: generate: true` to `pubspec.yaml` and an `l10n.yaml` config at project root.
- Create ARB files under `lib/l10n/`:
  - `app_en.arb` — every existing string, keyed by the same names used today
    (e.g. `dailyList`, `statusPending`, `errorDayLocked`, `selectedCount`, …).
  - `app_ml.arb` — Malayalam translations of the same keys.
- Codegen produces `AppLocalizations` (synchronous, context-based getters/methods,
  including the parameterised ones like `selectedCount(int)`,
  `noSearchResultsForQuery(String)`, `pageOf(int,int)`, `segmentSemantics({...})`).
- Add a tiny extension `context.l10n` (=> `AppLocalizations.of(context)!`) so call sites stay
  terse: `AppStrings.dailyList` → `context.l10n.dailyList`.
- Wire up `MaterialApp.router` in `lib/app.dart`:
  - `localizationsDelegates: AppLocalizations.localizationsDelegates`
  - `supportedLocales: AppLocalizations.supportedLocales` (`en`, `ml`)
  - **No explicit `locale`** → Flutter uses the device locale automatically, falling back to
    `en` (first supported / `localeResolutionCallback` default) when the device locale is
    not `ml`. This satisfies the "based on device language" requirement with zero extra code.
  - `title:` → keep `AppStrings.appName` (app name "SreerajP ToDo" is a proper noun, not
    translated). Optionally localize via `onGenerateTitle` later — out of scope here.

### Handling the non-`BuildContext` sites
- `error_message_mapper.dart`: change `mapErrorToMessage(Object error)` →
  `mapErrorToMessage(AppLocalizations l10n, Object error)` and pass `context.l10n` from the
  widgets that call it. (Callers are all in the presentation layer with context.)
- `statistics_notifier.dart`: it currently stores a localized string in `state.error`.
  Cleanest fix that respects "no business logic decides display text": store an error
  **marker** and let the widget localize. To keep this change contained, I will instead
  store a neutral sentinel and have the statistics screen map a non-null `error` to
  `context.l10n.errorGeneric` at display time (the notifier only signals *that* an error
  occurred, not its wording). I will confirm exact call sites during implementation.

### `app.dart` title attribute
- `MaterialApp.router(title: ...)` runs without a localized context; keep the untranslated
  app name there.

## 4. Files to be changed / created

**New files**
- `l10n.yaml` (project root) — gen_l10n config (arb dir `lib/l10n`, template `app_en.arb`,
  output class `AppLocalizations`).
- `lib/l10n/app_en.arb` — English source strings (all ~250 entries + metadata/placeholders).
- `lib/l10n/app_ml.arb` — Malayalam translations.
- `lib/core/extensions/localization_extensions.dart` — `context.l10n` getter.
- (Generated, not committed manually) `AppLocalizations` under `.dart_tool/flutter_gen` or
  configured `synthetic-package: false` output dir — decided in implementation.

**Edited files**
- `pubspec.yaml` — add `flutter: generate: true`.
- `lib/app.dart` — add `localizationsDelegates`, `supportedLocales`; import gen output.
- `lib/core/errors/error_message_mapper.dart` — take `AppLocalizations` param.
- `lib/application/statistics_notifier.dart` — stop storing localized text (signal-only).
- **All presentation-layer files using `AppStrings`** (the 30-ish widget/screen files from
  the grep) — swap `AppStrings.x` → `context.l10n.x`. Mechanical but broad; will break
  `const` on some `Text(...)` widgets (those `const` qualifiers get removed). `flutter
  analyze` will be run to catch every residual.
- **Tests** that reference `AppStrings` (`test/presentation/*`, `integration_test/app_test.dart`):
  pump widgets with `localizationsDelegates`/`supportedLocales`, and either keep asserting on
  English text (default test locale = `en`) or assert via `AppLocalizations`. Test helper to
  wrap `MaterialApp`/`pumpWidget` with the delegates will be added/updated.

**Removed**
- `lib/core/constants/app_strings.dart` — eventually deleted once all call sites migrate.
  (May keep temporarily during migration, removed before completion. CLAUDE.md's "no
  hardcoded strings / strings live in app_strings.dart" rule is effectively superseded by
  the ARB files becoming the single source of strings — I will note this in the change log;
  if you want, I can keep `app_strings.dart` only for non-translated constants like
  `appName`, `manualSegmentShort`, `emptyValue`.)

## 5. Offline / project-rule compliance

- **No new packages.** `flutter_localizations` + `intl` are already present and fully offline.
- No networking, analytics, or cloud deps introduced. Dep-audit will be run
  (`flutter pub deps --json | Select-String "http|socket|firebase|..."` → expect 0).
- NFC normalization, day-lock, status-lock, DB layering rules are untouched (this is a
  pure presentation/i18n change).
- All shell examples in the change log will use PowerShell.

## 6. Malayalam translation quality — please note

I will provide Malayalam translations for all keys, but **machine/AI-generated Malayalam
should be reviewed by a native speaker** (you) before release. I will keep the ARB keys and
English source authoritative, and flag any strings where Malayalam wording is uncertain
(especially terse UI labels, abbreviations like Mon/Tue, and the "Made with ❤ in India"
line). Proper nouns (app name, author name, "Claude", "GPT") stay untranslated.

## 7. Verification steps (after approval + implementation)

```powershell
# 1. Generate localizations + freezed (gen_l10n runs as part of build)
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs

# 2. Static analysis — must be clean (catches every missed AppStrings reference)
flutter analyze

# 3. Run the full test suite
flutter test

# 4. Offline dependency audit — expect zero matches
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics"

# 5. Manual smoke test: launch with device/emulator set to Malayalam, then to English,
#    confirm the UI switches and unsupported locales fall back to English.
```

## 8. Open decision for you

This is a large, broad-but-mechanical refactor (469 call sites). Before I touch any code I
want your decision on scope/approach (see the question I will ask alongside this plan).
Once you approve, I will implement in this order: ARB files → gen config + app.dart wiring →
`context.l10n` extension → migrate call sites by layer → fix non-context sites → tests →
analyze/test/audit → change log.
