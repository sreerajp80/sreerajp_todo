# Architecture

## 1. Scope

- Product: `SreerajP ToDo`
- Repository type: `application`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension`
- Platforms: `Android`, `Windows` (v1.0); `iOS`, `Linux`, `macOS` (future — architecture must not block these)

## 2. Goals And Non-Goals

### Goals

- Fully offline daily ToDo and time-tracking app with zero internet dependency.
- All data encrypted at rest using AES-256 (SQLCipher) and stored exclusively on the local device.
- Multi-segment time tracking per task per day, with both auto-recorded and manual entry.
- Copy/port tasks between days, recurring task generation, and cross-day search.
- Statistical reporting with charts and paginated data tables.
- Full Unicode support including CJK, RTL scripts, Devanagari, and emoji.

### Non-Goals

- Multi-user support, shared access, or data sync between devices.
- Cloud storage, remote backup, online accounts, or any network connectivity.
- Push notifications or reminders (deferred to a future version).
- User authentication or app lock (no login, no biometric gate in v1.0).

## 3. Architecture Summary

The app uses a custom 5-layer architecture (Presentation / Application / Domain / Data / Core) with Riverpod for state management. Screens delegate to StateNotifiers or FutureProviders, which route through use-case classes for multi-step business operations or directly through repository implementations for simple CRUD. All persistence is isolated behind a DAO layer backed by an encrypted SQLite database via `sqflite_sqlcipher`. Navigation is declarative via `go_router`.

## 4. Repository Structure

### Current Structure Tier

- `Custom Layered` (closest to Tier 2, but organised by architectural layer rather than by feature)
- Why this structure is appropriate:
  - Single-domain app (daily todos) with shared entities across all screens.
  - The domain model is small enough that feature-based isolation would add indirection without benefit.
  - Clear layer boundaries keep business logic testable without Flutter dependencies.

### Top-Level Source Layout

```text
lib/
|-- main.dart
|-- app.dart                        # MaterialApp, ThemeData, go_router
|-- core/
|   |-- constants/                  # app_constants, app_strings, app_routes
|   |-- errors/                     # exceptions, failures
|   `-- utils/                      # date_utils, duration_utils, unicode_utils
|-- data/
|   |-- database/                   # database_service, migrations/
|   |-- dao/                        # todo_dao, time_segment_dao, recurrence_rule_dao, statistics_query_service
|   |-- repositories/               # todo_repository_impl, time_segment_repository_impl
|   |-- backup/                     # backup_service
|   `-- models/                     # freezed entities + todo_status enum
|-- domain/
|   |-- entities/                   # domain models (immutable)
|   |-- repositories/               # abstract interfaces
|   `-- usecases/                   # multi-step business orchestrations
|-- application/                    # providers.dart, notifiers
`-- presentation/
    |-- screens/                    # one folder per screen with widgets/ subdirectory
    `-- shared/                     # shared widgets, theme
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/core/` | Pure Dart utilities, constants, exceptions — zero Flutter imports |
| `lib/data/` | Repository implementations, DAOs, database service, backup, migrations |
| `lib/domain/` | Abstract repository interfaces, use-case classes, domain entities — zero data-layer imports |
| `lib/application/` | Riverpod providers and StateNotifiers |
| `lib/presentation/` | Flutter widgets and screens — consumes only providers, never DAOs |

## 5. State Management

- Primary pattern: `Riverpod` (`flutter_riverpod`)
- Why this pattern was chosen:
  - Reactive, testable, and supports scoped overrides for testing.
  - Family providers fit naturally for parameterised queries (date, todoId, prefix).
  - No code generation required for basic usage.
- State boundaries:
  - Widgets own: animation state, form field controllers, scroll positions.
  - StateNotifiers own: screen-level state (todo list, undo stack, selection mode, pagination).
  - Repositories own: data access, day lock enforcement, title uniqueness checks.

### Provider Types Used

| Provider Type | Use |
|---------------|-----|
| `Provider` | Singleton services (DatabaseService, BackupService, DAOs, Repository) |
| `StateNotifierProvider.family` | Mutable screen state (DailyTodoNotifier per date, TimeTrackingNotifier per todoId) |
| `StateNotifierProvider` | Global mutable state (StatisticsNotifier, RecurrenceRulesNotifier) |
| `FutureProvider.family` | One-shot async reads (autocomplete prefix, search query) |
| `StreamProvider.family` | Live timer only (elapsed seconds ticking every 1 s) |

## 6. Data Flow

```text
Widget -> Provider/Notifier -> UseCase -> Repository -> DAO -> sqflite   (multi-step operations)
Widget -> Provider/Notifier -> Repository -> DAO -> sqflite              (simple CRUD)
```

Use-cases exist only for multi-step business orchestrations:

| Use-Case | Steps |
|----------|-------|
| `MarkTodoCompleted` | Close open segment -> set status to completed -> refresh |
| `MarkTodoDropped` | Close open segment -> set status to dropped -> refresh |
| `PortTodo` | Validate target date -> create copy on target -> mark source as ported (transaction) |
| `CopyTodos` | Conflict check per title -> batch insert -> return skip list |
| `StartTimeSegment` | Check day lock -> check completed lock -> check no running segment -> insert |
| `RepairOrphanedSegments` | Startup scan: close orphaned segments with zero duration |
| `GenerateRecurringTasks` | Expand RRULE rules for today + 7 days, create missing todos |

### Rules

- Widgets must not know: SQL, database handles, encryption, file paths.
- Notifiers must not know: DAO implementation details (they call repositories).
- Repositories abstract: SQLite queries, day lock enforcement, NFC normalisation.

## 7. Domain Model

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `TodoEntity` | One task per day | No (freezed) | Includes status, ported_to, source_date, recurrence_rule_id |
| `TimeSegmentEntity` | One start/stop pair | No (freezed) | Includes interrupted, manual flags |
| `RecurrenceRuleEntity` | RRULE template | No (freezed) | iCalendar RRULE string (RFC 5545) |
| `TodoStatus` | Enum: pending, completed, dropped, ported | No (enum) | Stored as TEXT in DB |

### Serialization Strategy

- JSON models: Yes (`json_serializable` for DB map conversion)
- Database models: Yes (freezed models in `lib/data/models/` mirror DB tables)
- Separate domain entities from transport models: Yes — domain entities in `lib/domain/entities/`, DB models in `lib/data/models/`

## 8. Dependency Management And Injection

- DI approach: Riverpod provider tree (root `ProviderScope` in `main.dart`)
- App-root dependencies:
  - `DatabaseService` (singleton, opened once at startup)
  - `BackupService` (singleton)
  - All DAOs and repositories (created from DatabaseService)
- Test replacement strategy:
  - `ProviderScope` overrides in tests to inject mock repositories.
  - `mocktail` for creating mock/fake implementations.
  - DAOs tested against in-memory SQLite databases.

## 9. Navigation

- Navigation approach: `go_router` (declarative)
- Route definition location: `lib/app.dart`
- Route path constants: `lib/core/constants/app_routes.dart`
- Protected-route strategy: Day lock is enforced at the repository layer, not via route guards.
- Deep-link support: No (not required for offline personal app).

### Route Table

| Route | Screen | Notes |
|-------|--------|-------|
| `/` | — | Redirects to `/day/<today>` |
| `/day/:date` | `DailyListScreen` | `YYYY-MM-DD` |
| `/todo/new` | `CreateEditTodoScreen` | Query param `?date=YYYY-MM-DD` |
| `/todo/:id` | `CreateEditTodoScreen` | Edit mode |
| `/todo/:id/segments` | `TimeSegmentsScreen` | View/add time segments |
| `/copy` | `CopyTodosScreen` | Query param `?from=YYYY-MM-DD` |
| `/search` | `SearchResultsScreen` | Query param `?q=<term>` |
| `/backup` | `BackupScreen` | Export / import / list backups |
| `/recurring` | `RecurringTasksScreen` | Manage recurrence rules |
| `/recurring/new` | `RecurrenceEditorScreen` | Create rule |
| `/recurring/:id` | `RecurrenceEditorScreen` | Edit rule |
| `/statistics` | `StatisticsScreen` | Charts and tables |

## 10. Persistence And External Systems

### Local Storage

- Database: `sqflite_sqlcipher` (mobile, AES-256 encrypted) + `sqflite_common_ffi` with SQLCipher (desktop)
- Key-value storage: None
- Secure storage: Android Keystore (Android) / Windows DPAPI (Windows) for the device-derived database encryption key

### Network

- Network client: None
- Offline behavior: Offline-only (the app has no networking code, no networking permissions, and no networking dependencies)

### Platform Channels Or Native Integrations

- `sqflite_sqlcipher`: Platform channel to native SQLCipher library (mobile)
- `sqflite_common_ffi`: FFI to SQLCipher shared library (desktop)
- `path_provider`: Platform channel to resolve app documents directory
- `file_picker`: Platform channel for file selection dialogs (backup export/import)

## 11. Environment And Build Model

- Flavors used: None (v1.0 — single configuration)
- Runtime config mechanism: None required (no environment-specific config)
- Build outputs supported:
  - Debug APK (`flutter build apk --debug`)
  - Release APK (`flutter build apk --release`)
  - Release App Bundle (`flutter build appbundle --release`)
  - Windows portable folder (`flutter build windows --release`)

## 12. UI System

- Theme source of truth: `lib/presentation/shared/theme/app_theme.dart`
- Design tokens location: Same file (colours, typography, spacing)
- Shared widget strategy: `lib/presentation/shared/widgets/` for cross-screen components (status badge, locked overlay, confirm dialog, undo snackbar)
- Accessibility expectations:
  - All interactive elements have `Semantics` labels.
  - Minimum tap target size 48 x 48 dp.
  - Status colours have contrast ratio >= 4.5:1 in both light and dark themes.

## 13. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | DAOs, repositories, use-cases, utilities, query services | In-memory SQLite for DAOs; mocktail for repositories |
| Widget | Screens with meaningful UI logic (daily list, create/edit, segments, stats) | Mock repositories via Riverpod overrides |
| Integration | Critical end-to-end flows (happy path, copy, day lock, Unicode, backup round-trip, offline enforcement) | `integration_test/app_test.dart` on Android emulator |

### Test Layout

```text
test/
|-- data/
|   |-- todo_dao_test.dart
|   |-- time_segment_dao_test.dart
|   |-- statistics_query_service_test.dart
|   |-- backup_service_test.dart
|   `-- recurrence_rule_dao_test.dart
|-- domain/
|   |-- todo_repository_test.dart
|   `-- usecases/
|       |-- mark_todo_completed_test.dart
|       |-- mark_todo_dropped_test.dart
|       |-- generate_recurring_tasks_test.dart
|       |-- port_todo_test.dart
|       `-- copy_todos_test.dart
|-- core/
|   `-- unicode_utils_test.dart
`-- presentation/
    |-- daily_list_screen_test.dart
    `-- create_edit_screen_test.dart
```

### Critical Test Areas

- Day lock enforcement (repository rejects mutations on past dates)
- Title uniqueness per day after NFC normalisation
- Terminal status lock (no segments on completed/dropped todos)
- Orphan segment repair on startup
- Backup export/import round-trip with passphrase re-encryption
- Unicode NFC normalisation (composed vs decomposed equivalence)

## 14. Operational Constraints

- Minimum supported OS versions: Android 5.0 (API 21), Windows 10
- Performance constraints:
  - Statistics queries paginated with `LIMIT/OFFSET` (no full-table scans)
  - Autocomplete queries < 100 ms with 5,000+ distinct titles
  - `ListView.builder` for lazy rendering of long lists
  - No `compute()` or `Isolate.spawn()` for DB queries (sqflite handles are not transferable)
  - 10-second result cache in StatisticsNotifier
- Regulatory or store constraints: None (personal use, not published to app stores in v1.0)
- Team constraints: Single developer, all phases sequential

## 15. Decisions And Tradeoffs

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| Database library | `sqflite_sqlcipher` + `sqflite_common_ffi` | Lean dependency graph, drop-in encrypted replacement for `sqflite` | Less type-safety than `drift`; raw SQL strings in DAOs |
| No background isolates for queries | Main isolate with paginated queries | `sqflite` handles are not transferable across Dart isolates | Large stat queries may briefly block UI; mitigated by pagination and caching |
| No build flavors in v1.0 | Single build configuration | Single developer, no dev/prod environment split needed | Must add flavors later if side-by-side installs or environment config is needed |
| Dual-key encryption | Device key (live DB) + user passphrase (backups) | Transparent daily use + portable backups | Forgotten passphrase = unrecoverable backup |
| No in-memory autocomplete cache | Direct DB query per keystroke (debounced 300 ms) | Always fresh, no stale cache logic, SQLite index is fast enough | Slightly more DB queries; acceptable given < 1 ms query time with index |
| Layer-first over feature-first | Single domain, shared entities across screens | Less indirection for a small app | May need refactoring if the app grows to multiple domains |

## 16. Known Risks And Follow-Ups

- Risk: `sqflite_common_ffi` Windows DLL missing from release build.
  Mitigation: Post-build script to verify `sqlite3.dll` presence; integration test.
- Risk: Unicode NFC normalisation mismatch causes false duplicate detections.
  Mitigation: `unorm_dart` package with unit tests for composed/decomposed equivalence.
- Risk: Live timer causes excessive widget rebuilds.
  Mitigation: `StreamProvider` scoped only to the time display widget.
- Risk: Orphaned open time segments after force-quit.
  Mitigation: `RepairOrphanedSegments` use-case runs on every app startup.
- Risk: Statistics queries slow on large datasets (> 10,000 rows).
  Mitigation: Paginated queries, yield to UI between batches, 10-second cache, optional read-only second DB connection.
- Risk: Future package upgrade silently introduces a transitive networking dependency.
  Mitigation: Pre-commit hook runs offline dep audit; `INTERNET` permission absence provides OS-level backstop.

## 17. Related Documents

- `README.md`
- `CLAUDE.md`
- `flutter_todo_app_plan.md`
- `docs/flutter_project_engineering_standard.md`
- `docs/release_process.md`
- `docs/security.md`
