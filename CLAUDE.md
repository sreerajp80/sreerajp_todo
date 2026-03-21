# CLAUDE.md — SreerajP Journal Vault

> This file is read automatically by Claude Code on every session in this project.
> It defines conventions, constraints, and context that must be followed without exception.

---

## Project Identity

| Field | Value |
|-------|-------|
| **App name** | SreerajP Journal Vault |
| **Type** | Personal offline-first daily ToDo / time-tracker |
| **Project root** | `L:\Android\SreerajP_ToDo` |
| **Flutter SDK** | 3.41.4 stable • rev `ff37bef603` |
| **Dart SDK** | 3.11.1 |
| **DevTools** | 2.54.1 |
| **Engine rev** | `e4b8dca3f1` • hash `99578ad035` |
| **IDE** | Visual Studio Code |
| **Platforms (MVP)** | Android, Windows desktop |
| **Platforms (future)** | iOS, Linux, macOS — architecture must not block these |
| **Database** | SQLite via `sqflite_sqlcipher` (mobile, AES-256 encrypted) + `sqflite_common_ffi` with SQLCipher (desktop) |
| **State management** | Riverpod (`flutter_riverpod`) |
| **Navigation** | `go_router` |
| **Organisation ID** | `com.sreerajp` |
| **Connectivity** | **None — fully offline, zero internet access required or permitted** |
| **Backend** | None |
| **Cloud services** | None |
| **Analytics / telemetry** | None |
| **Data leaves device** | Never |

---

## Non-Negotiable Rules

These rules apply to every file, every suggestion, every code snippet — no exceptions.

### 1. Fully Offline — No Internet Access, Ever

This is an **absolute constraint**. The app must install, launch, and operate in full without
any network interface being available — on an aeroplane, in a basement, on a device with no SIM
and no Wi-Fi. No feature may degrade, warn, or fail when the device is offline.

#### Package constraints
- **Zero** networking packages are permitted: no `http`, `dio`, `retrofit`, `chopper`,
  `web_socket_channel`, `connectivity_plus`, `internet_connection_checker`, or any transitive
  dependency that opens a socket.
- **Zero** cloud SDK packages: no Firebase, Supabase, Amplify, AppWrite, back4app, or any BaaS.
- **Zero** analytics or crash-reporting packages: no Sentry, Crashlytics, Datadog, Mixpanel,
  Amplitude, Segment, or any telemetry SDK.
- **Zero** ad SDKs.
- Before adding **any** new package, inspect its `pubspec.yaml` for transitive dependencies that
  include networking. If any are found, the package is rejected.

#### Android manifest
- The `AndroidManifest.xml` must **not** contain `INTERNET` permission.
- It must **not** contain `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, or any network permission.
- During Phase 9 (Build), verify with:
  ```powershell
  # Confirm INTERNET permission is absent from the merged manifest
  Select-String -Path "build\app\intermediates\merged_manifests\release\AndroidManifest.xml" `
    -Pattern "INTERNET"
  # Expected: zero matches
  ```

#### Windows
- The Windows build must not register any firewall rule or make any outbound connection.
- No WinRT network capability (`internetClient`, `internetClientServer`, `privateNetworkClientServer`)
  may appear in `Package.appxmanifest`.

#### Data storage
- All user data is stored exclusively in the local SQLite file on the device filesystem.
- No data is written to cloud storage, shared preferences synced to a cloud account,
  or any location outside the app's sandbox.
- The database file path is resolved at runtime via `path_provider` — it is always on the
  local filesystem, never a remote path or URI.

#### Font & asset loading
- All fonts and assets used at runtime must be **bundled** in the app binary (declared in
  `pubspec.yaml` under `flutter: assets:` or `flutter: fonts:`).
- Do not use `NetworkImage`, `Image.network()`, or any URL-based asset loader anywhere in the app.
- Use `AssetImage`, `Image.asset()`, or `Image.file()` only.

#### `pubspec.yaml` audit rule
- Every `flutter pub add` or manual `pubspec.yaml` edit must be followed by:
  ```powershell
  flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics"
  ```
  Zero matches are required before proceeding.

---

### 2. Unicode First

- Every `String` that is stored in the database **must** be NFC-normalised before the write.
  Use `unicodeUtils.nfcNormalize(value)` (defined in `lib/core/utils/unicode_utils.dart`,
  backed by the `unorm_dart` package).
- Never assume ASCII. All text fields accept any Unicode code point: CJK, RTL (Arabic, Hebrew),
  Devanagari, emoji, zero-width characters.
- Never hard-code `TextDirection.ltr` on a text input field. Use `unicodeUtils.detectTextDirection()`
  to set `textDirection` dynamically.
- `UNIQUE (date, title)` in SQLite is enforced after NFC normalisation — the repository layer must
  normalise the title string **before** the uniqueness check and before the SQL write.
- SQLite stores all text as **UTF-8**. Do not convert to any other encoding.

### 3. Day Lock is Sacred

- Any `TodoEntity` whose `date` field is strictly before today's local calendar date is **read-only**.
- The `TodoRepository` implementation **must** throw `DayLockedException` (defined in
  `lib/core/errors/exceptions.dart`) if a mutating operation is attempted on a past-date record.
  This is checked in the repository — not only in the UI.
- The UI additionally shows a padlock icon and disables all interactive controls for past-date items.
- There is no admin override or "bypass lock" UI. The `bypassLock` parameter in repository methods
  exists only for future internal tooling / export, never exposed to the user.

### 4. Terminal Status Lock (Completed / Dropped)

- Once a `TodoEntity.status` is set to `completed` or `dropped`, no new `TimeSegmentEntity` may
  be inserted for that todo, and no existing open segment may be closed against it. Any running
  timer is stopped when the status is changed.
- The repository throws `CompletedLockException` if this is attempted.
- UI must hide the start/stop button entirely for completed and dropped todos — not just disable it.
- In **statistics**, time spent on completed tasks is categorised as **productive time**, while
  time spent on dropped tasks is categorised as **dropped time** — they are reported separately.
- Changing status to **dropped** or **ported** requires a **confirmation dialog**. Marking as
  **completed** does not (most common action, should be fast).

### 5. One Open Segment Per Todo

- At most one `TimeSegmentEntity` with `end_time IS NULL` may exist for any given `todo_id` at any
  time. The `StartTimeSegment` use-case (or `TimeSegmentDao.insert()`) must check for an existing
  open segment and throw `SegmentAlreadyRunningException` before inserting.
- Multiple todos may have timers running simultaneously — there is no global single-timer constraint.
- On app startup, the `RepairOrphanedSegments` use-case is called. Any segment where
  `end_time IS NULL` and the parent `todos.date < today` is closed with
  `end_time = start_time` (zero duration) and marked as `interrupted = 1`.
- The `interrupted` and `manual` columns are included in the initial `time_segments` schema
  (`migration_v1.dart`). `manual = 1` indicates a manually entered segment (not recorded via
  start/stop).

### 6. Title Uniqueness Per Day

- Two todos on the same calendar `date` may never share the same title after NFC normalisation.
- Uniqueness is enforced at **three** layers:
  1. `UNIQUE (date, title)` constraint in SQLite DDL.
  2. `TodoDao.existsTitleOnDate()` check in the repository before every insert/update.
  3. Real-time validator on the title `TextFormField` in the UI (debounce 300 ms).
- The `excludeId` parameter in `existsTitleOnDate()` must always be passed during edits so that the
  current item does not conflict with itself.

### 7. No Direct DB Access from Widgets

- Widgets **never** import or call DAO classes directly.
- Widgets consume only Riverpod providers from `lib/application/providers.dart`.
- The call chain is:
  - `Widget → Provider/Notifier → UseCase → Repository → DAO → sqflite` (multi-step operations)
  - `Widget → Provider/Notifier → Repository → DAO → sqflite` (simple CRUD)
- Use-cases (`lib/domain/usecases/`) are for multi-step orchestrations only (e.g.,
  `MarkTodoCompleted`, `PortTodo`, `CopyTodos`, `StartTimeSegment`, `RepairOrphanedSegments`).
  Simple reads and single-step writes go directly through the repository.

### 8. Immutable Models

- All data model classes in `lib/data/models/` and `lib/domain/entities/` use `freezed`.
- Never mutate a model in-place. Always use `copyWith()`.
- Generated files (`*.freezed.dart`, `*.g.dart`) are **never** edited manually.
- Run code generation with:
  ```powershell
  dart run build_runner build --delete-conflicting-outputs
  ```

### 9. Measurements — Metric Only

- All displayed durations use `HH:MM:SS` (via `lib/core/utils/duration_utils.dart`).
- All spacing, padding, and sizing values in the UI are in logical pixels (dp) — Flutter's default.
  Never use inches, points, or imperial units in comments or variable names.
- Statistics that reference counts are plain integers. No percentage formatting unless it is
  explicitly derived from a count (e.g., completion rate = completed / total × 100).

### 10. No Hardcoded Strings in Widgets

- Every user-visible string must be defined as a constant in `lib/core/constants/app_strings.dart`.
- Error messages shown to the user are defined in `lib/core/constants/app_strings.dart` under the
  `AppStrings.errors` namespace.
- SQL query strings belong in the DAO class that uses them — not in repositories or widgets.

### 11. PowerShell for All Shell Examples

- This project runs on **Windows**. Every shell command in code comments, documentation, or
  suggestions must use PowerShell syntax.
- Use backslash `\` for Windows paths in documentation; use forward slash `/` or `path.join()` in
  Dart code (the `path` package normalises correctly on all platforms).

---

## Architecture Rules

### Layer Boundaries

```
Presentation  lib/presentation/       Widgets + Riverpod consumers
Application   lib/application/        StateNotifiers, providers
Domain        lib/domain/             Use-cases, abstract repository interfaces, domain entities
Data          lib/data/               Repository impls, DAOs, query services, DB models, migrations, backup
Core          lib/core/               Utils, constants, exceptions — no Flutter imports
```

- `core/` has **zero** Flutter framework imports. Pure Dart only. This makes it testable
  without a Flutter environment.
- `domain/` has **zero** `sqflite` or any other data-layer imports. It depends only on `core/`.
  It contains use-case classes (`lib/domain/usecases/`) for multi-step business orchestrations
  and abstract repository interfaces (`lib/domain/repositories/`).
- `data/` implements `domain/repositories/` interfaces. Repository implementations live in
  `lib/data/repositories/`. It never imports from `presentation/` or `application/`.
- `presentation/` never imports from `data/` directly.

### State Management

- Use `StateNotifierProvider` for mutable screen-level state.
- Use `FutureProvider` for one-shot async reads.
- Use `FutureProvider.family` for parameterised async queries (autocomplete prefix, search query).
- Use `StreamProvider` **only** for the live timer (elapsed seconds on a running time segment).
  Do not use `StreamProvider` for anything else — prefer `FutureProvider` + manual refresh.
- All providers are declared in `lib/application/providers.dart`. No inline provider declarations
  in widget files.
- Provider scope: `ProviderScope` at the root in `main.dart` — never nest additional `ProviderScope`
  widgets unless explicitly required for testing.

### Navigation

- All routes are defined in `lib/app.dart` inside the `GoRouter` configuration.
- Route path constants are defined in `lib/core/constants/app_routes.dart`.
- Never use `Navigator.push()` directly. Always use `context.go()`, `context.push()`, or
  `context.pop()` from `go_router`. The copy/port wizard returns results via typed `context.pop<T>()`.
- The `/` route always resolves to today's daily list (`/day/<today>`).

### Database

- `DatabaseService` is a singleton accessed via a Riverpod `Provider`.
- Database file location: resolved at runtime via `path_provider.getApplicationDocumentsDirectory()`.
- **Database encryption (dual-key)**: AES-256 via `sqflite_sqlcipher` (mobile) / SQLCipher FFI (desktop).
  - **Live database:** device-derived key (Android Keystore / Windows DPAPI) — transparent to the
    user, generated on first launch, never exposed.
  - **Backup files:** re-encrypted with a **user-set passphrase** at export time. This makes backups
    portable across devices and survivable across factory resets. The passphrase is entered at
    export and import — it is never stored on disk.
- Schema versioning: `onCreate` runs `migration_v1.dart` (contains the complete initial schema
  including `source_date`, `interrupted`, and `manual` columns); `onUpgrade` runs the appropriate
  incremental migration file. Never modify an existing migration file — add a new one.
- All writes use transactions where more than one row is affected.
- Always enable at startup:
  ```sql
  PRAGMA journal_mode=WAL;
  PRAGMA foreign_keys=ON;
  ```
- Platform detection for `sqflite_common_ffi` is done **only** in `main.dart`:
  ```dart
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  ```
  No other file checks the platform for database initialisation.

---

## Database Schema Reference

### `todos` table

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | TEXT | PK | UUID v4 |
| `date` | TEXT | NOT NULL | `YYYY-MM-DD` local date |
| `title` | TEXT | NOT NULL | NFC-normalised Unicode |
| `description` | TEXT | nullable | Unicode |
| `status` | TEXT | NOT NULL DEFAULT `'pending'` | `pending` \| `completed` \| `dropped` \| `ported` |
| `ported_to` | TEXT | nullable | `YYYY-MM-DD` — set only when `status = 'ported'` |
| `source_date` | TEXT | nullable | `YYYY-MM-DD` — set when this row was copied/ported from another date |
| `recurrence_rule_id` | TEXT | nullable, FK → `recurrence_rules.id` ON DELETE SET NULL | Links to the recurrence rule that generated this todo |
| `sort_order` | INTEGER | NOT NULL DEFAULT 0 | user drag-order within the day |
| `created_at` | TEXT | NOT NULL | ISO-8601 UTC datetime |
| `updated_at` | TEXT | NOT NULL | ISO-8601 UTC datetime |
| UNIQUE | — | `(date, title)` | enforced after NFC normalisation |

### `time_segments` table

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | TEXT | PK | UUID v4 |
| `todo_id` | TEXT | NOT NULL, FK → `todos.id` ON DELETE CASCADE | |
| `start_time` | TEXT | NOT NULL | ISO-8601 local datetime |
| `end_time` | TEXT | nullable | NULL = segment still running |
| `duration_seconds` | INTEGER | nullable | computed on segment close (whole seconds, truncated) |
| `interrupted` | INTEGER | NOT NULL DEFAULT 0 | 1 = auto-closed by orphan repair |
| `manual` | INTEGER | NOT NULL DEFAULT 0 | 1 = manually entered, 0 = recorded via start/stop |
| `created_at` | TEXT | NOT NULL | ISO-8601 UTC datetime |

### `recurrence_rules` table

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | TEXT | PK | UUID v4 |
| `title` | TEXT | NOT NULL | Template title (NFC-normalised) |
| `description` | TEXT | nullable | Template description |
| `rrule` | TEXT | NOT NULL | iCalendar RRULE string (RFC 5545) |
| `start_date` | TEXT | NOT NULL | `YYYY-MM-DD` when recurrence begins |
| `end_date` | TEXT | nullable | `YYYY-MM-DD` when recurrence ends (NULL = infinite) |
| `active` | INTEGER | NOT NULL DEFAULT 1 | 1 = active, 0 = paused |
| `created_at` | TEXT | NOT NULL | ISO-8601 UTC datetime |
| `updated_at` | TEXT | NOT NULL | ISO-8601 UTC datetime |

### Status enum values (stored as TEXT in DB)

| Dart enum | DB string | Meaning |
|-----------|-----------|---------|
| `TodoStatus.pending` | `'pending'` | Not yet acted on |
| `TodoStatus.completed` | `'completed'` | Done — locks new time segments |
| `TodoStatus.dropped` | `'dropped'` | Task dropped / no longer being pursued |
| `TodoStatus.ported` | `'ported'` | Moved to another day — `ported_to` is set |

---

## Riverpod Provider Registry

All providers live in `lib/application/providers.dart`.

| Provider | Type | Exposes |
|----------|------|---------|
| `databaseServiceProvider` | `Provider<DatabaseService>` | Singleton DB service |
| `todoDaoProvider` | `Provider<TodoDao>` | DAO |
| `timeSegmentDaoProvider` | `Provider<TimeSegmentDao>` | DAO |
| `statisticsQueryServiceProvider` | `Provider<StatisticsQueryService>` | Read-only query service |
| `todoRepositoryProvider` | `Provider<TodoRepository>` | Repository impl |
| `backupServiceProvider` | `Provider<BackupService>` | Backup service singleton |
| `dailyTodoProvider(date)` | `StateNotifierProvider.family` | Todos for one day + undo support |
| `timeTrackingProvider(todoId)` | `StateNotifierProvider.family` | Segment state for one todo |
| `liveTimerProvider(todoId)` | `StreamProvider.family` | Live elapsed time (1 s ticks) |
| `autocompleteProvider(prefix)` | `FutureProvider.family` | Title suggestions via direct DB query |
| `searchResultsProvider(query)` | `FutureProvider.family` | Cross-day search results |
| `recurrenceRuleDaoProvider` | `Provider<RecurrenceRuleDao>` | DAO |
| `recurrenceRulesProvider` | `StateNotifierProvider` | All recurrence rules |
| `statisticsProvider` | `StateNotifierProvider<StatisticsNotifier, StatisticsState>` | Paginated aggregated stats |

---

## go_router Route Table

| Route path | Screen class | Notes |
|------------|-------------|-------|
| `/` | — | Redirects to `/day/<today>` |
| `/day/:date` | `DailyListScreen` | `date` param: `YYYY-MM-DD` |
| `/todo/new` | `CreateEditTodoScreen` | Query param: `?date=YYYY-MM-DD` |
| `/todo/:id` | `CreateEditTodoScreen` | Edit mode |
| `/todo/:id/segments` | `TimeSegmentsScreen` | View/add time segments |
| `/copy` | `CopyTodosScreen` | Query param: `?from=YYYY-MM-DD` |
| `/search` | `SearchResultsScreen` | Query param: `?q=<search-term>` |
| `/backup` | `BackupScreen` | Export / import / list backups |
| `/recurring` | `RecurringTasksScreen` | Manage recurrence rules |
| `/recurring/new` | `RecurrenceEditorScreen` | Create a new recurrence rule |
| `/recurring/:id` | `RecurrenceEditorScreen` | Edit an existing recurrence rule |
| `/statistics` | `StatisticsScreen` | |

Route path constants live in `lib/core/constants/app_routes.dart`.

---

## Naming Conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Dart files | `snake_case.dart` | `todo_dao.dart` |
| Classes | `PascalCase` | `TodoRepository` |
| Variables / methods | `camelCase` | `findByDate()` |
| Constants | `camelCase` in `const` context | `kDatabaseVersion` |
| Providers | `camelCase` + `Provider` suffix | `todoRepositoryProvider` |
| DB table names | `snake_case` plural | `todos`, `time_segments` |
| DB column names | `snake_case` | `sort_order`, `ported_to` |
| Route paths | kebab-case with `:param` | `/day/:date` |
| Test files | mirror source path, `_test.dart` suffix | `todo_dao_test.dart` |
| Enums | `PascalCase` type, `camelCase` values | `TodoStatus.pending` |

---

## File Creation Rules

- When creating a new feature screen, **always** create both the screen file and a `widgets/`
  subdirectory, even if it starts empty.
- New DAO methods must have a corresponding unit test added in the same commit/session.
- New `freezed` models require running the code-gen command before the model can be used.
- Generated files (`*.freezed.dart`, `*.g.dart`) must **never** be edited manually.
- Migration files are **append-only**: `migration_v1.dart` is never changed after its first use.
  New schema changes go in `migration_v2.dart`, etc.
- `key.properties` (Android signing) must **never** be created inside the project directory that
  is tracked by Git. Store it at `L:\Android\key.properties` (one level up).

---

## Code Generation

```powershell
# Re-generate all freezed + json_serializable code
dart run build_runner build --delete-conflicting-outputs

# Watch mode during active development
dart run build_runner watch --delete-conflicting-outputs
```

Always run build_runner after:
- Adding a new `@freezed` class.
- Adding a new `@JsonSerializable` class.
- Changing any field in an existing `@freezed` / `@JsonSerializable` class.

---

## Testing Rules

- Minimum unit test coverage target: **80 %** on `lib/data/` and `lib/domain/`.
- **Tests are written alongside features** in each phase — not batched in a separate testing phase.
  Phase 8 is reserved for integration tests, coverage audits, and performance profiling.
- All DAO tests use an **in-memory SQLite** database (pass `inMemoryDatabasePath` to `openDatabase`).
- Widget tests mock the repository layer via `mocktail` — never mock DAOs directly in widget tests.
- Integration tests live in `integration_test/app_test.dart` and run on Android emulator.
- Test file must be created for every new DAO method. No exceptions.
- Do not use `print()` in tests — use `debugPrint()` or structured logging.

### Running Tests

```powershell
# All unit + widget tests
flutter test

# Single file
flutter test test/data/todo_dao_test.dart

# Integration tests (Android emulator must be running)
flutter test integration_test/app_test.dart
```

---

## Build Commands

```powershell
# Android debug
flutter run -d <emulator-id>

# Android release APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Windows debug
flutter run -d windows

# Windows release
flutter build windows --release

# Analyse code (run before every commit)
flutter analyze

# Format all Dart files
dart format lib/ test/ integration_test/
```

---

## Dependency Constraints

- **Do not upgrade** any package without running `flutter analyze` and all tests afterwards.
- **Android Gradle Plugin**: stay on AGP **8.x** — AGP 9 is not yet fully supported by all
  Flutter 3.41 plugins. Do not accept automated AGP upgrade suggestions.
- **Offline enforcement — hard blocked packages** (never add, never accept as transitive dep):

  | Category | Blocked examples |
  |----------|-----------------|
  | HTTP clients | `http`, `dio`, `chopper`, `retrofit` |
  | WebSockets | `web_socket_channel`, `socket_io_client` |
  | Cloud / BaaS | `firebase_core` and all `firebase_*`, `supabase`, `amplify_*`, `appwrite` |
  | Analytics | `firebase_analytics`, `amplitude_flutter`, `mixpanel_flutter`, `segment_analytics` |
  | Crash reporting | `sentry_flutter`, `firebase_crashlytics`, `datadog_flutter_plugin` |
  | Ads | Any `*_ads_*` or `google_mobile_ads` |
  | Network status | `connectivity_plus`, `internet_connection_checker` |

- **Allowed local-only packages** (pre-approved, already in plan):
  `sqflite_sqlcipher`, `sqflite_common_ffi`, `path`, `path_provider`, `flutter_riverpod`,
  `go_router`, `intl`, `fl_chart`, `table_calendar`, `uuid`, `flutter_localizations`,
  `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`,
  `build_runner`, `mocktail`, `flutter_test`, `unorm_dart`, `file_picker`,
  `flutter_native_splash`, `rrule`.

  > `sqflite_sqlcipher` replaces `sqflite` for encrypted storage (plan v1.3).
  > `unorm_dart`, `file_picker`, and `flutter_native_splash` were added in plan v1.2.
  > Each must pass the offline dep audit before being added to the project.

- **Vetting new packages**: before adding anything not in the approved list above —
  1. Check the package's own `pubspec.yaml` on pub.dev for any networking dependency.
  2. Run the dep-audit command (see Rule 1 — Fully Offline).
  3. State clearly in the request why the package is needed and confirm it is network-free.

- If a new package is needed, check `pub.dev` scores: Likes > 100, Pub points = 130/130,
  and Flutter Favorites badge preferred.

---

## What Claude Must Always Do

1. **Read this file first** before writing any code for this project.
2. **Verify offline compliance** before suggesting any new package — run the dep-audit command
   and confirm zero networking matches.
3. **Ask before adding any new package** not already listed in the plan — state the reason,
   the pub.dev score, and which existing package it replaces or supplements.
4. **State the target layer** (Presentation / Application / Domain / Data / Core) before
   implementing any new class.
5. **Normalise strings to NFC** in every code path that writes a title or description to the DB.
6. **Check the day lock** in every repository method that mutates data.
7. **Write the test first** (or alongside) any new DAO method — never leave a DAO method untested.
8. **Use PowerShell syntax** for any shell command examples on this Windows machine.
9. **Prefer metric units** in all comments, variable names, and documentation.
10. **Run `flutter analyze`** mentally before suggesting code — flag any `avoid_print`,
    `prefer_const_constructors`, or `unnecessary_import` violations proactively.
11. **Never hardcode a string** visible to the user outside of `app_strings.dart`.
12. **Use only bundled assets** — `AssetImage`, `Image.asset()`, or `Image.file()`.
    Never use `Image.network()` or any URL-based loader.
13. **Route multi-step operations through use-cases** (`lib/domain/usecases/`). Simple CRUD
    goes directly through the repository.
14. **Show an undo SnackBar** (5 s timeout) + **persistent undo button (↩) in the app bar**
    after every terminal status change (completed, dropped, ported) and after bulk status
    changes. The undo stack holds the last 5 changes and clears on day navigation or after
    2 minutes of inactivity.

---

## What Claude Must Never Do

- **Never** put business logic in a widget file. Move it to a Notifier, Use-Case, or Repository.
- **Never** call a DAO directly from a widget or a Notifier — always go through the Repository
  (or Use-Case → Repository for multi-step operations).
- **Never** edit `*.freezed.dart` or `*.g.dart` files manually.
- **Never** write to the `todos` or `time_segments` table without going through the Repository layer.
- **Never** expose raw `sqflite` `Database` objects outside of `lib/data/`.
- **Never** skip NFC normalisation before a DB write of a text field.
- **Never** allow a second open `time_segments` row (`end_time IS NULL`) for the same `todo_id`.
- **Never** suggest storing secrets, API keys, or signing credentials inside the project root.
- **Never** use `Navigator.push()` — use `go_router`'s `context.go()` / `context.push()` /
  `context.pop()`.
- **Never** add a cloud, analytics, networking, or telemetry dependency.
- **Never** use imperial measurements in code, comments, or documentation.
- **Never** add `INTERNET`, `ACCESS_NETWORK_STATE`, or any network permission to `AndroidManifest.xml`.
- **Never** use `Image.network()`, `NetworkImage`, or any URL-based image or asset loader.
- **Never** store or transmit data outside the device's local filesystem.
- **Never** make an outbound network call from any Dart code path, even for debugging or logging.
- **Never** use `compute()` or `Isolate.spawn()` for `sqflite` queries — database handles are not
  transferable across Dart isolates.
- **Never** cache the full autocomplete title list in memory — always query the DB directly
  with a prefix and `LIMIT`.

---

## Quick Reference: Key Utility Functions

| Function | Location | Purpose |
|----------|----------|---------|
| `nfcNormalize(String s)` | `lib/core/utils/unicode_utils.dart` | NFC-normalise before DB write |
| `detectTextDirection(String s)` | `lib/core/utils/unicode_utils.dart` | RTL/LTR detection for TextFields |
| `isToday(String date)` | `lib/core/utils/date_utils.dart` | Check if ISO date = today |
| `isPastDate(String date)` | `lib/core/utils/date_utils.dart` | Check if date < today (lock check) |
| `formatDate(DateTime d)` | `lib/core/utils/date_utils.dart` | Localised display string |
| `formatDuration(int seconds)` | `lib/core/utils/duration_utils.dart` | Seconds → `HH:MM:SS` string |
| `todayAsIso()` | `lib/core/utils/date_utils.dart` | Returns today as `YYYY-MM-DD` string |

---

## Exception Taxonomy

| Exception class | When thrown |
|-----------------|-------------|
| `DayLockedException` | Mutating a todo whose `date < today` |
| `CompletedLockException` | Adding/closing a time segment on a `completed` todo |
| `DuplicateTitleException` | Inserting/updating a title that already exists for that date |
| `SegmentAlreadyRunningException` | Starting a new segment when one is already open for that todo |
| `TodoNotFoundException` | Attempting to operate on a non-existent todo ID |
| `BackupVersionTooNewException` | Imported backup DB has a schema version newer than the app |
| `BackupCorruptedException` | `PRAGMA integrity_check` fails on the backup file |

All exceptions are defined in `lib/core/errors/exceptions.dart`.

---

*This file is the single source of truth for AI-assisted development in this project.
Last updated: 2026-03-20 — synced with plan v1.3 (unable→dropped, hybrid undo with confirmation
dialogs, dual-key encryption: device key for live DB + user passphrase for portable backups,
dropped≠completed in stats, sqflite_sqlcipher replaces sqflite).*
