# Change log — Code follows the guidelines strictly

**Date:** 2026-10-05

**Plan:** [plans/20261005_072352_code_guideline_compliance.md](../plans/20261005_072352_code_guideline_compliance.md)

---

## 1. Summary

The code now follows the hard rules in `CLAUDE.md` and the engineering standard
(`docs/guidelines/flutter_project_engineering_standard.md`) on layers, logging, error
handling, navigation and localization. Users see two visible changes:

- All screens, including Help and Features, now follow the chosen app language.
- Error messages are short and friendly. Raw error text is no longer shown.

---

## 2. Layers

### 2.1 Models moved into `domain/` (plan 3.1)

- All hand-written models moved from `lib/data/models/` to `lib/domain/entities/` with
  `git mv`. This replaced the one-line `export` files that were there.
  `lib/data/backup/backup_file_info.dart` moved there too.
- `lib/data/models/` no longer exists. Imports in `lib/`, `test/` and `integration_test/`
  (about 120 files) now point to `domain/entities/`.
- **Different from the plan:** `build_runner` crashes on this code base. The locked `analyzer`
  package is older than the Dart language version and cannot read the dot-shorthand syntax
  the code already uses. The freezed output depends only on the file name (`part of
  'todo_entity.dart'`), not on the folder. So the committed `*.freezed.dart` files were
  restored unchanged from git next to their moved sources, not regenerated. No generated
  file was edited by hand. The model sources are unchanged apart from imports (checked by
  diff). This is now listed as a risk in `docs/architecture.md` §16.

### 2.2 `domain/` is pure Dart (plan 3.2)

- The `package:flutter/foundation.dart` import was removed from 9 `domain/` files.
  `@immutable` was dropped (the classes keep `const` constructors and `final` fields).
  `Uint8List` now comes from `dart:typed_data`.
- `grep "package:flutter" lib/domain` and `grep "sreerajp_todo/data/" lib/domain` now find
  nothing.

### 2.3 Statistics repository (plan 3.8b)

- New `lib/domain/repositories/statistics_repository.dart` (interface) and
  `lib/data/repositories/statistics_repository_impl.dart` (wraps `StatisticsQueryService`).
- `StatisticsNotifier` now takes the repository, not the DAO-layer class.
  `providers.dart` wires the new `statisticsRepositoryProvider`. Three tests now mock the
  repository.

---

## 3. Logging and error handling

### 3.1 `AppLogger` (plan 3.3)

- New `lib/core/logging/app_logger.dart`. It is pure Dart and adds no new package. It has
  six levels, from `trace` to `fatal`, and writes to the console through `dart:developer`.
  `trace` and `debug` are silent in release builds. It records only the error **type**,
  never the error message.
- All 53 `debugPrint` calls in 19 files now use `AppLogger`:
  - Channel failures that have a fallback → `warning`.
  - "Host does not handle" → `debug`.
  - Failures that break a user action → `error`, with the stack trace.
- Messages no longer include raw `$e` text.
- New test: `test/core/logging/app_logger_test.dart`.

### 3.2 Global error handlers (plan 3.4)

- `lib/main.dart` now sets `FlutterError.onError` and `PlatformDispatcher.instance.onError`.
  Both log through `AppLogger`. In release builds `ErrorWidget.builder` returns the new
  `SafeErrorFallback`, a neutral box with only an icon.
- New test: `test/presentation/shared/widgets/safe_error_fallback_test.dart`.

### 3.3 Typed exceptions (plan 3.7)

- `lib/core/errors/exceptions.dart` now has a `sealed class AppException`. All 14
  exception classes extend it. There is also a new `ValidationException`.
- `StateError('Todo not found')` → `TodoNotFoundException` (3 use cases).
- `ArgumentError` → `ValidationException` in `time_segment_repository_impl.dart` (2) and
  `crypto_utils.dart`. The backup screen now checks for `ValidationException`, and one test
  now expects it.

### 3.4 Friendly error messages (plan 3.6)

- `mapErrorToMessage` now uses an exhaustive `switch` over `AppException`, so a new
  exception type will not compile until it has a message. Any other error gets the generic
  message.
- Every place that showed `e.toString()` now shows the mapped message (14 places in 9
  files).
- New test: `test/presentation/shared/error_message_mapper_test.dart`.

---

## 4. Navigation (plan 3.8a)

- New route `AppRoutes.ocrEnhance` (`/ocr-scan/enhance`). The image path is passed as
  `extra`.
- `AppRoutes.ocrScanPath` gained `returnResult`. When it is set, the route adds
  `return=1` and the scanner gives the scanned title and description back to the caller.
- All three `Navigator.push(MaterialPageRoute(...))` calls now use `context.push`. Two are
  in `ocr_scan_screen.dart`; the third is in `create_edit_todo_screen.dart` and was found
  during the work.
- The OCR pages close themselves with `context.pop`.
- `Navigator.pop` calls that close dialogs and bottom sheets were left as they are. The
  rule only bans `Navigator.push`.

---

## 5. Localization (plan 3.5)

- 413 new ARB keys were added to `app_en.arb`, `app_ml.arb` and `app_sa.arb`, each with an
  `@key` description. Each file now has 1,611 keys. Counts use ICU plurals.
- Screens converted:
  - the Features screen;
  - all 11 Help screens;
  - the P2P Wi-Fi sync screen;
  - the AirQR share and preview dialogs;
  - the OCR scanner and its camera overlay;
  - the recall-confidence dialog, the backup health dashboard and the Markdown import
    dialog;
  - the day-list progress header, task history, Mastery Deck detail, carry-over settings,
    prerequisites, and the pending-tasks notification.
- The Features list was a `static const` list. It is now a function that takes
  `AppLocalizations`.
- The P2P status line now stores a small enum and builds its text in `build()`.
- Sanskrit text was checked against the Hindi-marker list from
  `docs/guidelines/language_packs/sanskrit_malayalam.md`. One trap was avoided: the word
  `सङ्ग्रहे` contains the marker letters `रहे`, so other Sanskrit words were used instead.
- **Text corrections:** three user-facing texts said the app has **no** INTERNET
  permission:
  - the privacy Help screen;
  - the FAQ;
  - the Features screen (in two places).

  This is no longer true, because `INTERNET` is declared for local Wi-Fi sync. The texts now
  say that INTERNET is the only network permission, used only for Wi-Fi sync with your own
  devices on the local network.
- **Hard Rule 9:** the AirQR "estimated scan time" now uses `formatDuration`
  (`~HH:MM:SS`) instead of `~2 m 5 s`.
- Literals that remain are allowed by the rules: log messages, platform error codes, RRULE
  tokens, file names, widget keys, and unit symbols (B, KB, MB, EV).

---

## 6. Other

- `pubspec.yaml`: `cupertino_icons` was removed. It was never used.
- New test: `test/data/dao/todo_search_index_dao_test.dart` (6 tests, in-memory SQLite).

---

## 7. Docs

- `docs/architecture.md`:
  - The tree and ownership table now show the models in `domain/entities/`,
    `core/logging/` and `SafeErrorFallback`.
  - The serialization notes were updated.
  - New "Logging", "Error boundaries" and "User-facing errors" notes in §14.
  - New `build_runner` risk in §16.
- `docs/project_structure.md`: the tree and layer notes were updated.
- `docs/security.md`: the logging controls now describe `AppLogger`.
- `docs/dependencies.md`: `cupertino_icons` was removed.
- `CLAUDE.md` and `AGENTS.md` (kept in sync): new Never rules 17 (no
  `print`/`debugPrint`, use `AppLogger`) and 18 (no raw exception text in the UI).

---

## 8. Verification

- `dart format lib/ test/ integration_test/`: no changes.
- `flutter analyze`: no issues.
- `flutter test`: all 846 tests passed (833 before, plus 13 new).
- These searches find nothing:
  - `debugPrint` in `lib/` (only the comment in `app_logger.dart` mentions it);
  - `sreerajp_todo/data/` in `lib/domain` or `lib/presentation`;
  - `package:flutter` in `lib/domain`;
  - `Navigator.push` or `MaterialPageRoute` in `lib/`.
- `package:flutter` in `lib/core` finds only `config_service.dart`, the allowed exception.

---

## 9. Follow-ups

- **Review the translations.** About 410 new Malayalam and Sanskrit strings were written
  for this change, mostly the long Help and Features text. A native reviewer should check
  them before release.
- **Fix `build_runner`.** Upgrade `build_runner`, `freezed` and `analyzer` in their own
  change, before any model changes.
- **Some Help text may not match the app.** For example, the Mastery Deck help describes
  "Easy, Good, Hard, Again" ratings and five mastery levels, but the recall dialog has
  Hard / Revision / Easy. These texts were translated as written. Only the false INTERNET
  claims were corrected.
- **Plain counts in two places.** `copy_todos_screen.dart` and `daily_progress_header.dart`
  still join a number with a localized word ("3 items to copy"). This text is localized,
  but it does not use ICU plurals.
