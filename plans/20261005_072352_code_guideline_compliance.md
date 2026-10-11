# Plan — Make the code follow the guidelines strictly

**Status:** completed

**Date:** 2026-10-05

---

## 1. Background

Two earlier plans today fixed the `docs/` folder and the folder layout
(`plans/20261005_065725_docs_guideline_compliance.md`,
`plans/20261005_070445_project_structure_compliance.md`). This plan covers the **code itself**.

I checked the code against the hard rules in `CLAUDE.md` and against
`docs/guidelines/flutter_project_engineering_standard.md` (called "the standard" below).

### 1.1 Already compliant (no change needed)

- `flutter analyze`: 0 issues. `dart format`: 0 files changed.
- No `NetworkImage`, no `print()`, no network packages. Sockets only in `P2pWifiSyncService`.
- `core/` imports Flutter only in `config_service.dart` (the allowed exception).
- `presentation/` never imports `data/`.
- ARB key parity: 1,198 keys in each of `en`, `ml`, `sa`, with `@key` descriptions.
- NFC normalization is done on every text write (in the repositories or the DAOs).
- Day lock, terminal-status lock and one-open-segment checks are in the repositories.
- `compute()` is used only for OCR image work, never for `sqflite` queries (allowed).
- Every DAO has a test, except one (see 2.8).

---

## 2. What is wrong (audit result)

### 2.1 `domain/` depends on `data/` (wrong direction)

`CLAUDE.md`: "`domain/` depends on `core/` only and never imports … data classes", and
"presentation → application → domain ← data".

Today the real model classes live in `lib/data/models/`. 32 files in `domain/`,
`application/` and `presentation/` import them. Some files in `lib/domain/entities/` are only
one-line `export`s of `data/models/` files. So `domain/` points at `data/`, which is backwards.

### 2.2 `domain/` imports Flutter

9 files in `lib/domain/` import `package:flutter/foundation.dart`, only for `@immutable`,
`kDebugMode` and `debugPrint`. `domain/` must be pure Dart.

### 2.3 `debugPrint` in committed code; no logger

Standard §14.2–§14.3: a named logger (`AppLogger`) with levels is required. `debugPrint` "MUST
NOT be committed". Log the operation and error type, not raw exception text (it may hold user
data such as a task title).

Today: 53 `debugPrint` calls in 19 files. Some print `$e` (raw exception text). There is no
`AppLogger`.

### 2.4 No global error handlers

Standard §11.1: `main()` MUST set `FlutterError.onError`, `PlatformDispatcher.instance.onError`
and, in release builds, `ErrorWidget.builder` → a safe fallback widget. `lib/main.dart` sets none
of these.

### 2.5 Hard-coded English text in the UI (Hard Rule 10)

About 400 English strings are written directly in widgets instead of coming from the ARB files.

| Area | Files | Approx. strings |
| --- | --- | --- |
| Features screen | `screens/features/features_screen.dart` | 127 |
| Help screens | `screens/help/*.dart` (11 files) | 177 |
| P2P Wi-Fi sync screen | `screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart` | 20 |
| Other widgets | `air_qr_share_dialog`, `air_qr_preview_sheet`, `recall_confidence_dialog`, `backup_health_dashboard`, `task_history_screen`, `ocr_scan_screen`, `markdown_import_dialog`, `pending_alert_watcher`, `mastery_deck_detail_screen`, `data_handoff_screen`, `daily_progress_header`, `backup_screen`, `daily_list_screen` | ~45 |

Some of these also show plain counts like `'${n} tasks'`, which need ICU plural forms.

### 2.6 Raw exception text shown to the user

Standard §11.2: user messages "MUST NOT contain stack traces, internal exception class names".
These places show `e.toString()` in a SnackBar or on screen:
`evening_reflection_modal.dart`, `pending_todos_alert_sheet.dart`, `data_handoff_screen.dart`
(3), `markdown_import_dialog.dart`, `ocr_scan_screen.dart` (3), `p2p_wifi_sync_screen.dart` (2),
`time_segments_screen.dart` (2), `daily_list_screen.dart`.

A mapper already exists: `lib/presentation/shared/error_message_mapper.dart`.

### 2.7 Untyped exceptions

Standard §11.3: services MUST throw typed domain exceptions, under a `sealed` base class.

- `StateError('Todo not found …')` in `complete_srs_todo.dart`, `mark_todo_completed.dart`,
  `mark_todo_dropped.dart` (a `TodoNotFoundException` already exists).
- `ArgumentError` in `time_segment_repository_impl.dart` (2) and `crypto_utils.dart`.
- The classes in `lib/core/errors/exceptions.dart` implement `Exception` directly; there is no
  sealed base class.

### 2.8 Smaller items

| # | Problem | Rule |
| --- | --- | --- |
| a | `ocr_scan_screen.dart` uses `Navigator.of(context).push(MaterialPageRoute(...))` twice. | `CLAUDE.md` Never #9 — use `go_router` |
| b | `StatisticsNotifier` takes `StatisticsQueryService` (a DAO-layer class) directly. | `CLAUDE.md` Never #2 — no DAOs in Notifiers |
| c | `lib/data/dao/todo_search_index_dao.dart` has no unit test. | Testing rules — every DAO method has a test |
| d | `cupertino_icons` is in `pubspec.yaml` but not used anywhere, and is not on the approved list. | Dependency constraints |

---

## 3. The fix

### 3.1 Move the models into `domain/` (fixes 2.1)

- `git mv` every file in `lib/data/models/*.dart` (not the generated `*.freezed.dart`) to
  `lib/domain/entities/`, replacing the one-line `export` files there.
- Also move `lib/data/backup/backup_file_info.dart` the same way.
- Delete the old generated `*.freezed.dart` files, then run
  `dart run build_runner build --delete-conflicting-outputs` to make new ones. (Generated files
  are never edited by hand.)
- Update all imports in `lib/`, `test/` and `integration_test/` to
  `package:sreerajp_todo/domain/entities/...`.
- `toMap()` / `fromMap()` stay on the models. They are plain Dart maps with no `sqflite` import,
  and the standard §4.3 allows one model for storage and UI in a simple app.
- Afterwards: `grep "sreerajp_todo/data/" lib/domain` must find nothing.

### 3.2 Make `domain/` pure Dart (fixes 2.2)

- Remove `import 'package:flutter/foundation.dart'` from the 9 files.
- Drop `@immutable` (same as was done for `SpeechEvent`; the classes stay immutable with
  `const` constructors and `final` fields). Freezed models are not affected.
- Replace `debugPrint` with `AppLogger` (3.3).
- Afterwards: `grep "package:flutter" lib/domain` must find nothing.

### 3.3 Add `AppLogger` and remove every `debugPrint` (fixes 2.3)

- New file `lib/core/logging/app_logger.dart`, pure Dart:
  - levels `trace`, `debug`, `info`, `warning`, `error`, `fatal` (standard §14.1);
  - writes through `dart:developer` `log()` — **no new package**;
  - `trace` and `debug` are silent in release builds (checked with
    `bool.fromEnvironment('dart.vm.product')`, which is pure Dart);
  - `error` / `fatal` take `error` and `stackTrace`.
  - Console only. Writing logs to a file (§14.4) is optional and is not added; this is noted in
    `docs/architecture.md`.
- Replace all 53 `debugPrint` calls. Messages log the operation name and the error **type**
  (`e.runtimeType`), never raw `$e` text that may hold a task title.
- New test `test/core/logging/app_logger_test.dart`.

### 3.4 Global error handlers (fixes 2.4)

- In `lib/main.dart`, before `runApp`: set `FlutterError.onError` (logs with `AppLogger.error`;
  dumps to console in debug), `PlatformDispatcher.instance.onError` (logs, returns `true`), and in
  release `ErrorWidget.builder = (_) => const SafeErrorFallback()`.
- New widget `lib/presentation/shared/widgets/safe_error_fallback.dart`: a simple neutral box with
  a warning icon and no text (it has no `BuildContext` for localization, so it shows no words, and
  no exception detail).

### 3.5 Move all hard-coded UI text into the ARB files (fixes 2.5)

- Add one ARB key per string to `app_en.arb`, `app_ml.arb` and `app_sa.arb`, each with an `@key`
  description. Counts use ICU `{count, plural, …}`.
- Malayalam: natural modern Malayalam. Sanskrit: classical Sanskrit only, following
  `docs/guidelines/language_packs/sanskrit_malayalam.md` (no Hindi words).
- Replace each literal with `context.l10n.<key>`. Where text is built outside a widget
  (for example `_peerStatusMessage` in the P2P screen, or the notification text in
  `pending_alert_watcher.dart`), store a small enum/state value and build the text in `build()`.
- Run `flutter gen-l10n`. The existing `translation_parity_test` and `sanskrit_quality_test`
  must still pass.
- Brand-like names stay as they are (font names such as "Noto Sans Malayalam").

### 3.6 Friendly error messages (fixes 2.6)

- Replace every `e.toString()` / `$e` shown to the user with `mapErrorToMessage(context.l10n, e)`.
- Where an ARB message today takes the raw error as a placeholder (for example
  `dataHandoffExportFailed(e.toString())`), pass the mapped message instead.
- Extend `mapErrorToMessage` for any exception type that is not yet covered, with a localized
  generic fallback.

### 3.7 Typed exceptions (fixes 2.7)

- In `lib/core/errors/exceptions.dart`: add `sealed class AppException implements Exception`
  and make every existing exception class extend it (all are in the same file, so `sealed`
  works). Add `ValidationException` for bad input.
- `StateError('Todo not found …')` → `TodoNotFoundException`.
- `ArgumentError` in `time_segment_repository_impl.dart` and `crypto_utils.dart` →
  `ValidationException`.
- `ArgumentError` in `TodoStatus.fromValue` and the `StateError`s in `win32_dpapi.dart` stay:
  they mark programmer errors / corrupt data, not user-facing failures.
- Update the tests that expect the old error types.

### 3.8 Smaller items (fixes 2.8)

- **a.** Add a route `AppRoutes.ocrEnhance` (`/ocr/enhance`) in `app_routes.dart` and `app.dart`
  that receives the image path through `extra`. Replace both `Navigator.push` calls with
  `context.push<String>(AppRoutes.ocrEnhance, extra: path)`.
- **b.** Add `lib/domain/repositories/statistics_repository.dart` (interface) and
  `lib/data/repositories/statistics_repository_impl.dart` (wraps `StatisticsQueryService`).
  `StatisticsNotifier` takes the repository. `providers.dart` wires it.
- **c.** Add `test/data/dao/todo_search_index_dao_test.dart` (in-memory SQLite) covering each
  public method.
- **d.** Remove `cupertino_icons` from `pubspec.yaml`, run `flutter pub get`.

### 3.9 Docs

- `docs/architecture.md`: note that models live in `domain/entities/`, describe `AppLogger`
  and the global error handlers.
- `docs/project_structure.md`: remove `data/models/`, add `core/logging/`.
- `docs/dependencies.md`: remove `cupertino_icons`.
- `CLAUDE.md` / `AGENTS.md` (kept in sync): add "use `AppLogger`, never `debugPrint`" to the
  Never list.

### 3.10 Verify

- `dart format lib/ test/ integration_test/`
- `flutter analyze` — 0 issues.
- `flutter test` — all pass.
- Checks that must return nothing:
  - `grep -rn "debugPrint" lib`
  - `grep -rn "sreerajp_todo/data/" lib/domain lib/presentation`
  - `grep -rn "package:flutter" lib/domain`
  - `grep -rn "Navigator.of(context).push\|Navigator.push" lib`
- Re-run the hard-coded-string scan on `lib/presentation`.

---

## 4. Files to change

**Moved (`git mv`):** all 14 hand-written files in `lib/data/models/` and
`lib/data/backup/backup_file_info.dart` → `lib/domain/entities/`.

**New:**

- `lib/core/logging/app_logger.dart`
- `lib/presentation/shared/widgets/safe_error_fallback.dart`
- `lib/domain/repositories/statistics_repository.dart`
- `lib/data/repositories/statistics_repository_impl.dart`
- `test/core/logging/app_logger_test.dart`
- `test/data/dao/todo_search_index_dao_test.dart`

**Regenerated (by `build_runner` / `gen-l10n`, never by hand):** the `*.freezed.dart` files of
the moved models; `lib/l10n/app_localizations*.dart`.

**Edited:**

- `lib/main.dart`, `lib/app.dart`, `lib/core/constants/app_routes.dart`
- `lib/core/errors/exceptions.dart`, `lib/core/security/crypto_utils.dart`
- `lib/application/providers.dart`, `lib/application/statistics_notifier.dart`,
  `lib/application/recurrence_rules_notifier.dart`
- The 19 files with `debugPrint` (in `application/`, `core/config/`, `data/platform/`,
  `data/services/`, `domain/`)
- The 9 `domain/` files that import Flutter
- `lib/domain/usecases/complete_srs_todo.dart`, `mark_todo_completed.dart`,
  `mark_todo_dropped.dart`, `lib/data/repositories/time_segment_repository_impl.dart`
- `lib/presentation/shared/error_message_mapper.dart`
- About 30 presentation files listed in 2.5 and 2.6
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`
- About 60 files in `lib/`, `test/`, `integration_test/` whose imports point at the moved models
- `pubspec.yaml`
- `docs/architecture.md`, `docs/project_structure.md`, `docs/dependencies.md`, `CLAUDE.md`,
  `AGENTS.md`

**Change log:** `change_log/<timestamp>_code_guideline_compliance.md`

---

## 5. Risks

- **Size.** This is a big change. Steps 3.1–3.4 and 3.6–3.8 are mostly mechanical; the analyzer
  and the 833 tests will catch broken imports or behaviour.
- **Translations (3.5).** About 400 new strings need Malayalam and Sanskrit text. I will write
  them carefully, but you should review the Sanskrit and Malayalam wording, especially the long
  Help and Features text.
- **Behaviour.** Users will see friendlier error messages instead of raw error text. Nothing
  else visible changes, apart from the new text now following the chosen app language.
