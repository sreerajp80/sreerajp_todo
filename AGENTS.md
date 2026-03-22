# AGENTS.md — Codex Rules For SreerajP ToDo

This file is the Codex-facing rule file for this repository.
It is generated from and must stay aligned with [CLAUDE.md](/l:/Android/sreerajp_todo/CLAUDE.md).
If guidance diverges, update both files in the same change.

## Project Identity

- App: `SreerajP ToDo`
- Type: personal offline-first daily todo and time-tracker
- Root: `L:\Android\sreerajp_todo`
- Flutter: `3.41.4 stable`
- Dart: `3.11.1`
- Platforms now: Android, Windows
- Platforms later: iOS, Linux, macOS
- Database: SQLite via `sqflite_sqlcipher` on mobile and `sqflite_common_ffi` with SQLCipher on desktop
- State management: Riverpod
- Navigation: `go_router`
- Backend/cloud/analytics: none
- Connectivity rule: fully offline, zero internet access required or permitted

## Non-Negotiable Rules

### 1. Fully Offline

- Never add networking, cloud, analytics, crash-reporting, telemetry, ad, or connectivity packages.
- Before adding any package, audit transitive dependencies for networking.
- `AndroidManifest.xml` must not contain `INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, or similar permissions.
- Windows builds must not register firewall rules or request network capabilities.
- All data stays on the local filesystem only.
- Runtime assets must be bundled. Use `AssetImage`, `Image.asset()`, or `Image.file()` only.
- Never use `NetworkImage` or `Image.network()`.
- Dependency audit command:

```powershell
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics"
```

### 2. Unicode First

- NFC-normalize every string written to the database with `unicodeUtils.nfcNormalize(value)`.
- Assume full Unicode input support at all times.
- Do not hardcode `TextDirection.ltr` on text inputs; use `unicodeUtils.detectTextDirection()`.
- Title uniqueness is enforced after NFC normalization.

### 3. Day Lock

- Any `TodoEntity` dated before today is read-only.
- Repository mutating methods must enforce this and throw `DayLockedException`.
- UI must also show the lock state, but UI-only enforcement is insufficient.

### 4. Terminal Status Lock

- `completed` and `dropped` todos cannot accept new time segments.
- Any open segment must be stopped when a todo becomes terminal.
- Repository throws `CompletedLockException` when violated.
- Start/stop controls must be hidden for completed and dropped todos.
- In statistics, completed time and dropped time are separate categories.
- Changing status to `dropped` or `ported` requires confirmation.

### 5. One Open Segment Per Todo

- At most one open `TimeSegmentEntity` per `todo_id`.
- Starting a second open segment must throw `SegmentAlreadyRunningException`.
- Multiple different todos may run timers simultaneously.
- On startup, `RepairOrphanedSegments` closes open segments on past-day todos with zero duration and `interrupted = 1`.
- `interrupted` and `manual` belong in the initial schema.

### 6. Title Uniqueness Per Day

- No two todos on the same date may share the same title after NFC normalization.
- Enforce this in SQLite, repository checks, and UI validation.
- Pass `excludeId` when editing.

### 7. No Direct DB Access From Widgets

- Widgets consume only providers from `lib/application/providers.dart`.
- Call flow:
  - `Widget -> Provider/Notifier -> UseCase -> Repository -> DAO -> sqflite` for multi-step work
  - `Widget -> Provider/Notifier -> Repository -> DAO -> sqflite` for simple CRUD
- Use-cases exist only for multi-step orchestration.

### 8. Immutable Models

- All models/entities in `lib/data/models/` and `lib/domain/entities/` use `freezed`.
- Never mutate in place; use `copyWith()`.
- Never edit generated `*.freezed.dart` or `*.g.dart` files manually.

### 9. Measurements

- Display durations as `HH:MM:SS` via `lib/core/utils/duration_utils.dart`.
- Use logical pixels only.
- Use metric wording in comments, docs, and identifiers.

### 10. Strings

- Every user-visible string lives in `lib/core/constants/app_strings.dart`.
- User-facing error messages also live there.
- SQL strings belong in DAO classes only.

### 11. Shell And Path Conventions

- All shell examples and commands in docs/comments use PowerShell syntax.
- Use backslashes in Windows documentation paths.
- In Dart code, use `/` or `path.join()`.

## Architecture Rules

### Layers

```text
Presentation  lib/presentation/   Widgets + Riverpod consumers
Application   lib/application/    StateNotifiers, providers
Domain        lib/domain/         Use-cases, repository interfaces, domain entities
Data          lib/data/           Repository impls, DAOs, DB models, migrations, backup
Core          lib/core/           Utils, constants, exceptions; no Flutter imports
```

- `core/` is pure Dart with zero Flutter imports.
- `domain/` depends on `core/` only and never imports `sqflite`.
- `data/` implements domain repository interfaces.
- `presentation/` never imports `data/` directly.

### State Management

- Use `StateNotifierProvider` for mutable screen state.
- Use `FutureProvider` for one-shot async reads.
- Use `FutureProvider.family` for parameterized async queries.
- Use `StreamProvider` only for the live timer.
- Declare providers in `lib/application/providers.dart`.
- Root `ProviderScope` lives in `main.dart`; do not nest extra scopes unless tests require it.

### Navigation

- Define routes in `lib/app.dart`.
- Keep path constants in `lib/core/constants/app_routes.dart`.
- Never use `Navigator.push()` directly; use `go_router`.
- `/` resolves to today's daily list.

### Database

- `DatabaseService` is a singleton exposed by Riverpod.
- Resolve DB location with `path_provider.getApplicationDocumentsDirectory()`.
- Live DB uses a device-derived key; backups are re-encrypted with a user passphrase.
- `migration_v1.dart` is append-only after first release. New schema changes go in new migration files.
- Multi-row writes use transactions.
- Enable:

```sql
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;
```

- Platform detection for `sqflite_common_ffi` happens only in `main.dart`.

## Naming And File Rules

- Dart files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Providers: `camelCaseProvider`
- DB tables/columns: `snake_case`
- Routes: kebab-case with `:param`
- Tests mirror source path and end in `_test.dart`

- New feature screens must include both the screen file and a `widgets/` subdirectory.
- New DAO methods require tests in the same change.
- New `freezed` or `json_serializable` models require code generation before use.
- Migration files are append-only.
- Never store `key.properties` inside the repo root; keep it at `L:\Android\key.properties`.

## Code Generation

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

Run code generation after adding or changing any `@freezed` or `@JsonSerializable` class.

## Testing And Validation

- Coverage target: at least `80%` for `lib/data/` and `lib/domain/`.
- Write tests alongside features, not in a later batch.
- DAO tests use in-memory SQLite.
- Widget tests mock repositories, never DAOs.
- Integration tests live in `integration_test/app_test.dart`.
- Every new DAO method must have a test.
- Do not use `print()` in tests.

Commands:

```powershell
flutter test
flutter test test/data/todo_dao_test.dart
flutter test integration_test/app_test.dart
flutter analyze
dart format lib/ test/ integration_test/
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
```

## Dependency Constraints

- Do not upgrade packages without rerunning analysis and tests.
- Stay on Android Gradle Plugin `8.x`.
- Hard-blocked package categories:
  - HTTP clients
  - WebSockets
  - Cloud/BaaS SDKs
  - Analytics
  - Crash reporting
  - Ads
  - Network-status packages
- Approved local-only packages include:
  - `sqflite_sqlcipher`
  - `sqflite_common_ffi`
  - `path`
  - `path_provider`
  - `flutter_riverpod`
  - `go_router`
  - `intl`
  - `fl_chart`
  - `table_calendar`
  - `uuid`
  - `flutter_localizations`
  - `freezed`
  - `freezed_annotation`
  - `json_serializable`
  - `json_annotation`
  - `build_runner`
  - `mocktail`
  - `flutter_test`
  - `unorm_dart`
  - `file_picker`
  - `flutter_native_splash`
  - `rrule`

If a new package is proposed:
1. State why it is needed.
2. Confirm it is network-free.
3. Run the dependency audit.
4. Confirm analysis and tests afterwards.

## Codex Must Always Do

1. Read this file and [CLAUDE.md](/l:/Android/sreerajp_todo/CLAUDE.md) before making non-trivial changes.
2. State the target layer before adding a new class or feature slice.
3. Enforce NFC normalization on every DB text write path.
4. Enforce day-lock checks in every repository mutation.
5. Add tests with every new DAO method.
6. Keep user-visible strings in `app_strings.dart`.
7. Route multi-step operations through domain use-cases.
8. Use bundled assets only.
9. Use PowerShell syntax in docs and command examples.
10. After behavior changes, run `flutter analyze` and `flutter test` before considering the task complete.
11. Preserve the undo UX: SnackBar with 5-second timeout and persistent app-bar undo for terminal status changes and bulk status changes; stack depth 5; clear on day navigation or 2 minutes inactivity.

## Codex Must Never Do

- Put business logic in widget files.
- Call DAOs directly from widgets or notifiers.
- Edit generated files manually.
- Write directly to `todos` or `time_segments` outside the repository layer.
- Expose raw `sqflite` `Database` objects outside `lib/data/`.
- Skip NFC normalization before DB text writes.
- Allow a second open time segment for the same todo.
- Store secrets, keys, or signing credentials in the project root.
- Use `Navigator.push()` instead of `go_router`.
- Add cloud, analytics, networking, telemetry, or connectivity dependencies.
- Add Android network permissions.
- Use URL-based image loading.
- Store or transmit data outside the local device filesystem.
- Make outbound network calls from Dart for any reason.
- Use `compute()` or `Isolate.spawn()` for `sqflite` queries.
- Cache the full autocomplete title list in memory.

## Key References

- Full project rules: [CLAUDE.md](/l:/Android/sreerajp_todo/CLAUDE.md)
- Engineering standard: [docs/flutter_project_engineering_standard.md](/l:/Android/sreerajp_todo/docs/flutter_project_engineering_standard.md)
- Architecture overview: [docs/architecture.md](/l:/Android/sreerajp_todo/docs/architecture.md)
- Security constraints: [docs/security.md](/l:/Android/sreerajp_todo/docs/security.md)

## Quick Utility Reference

- `lib/core/utils/unicode_utils.dart`
  - `nfcNormalize(String s)`
  - `detectTextDirection(String s)`
- `lib/core/utils/date_utils.dart`
  - `isToday(String date)`
  - `isPastDate(String date)`
  - `formatDate(DateTime d)`
  - `todayAsIso()`
- `lib/core/utils/duration_utils.dart`
  - `formatDuration(int seconds)`

## Exception Reference

- `DayLockedException`
- `CompletedLockException`
- `DuplicateTitleException`
- `SegmentAlreadyRunningException`
- `TodoNotFoundException`
- `BackupVersionTooNewException`
- `BackupCorruptedException`

All exceptions are defined in `lib/core/errors/exceptions.dart`.

Last synced from `CLAUDE.md`: `2026-03-22`
