# Phase 1 — Project Setup & Foundation

## Objective
Create a runnable Flutter skeleton with navigation, theming, folder structure, and offline enforcement tooling. The app must run on Android and Windows desktop with zero internet dependency.

## Context
- **App name:** SreerajP ToDo
- **Organisation:** `in.sreerajp`
- **Project root:** `L:\Android\sreerajp_todo`
- **Flutter SDK:** 3.41.4 stable
- **Platforms (MVP):** Android, Windows desktop
- **This is a fully offline app** — no internet access, ever. No networking packages, no cloud services, no analytics, no telemetry.

## Pre-Requisites
- Read `CLAUDE.md` in the project root — it is the single source of truth.
- Read `flutter_todo_app_plan.md` for full architectural context.
- Read `docs/architecture.md` — layer boundaries, folder structure, ownership rules.
- Read `docs/flutter_project_engineering_standard.md` — coding standards (§8), lint config (§8.1), structure rules (§3), AI assistant instructions (§13), Definition of Done (§14).

## Tasks

### 1. Scaffold the Flutter Project
```powershell
cd L:\Android\sreerajp_todo
flutter create --org in.sreerajp --platforms android,windows .
```

### 2. Set Up Folder Structure
Create the following directory tree under `lib/`:
```
lib/
├── main.dart
├── app.dart                         # MaterialApp + GoRouter + ThemeData
├── core/
│   ├── constants/
│   │   ├── app_constants.dart       # DB version, limits, durations
│   │   ├── app_strings.dart         # ALL user-visible strings
│   │   └── app_routes.dart          # Route path constants
│   ├── errors/
│   │   ├── exceptions.dart          # DayLockedException, CompletedLockException, etc.
│   │   └── failures.dart
│   └── utils/
│       ├── date_utils.dart          # isToday(), isPastDate(), todayAsIso(), formatDate()
│       ├── duration_utils.dart      # formatDuration() → HH:MM:SS
│       └── unicode_utils.dart       # nfcNormalize(), detectTextDirection()
├── data/
│   ├── database/
│   │   ├── database_service.dart
│   │   └── migrations/
│   │       └── migration_v1.dart
│   ├── dao/
│   ├── repositories/
│   ├── backup/
│   └── models/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── application/
│   └── providers.dart
└── presentation/
    ├── screens/
    │   ├── daily_list/
    │   │   ├── daily_list_screen.dart
    │   │   └── widgets/
    │   ├── create_edit_todo/
    │   │   ├── create_edit_todo_screen.dart
    │   │   └── widgets/
    │   ├── time_segments/
    │   │   ├── time_segments_screen.dart
    │   │   └── widgets/
    │   ├── copy_todos/
    │   │   └── copy_todos_screen.dart
    │   ├── search_results/
    │   │   ├── search_results_screen.dart
    │   │   └── widgets/
    │   ├── recurring_tasks/
    │   │   ├── recurring_tasks_screen.dart
    │   │   ├── recurrence_editor_screen.dart
    │   │   └── widgets/
    │   ├── backup/
    │   │   ├── backup_screen.dart
    │   │   └── widgets/
    │   └── statistics/
    │       ├── statistics_screen.dart
    │       └── widgets/
    └── shared/
        ├── widgets/
        │   ├── status_badge.dart
        │   ├── locked_overlay.dart
        │   ├── confirm_dialog.dart
        │   └── undo_status_snackbar.dart
        └── theme/
            └── app_theme.dart
```

Also create `test/`, `integration_test/`, and `assets/fonts/` directories.

### 3. Add Dependencies to `pubspec.yaml`

**dependencies:**
- `flutter` (sdk)
- `flutter_localizations` (sdk)
- `sqflite_sqlcipher: ^3.1.0` (replaces `sqflite` — AES-256 encrypted SQLite for mobile)
- `sqflite_common_ffi: ^2.3.4` (SQLite FFI for desktop)
- `path: ^1.9.0`
- `path_provider: ^2.1.4`
- `flutter_riverpod: ^2.6.1`
- `go_router: ^14.8.1`
- `intl: ^0.20.2`
- `fl_chart: ^0.70.2`
- `table_calendar: ^3.2.0`
- `uuid: ^4.5.1`
- `freezed_annotation: ^2.4.4`
- `json_annotation: ^4.9.0`
- `unorm_dart: ^2.0.0`
- `file_picker: ^8.0.0`
- `rrule: ^0.2.16` (iCalendar RRULE parsing — audit transitive deps first)

**dev_dependencies:**
- `flutter_test` (sdk)
- `build_runner: ^2.4.14`
- `freezed: ^2.5.7`
- `json_serializable: ^6.9.0`
- `mocktail: ^1.0.4`
- `flutter_native_splash: ^2.4.0`

Run `flutter pub get` then run the **offline dependency audit**:
```powershell
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio|chopper|retrofit|amplitude|mixpanel|datadog"
```
**Zero matches required.** If any match, identify the chain and remove/replace the offending package.

### 4. Verify AndroidManifest.xml
```powershell
Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
```
Zero matches required. If `INTERNET` permission exists (Flutter adds it by default), **remove it**.

### 5. Configure `main.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const ProviderScope(child: TodoApp()));
}
```

Platform detection for FFI is done **only** in `main.dart`. No other file checks the platform for DB init.

### 6. Configure `app.dart`
- Create `MaterialApp.router` with `GoRouter`.
- Define all routes with **placeholder screens** (a `Scaffold` with the route name as title).
- Route table:

| Route | Screen | Notes |
|-------|--------|-------|
| `/` | — | Redirects to `/day/<today>` |
| `/day/:date` | `DailyListScreen` | |
| `/todo/new` | `CreateEditTodoScreen` | Query param: `?date=YYYY-MM-DD` |
| `/todo/:id` | `CreateEditTodoScreen` | Edit mode |
| `/todo/:id/segments` | `TimeSegmentsScreen` | |
| `/copy` | `CopyTodosScreen` | Query param: `?from=YYYY-MM-DD` |
| `/search` | `SearchResultsScreen` | Query param: `?q=<term>` |
| `/backup` | `BackupScreen` | |
| `/recurring` | `RecurringTasksScreen` | |
| `/recurring/new` | `RecurrenceEditorScreen` | |
| `/recurring/:id` | `RecurrenceEditorScreen` | |
| `/statistics` | `StatisticsScreen` | |

- Define route path constants in `lib/core/constants/app_routes.dart`.
- Use `context.go()`, `context.push()`, `context.pop()` — **never** `Navigator.push()`.

### 7. Implement Theme (`lib/presentation/shared/theme/app_theme.dart`)
- Light and dark `ThemeData` with a consistent colour palette.
- Unicode-compatible font: use system default or bundle Noto Sans in `assets/fonts/`.
- Text fields: `TextInputType.multiline`, `TextCapitalization.none` (don't interfere with non-Latin scripts).
- **All fonts must be bundled** — no Google Fonts network loader, no `Image.network()`.

### 8. Implement Core Utilities (stub implementations OK for Phase 1)
- `lib/core/constants/app_strings.dart` — define initial string constants (app name, placeholder text).
- `lib/core/constants/app_constants.dart` — define `kDatabaseVersion = 1`, `kUndoTimeoutSeconds = 5`, `kUndoStackSize = 5`, etc.
- `lib/core/constants/app_routes.dart` — route path constants.
- `lib/core/errors/exceptions.dart` — define all exception classes:
  - `DayLockedException`
  - `CompletedLockException`
  - `DuplicateTitleException`
  - `SegmentAlreadyRunningException`
  - `TodoNotFoundException`
  - `BackupVersionTooNewException`
  - `BackupCorruptedException`
- `lib/core/utils/date_utils.dart` — `isToday()`, `isPastDate()`, `todayAsIso()`, `formatDate()`.
- `lib/core/utils/duration_utils.dart` — `formatDuration(int seconds)` → `HH:MM:SS`.
- `lib/core/utils/unicode_utils.dart` — `nfcNormalize()` (using `unorm_dart`), `detectTextDirection()`.

### 9. Set Up Pre-Commit Git Hook
Create `.githooks/pre-commit` that runs:
1. `flutter analyze --no-fatal-infos`
2. Offline dep audit (grep for networking packages in `flutter pub deps`)
3. Manifest check (grep for INTERNET/NETWORK_STATE in AndroidManifest.xml)
4. `flutter test`

Configure: `git config core.hooksPath .githooks`

### 10. Verify Hot Reload
- Run on Android emulator: `flutter run -d <emulator-id>`
- Run on Windows: `flutter run -d windows`
- Verify hot reload works on both.

## Constraints (from CLAUDE.md)
- `core/` has **zero** Flutter framework imports — pure Dart only.
- `domain/` has **zero** `sqflite` imports — depends only on `core/`.
- All user-visible strings in `app_strings.dart`.
- No hardcoded strings in widget files.
- No `Navigator.push()` — use `go_router` only.
- No networking packages of any kind.
- PowerShell syntax for all shell commands.

## Deliverables
- [ ] Running app on Android emulator and Windows showing placeholder screens
- [ ] All routes navigable (including `/search`, `/backup`, `/recurring`)
- [ ] Offline dependency audit passes with zero networking matches
- [ ] `AndroidManifest.xml` confirmed to have no `INTERNET` or network permissions
- [ ] Pre-commit hook installed and functional
- [ ] Core utilities implemented and tested
- [ ] Light/dark theme switching works
