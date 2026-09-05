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
|   |-- config/                     # app_config, config_service (About screen)
|   |-- constants/                  # app_constants, app_routes
|   |-- errors/                     # exceptions, failures
|   |-- extensions/                 # localization and build context extensions
|   |-- platform/                   # thin Dart sides of the app's own method channels
|   |-- voice/                      # voice_command_parser + the en and ml lexicons
|   `-- utils/                      # date_utils, duration_utils, unicode_utils
|-- data/
|   |-- database/                   # database_service, database_key_service, migrations/
|   |-- dao/                        # todo_dao, time_segment_dao, recurrence_rule_dao, statistics_query_service
|   |-- repositories/               # todo_repository_impl, time_segment_repository_impl
|   |-- backup/                     # backup_service
|   `-- models/                     # freezed entities + todo_status enum
|-- domain/
|   |-- entities/                   # domain models (immutable)
|   |-- repositories/               # abstract interfaces
|   `-- usecases/                   # multi-step business orchestrations
|-- l10n/                           # ARB string files + generated AppLocalizations
|-- application/                    # providers.dart, notifiers
`-- presentation/
    |-- screens/                    # one folder per screen with widgets/ subdirectory
    `-- shared/                     # shared widgets, theme
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/core/` | Pure Dart utilities, config loader, constants, exceptions |
| `lib/l10n/` | ARB translations and generated localization classes |
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
| `StreamProvider` | Pomodoro block countdown (`pomodoroCountdownProvider`, 1 s tick) and the focus-nudge countdown (`focusPulseCountdownProvider`, 1 s tick) |
| `StateProvider` | `timerActivityTickProvider`, bumped on every timer start / stop / pause so the lifecycle watcher can re-check the keep-awake flag without polling |

### Time Tracking Settings

The time-tracking settings are owned by `TimeTrackingSettingsNotifier`
(`lib/application/time_tracking_settings_notifier.dart`), which mirrors
`AppearanceNotifier`: it reads from and writes straight to `SharedPreferences`, and every
default reproduces the app's earlier fixed behaviour.

| Piece | File | Job |
|-------|------|-----|
| `TimeTrackingSettingsNotifier` | `application/time_tracking_settings_notifier.dart` | Holds and saves every setting |
| `PomodoroNotifier` | `application/pomodoro_notifier.dart` | Work / break cycle. Owns no database work — it calls back into `TimeTrackingNotifier` to start and stop segments |
| `FocusPulseNotifier` | `application/focus_pulse_notifier.dart` | The nudge given every so often while a timer runs. Owns the schedule only; the mode, the gap, the clock and the nudge itself are all injected, so it is tested with no platform channel. Stays quiet while Pomodoro is on |
| `TimerPausedStore` / `PausedTodosNotifier` | `application/timer_paused_store.dart` | Which todos show Resume rather than Start, for today only |
| `focus_pulse_rules.dart` | `core/utils/` | Pure Dart: the nudge mode enum, the allowed range for the gap, and the next-pulse instant. Pulses are counted from the start of the running segment, so the schedule cannot drift |
| `time_tracking_rules.dart` | `core/utils/` | Pure Dart: the setting enums, rounding, minimum-length check, next auto-stop instant. No Flutter imports, so every rule is unit tested without a binding |
| `ScreenWakeChannel` | `core/platform/` | Dart side of the keep-awake channel; a no-op off Android |
| `TimerLifecycleWatcher` | `presentation/shared/widgets/` | `WidgetsBindingObserver` wrapping the app: auto-stop, auto-pause on background, keep-awake, and pointing the focus nudge at the running timer |
| `TrackedDurationFormat` | `presentation/shared/utils/` | Inherited widget handing the rounding and format choices to deeply nested report widgets, so Statistics did not need a new constructor argument on every layer |

The settings are read through callbacks (`bool Function()`, `int Function()`) rather than
captured values, so `StartTimeSegment`, `RepairOrphanedSegments` and `TimeTrackingNotifier`
pick up a change on their very next call without being rebuilt.


### Task Defaults

The task defaults are owned by `TaskDefaultsNotifier`
(`lib/application/task_defaults_notifier.dart`), built the same way as
`TimeTrackingSettingsNotifier`: it reads from and writes straight to `SharedPreferences`,
and every default reproduces the behaviour the app had before the setting existed.

| Piece | File | Job |
|-------|------|-----|
| `TaskDefaultsNotifier` | `application/task_defaults_notifier.dart` | Holds and saves every task default |
| `task_default_rules.dart` | `core/utils/` | Pure Dart: the setting enums, the target-time split/join, and the once-a-day carry-over check. No Flutter imports |
| `TodoSortOption` | `core/constants/todo_sort_option.dart` | The 9 day-list orders. It lives in `core/` because the saved default is held in the application layer, which must never import from `presentation/` |
| `day_list_filters.dart` | `presentation/screens/daily_list/` | The show/hide and sink-to-bottom rules, pulled out of the screen so they can be unit tested without a widget tree |
| `CarryOverSheet` | `presentation/screens/daily_list/widgets/` | Finds the unfinished tasks and offers to copy them into today. Copying goes through the existing `CopyTodos` use case, so nothing about the day lock or NFC normalisation is re-implemented |
| `task_default_labels.dart` | `presentation/shared/` | One home for the priority, sort and target names and the priority colours, shared by the settings pages, the form, the tile and the sort menu |

`autocompleteProvider` **watches** the suggestion limit, so changing the count or turning
suggestions off refreshes the field without a restart. A limit of zero means the query is
never run at all.


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
| `TodoEntity` | One task per day | No (freezed) | Includes status, priority, target_seconds, ported_to, source_date, recurrence_rule_id |
| `TimeSegmentEntity` | One start/stop pair | No (freezed) | Includes interrupted, manual flags |
| `RecurrenceRuleEntity` | RRULE template | No (freezed) | iCalendar RRULE string (RFC 5545) |
| `TodoStatus` | Enum: pending, working, completed, dropped, ported | No (enum) | Stored as TEXT in DB |
| `TodoPriority` | Enum: low, normal, high, urgent | No (enum) | Stored as TEXT in DB. Added by migration v9. An unknown stored value reads as `normal` rather than throwing, so a downgrade cannot stop the day list loading |

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
| `/todo/new` | `CreateEditTodoScreen` | Query params `?date=YYYY-MM-DD`, and `title`, `description`, `target`, `priority` when the voice sheet hands over a filled-in draft. Built by `AppRoutes.createTodoPath` so escaping is never forgotten |
| `/todo/:id` | `CreateEditTodoScreen` | Edit mode |
| `/todo/:id/segments` | `TimeSegmentsScreen` | View/add time segments |
| `/focus/:id` | `FocusScreen` | Full-screen focus view for one task |
| `/copy` | `CopyTodosScreen` | Query param `?from=YYYY-MM-DD` |
| `/search` | `SearchResultsScreen` | Query param `?q=<term>` |
| `/backup` | `BackupScreen` | Export / import / list backups |
| `/recurring` | `RecurringTasksScreen` | Manage recurrence rules |
| `/recurring/new` | `RecurrenceEditorScreen` | Create rule |
| `/recurring/:id` | `RecurrenceEditorScreen` | Edit rule |
| `/statistics` | `StatisticsScreen` | Charts and tables |
| `/settings/time-tracking` | `TimeTrackingScreen` | Time tracking settings hub |
| `/settings/time-tracking/auto-stop` | `AutoStopScreen` | Auto-stop mode and custom time |
| `/settings/time-tracking/timer` | `TimerBehaviourScreen` | Single timer, auto-pause, keep awake, minimum length |
| `/settings/time-tracking/pomodoro` | `PomodoroScreen` | Focus block lengths and auto-start |
| `/settings/time-tracking/focus` | `FocusModeScreen` | The nudge mode and gap, and the immersive Focus view switch |
| `/settings/time-tracking/display` | `TimeDisplayScreen` | Rounding, duration format, manual entry default |
| `/settings/task-defaults` | `TaskDefaultsScreen` | Task defaults hub |
| `/settings/task-defaults/new-task` | `DefaultsNewTaskScreen` | Default status, priority, target time |
| `/settings/task-defaults/day-list` | `DefaultsDayListScreen` | Default order, remember order, show/hide and sink finished |
| `/settings/task-defaults/actions` | `DefaultsTaskActionsScreen` | Confirmations and carry-over |
| `/settings/task-defaults/autocomplete` | `DefaultsAutocompleteScreen` | Suggestions on/off and how many |

## 10. Persistence And External Systems

### Local Storage

- Database: `sqflite_sqlcipher` (mobile, AES-256 encrypted) + `sqflite_common_ffi` with SQLCipher (desktop)
- Key-value storage: `shared_preferences` for appearance, language, time-tracking and task-default settings, plus the transient paused-timer marks and the "carry-over last asked on" date. No user task data is ever stored here.
- Schema version: 9. Migration v9 adds `todos.priority` (TEXT, not null, default `normal`) and `todos.target_seconds` (INTEGER, nullable), plus an `idx_todos_priority` index on `(date, priority)`. It is guarded by a `PRAGMA table_info` check, so it is safe to run twice. A backup made by an older build restores as an older database and is upgraded on open; an older P2P peer or handoff file has both columns defaulted in `P2pSyncPayload`.
- Secure storage: Android Keystore (Android) / Windows DPAPI (Windows) for the device-derived database encryption key

### Network

- Network client: None
- Offline behavior: Offline-only (the app has no networking code, no networking permissions, and no networking dependencies)

### Platform Channels Or Native Integrations

- `sqflite_sqlcipher`: Platform channel to native SQLCipher library (mobile)
- `sqflite_common_ffi`: FFI to SQLCipher shared library (desktop)
- `path_provider`: Platform channel to resolve app documents directory
- `file_picker`: Platform channel for file selection dialogs (backup export/import)
- `in.sreerajp.todo/database_key`: Own channel to the Android Keystore for the database key
- `in.sreerajp.todo/screen_wake`: Own channel setting and clearing `FLAG_KEEP_SCREEN_ON` while a timer runs (Android only). Written as a channel rather than a package so the audited dependency list stays unchanged
- `in.sreerajp.todo/app_lock`: Own channel for `FLAG_SECURE` and the device unlock screen (Android only)
- `in.sreerajp.todo/speech` and `in.sreerajp.todo/speech_events`: Own method and event channel pair over Android `SpeechRecognizer`, for the voice task sheet (Android only). The host always asks for the on-device engine and refuses to listen when it cannot, so the offline guarantee holds; see `docs/security.md` section 10. Written as a channel rather than a package for the same reason as the two above

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
