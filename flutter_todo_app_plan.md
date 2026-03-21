# Personal ToDo App — Project Plan

**Flutter SDK:** 3.41.4 (stable) • rev `ff37bef603` • 2026-03-03
**Dart SDK:** 3.11.1 • DevTools 2.54.1
**IDE:** Visual Studio Code
**Project Root:** `L:\Android\SreerajP_ToDo`
**Date:** 2026-03-15
**Version:** 1.3 (updated 2026-03-20)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tools & Technologies](#2-tools--technologies)
3. [Assumptions](#3-assumptions)
4. [Database Schema](#4-database-schema)
5. [App Architecture](#5-app-architecture)
6. [Phase-Wise Plan](#6-phase-wise-plan)
   - [Phase 1 – Project Setup & Foundation](#phase-1--project-setup--foundation)
   - [Phase 2 – Database Layer](#phase-2--database-layer)
   - [Phase 3 – Core ToDo Features](#phase-3--core-todo-features)
   - [Phase 3B – Recurring Tasks](#phase-3b--recurring-tasks)
   - [Phase 4 – Time Tracking](#phase-4--time-tracking)
   - [Phase 5 – Copy / Port Features](#phase-5--copy--port-features)
   - [Phase 5B – Local Backup & Restore](#phase-5b--local-backup--restore)
   - [Phase 6 – Statistics Screen](#phase-6--statistics-screen)
   - [Phase 7 – UI Polish & Unicode Support](#phase-7--ui-polish--unicode-support)
   - [Phase 8 – Testing (Gaps & Integration)](#phase-8--testing-gaps--integration)
   - [Phase 9 – Build & Release](#phase-9--build--release)
7. [Folder Structure](#7-folder-structure)
8. [Risk Register](#8-risk-register)
9. [Timeline Summary](#9-timeline-summary)

---

## 1. Project Overview

A personal, **fully offline** ToDo application built with Flutter targeting **Android**, **iOS**, **Windows**, **Linux**, and **macOS** desktop platforms. The app requires **zero internet access** at any point — installation, first launch, normal use, and background operation all function without any network interface. No data ever leaves the device.

The app allows a user to manage daily tasks with rich metadata: status tracking (completed / dropped / ported), multi-segment time tracking per task per day, copy/port of tasks between days, and statistical reporting.

All text fields (title, description) must fully support **Unicode** characters including CJK, RTL scripts (Arabic, Hebrew), Devanagari, emoji, and other multi-byte code points.

---

## 2. Tools & Technologies

### 2.1 Core Development

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.41.4 (stable) • channel stable • rev `ff37bef603` | Cross-platform UI framework |
| Dart | 3.11.1 (bundled with Flutter 3.41.4) | Programming language |
| Flutter Engine | rev `e4b8dca3f1` • hash `99578ad035` | Native rendering engine |
| Dart DevTools | 2.54.1 | Performance profiling, widget inspector, DB viewer |
| Visual Studio Code | Latest stable | Primary IDE |
| Dart & Flutter VS Code Extension | Latest | Syntax, debug, hot reload |

### 2.2 Flutter Packages (pub.dev)

> **Offline policy:** Every package in this list has been verified to contain zero networking
> dependencies. No package that makes or enables any outbound connection may be added.

| Package | Purpose | Network-free? |
|---------|---------|---------------|
| `sqflite_sqlcipher` | SQLite database driver with AES-256 encryption (mobile) | ✅ Local file I/O only, drop-in replacement for `sqflite` |
| `sqflite_common_ffi` | SQLite FFI layer for Windows, Linux, macOS desktop (with SQLCipher) | ✅ Local file I/O only |
| `path` | Cross-platform file path resolution | ✅ Pure Dart |
| `path_provider` | Locate the app's documents/data directory for DB file | ✅ Local filesystem only |
| `flutter_riverpod` | State management — reactive, testable | ✅ Pure Dart |
| `go_router` | Declarative routing / navigation | ✅ No network calls |
| `intl` | Date / time formatting, localisation | ✅ Bundled locale data |
| `fl_chart` | Charts and graphs for the statistics screen | ✅ Pure Flutter rendering |
| `table_calendar` | Calendar widget for day picker | ✅ Pure Flutter widget |
| `uuid` | UUID v4 generation for record primary keys | ✅ Pure Dart / CSPRNG |
| `flutter_localizations` | Localisation support (LTR / RTL layouts) | ✅ Bundled in Flutter SDK |
| `freezed` + `freezed_annotation` | Immutable data model code generation | ✅ Dev-time codegen only |
| `json_serializable` + `json_annotation` | JSON serialisation for model classes | ✅ Dev-time codegen only |
| `build_runner` | Code generation runner | ✅ Dev-time only |
| `mocktail` | Mocking library for unit / widget tests | ✅ Test-only |
| `flutter_test` | Built-in widget testing (Flutter SDK) | ✅ Test-only |
| `unorm_dart` | Unicode NFC normalisation (UAX #15) | ✅ Pure Dart, zero deps — **audit before adding** |
| `file_picker` | File picker for backup export/import location | ✅ Platform channels only — **audit transitive deps before adding** |
| `rrule` | iCalendar RRULE parsing and date expansion (RFC 5545) | ✅ Pure Dart — **audit transitive deps before adding** |
| `flutter_native_splash` | Splash screen code generation | ✅ Dev-time only — **audit before adding** |

> **New/changed packages (v1.3):** `sqflite_sqlcipher` replaces `sqflite` for encrypted storage.
> `unorm_dart`, `file_picker`, and `flutter_native_splash` must each pass the offline dep audit
> (`flutter pub deps` check for networking transitive deps) before being added to the project.
> If any fails, see their respective amendment sections for fallback approaches.

### 2.3 VS Code Extensions

| Extension | Purpose |
|-----------|---------|
| Dart | Dart language support |
| Flutter | Flutter device management, hot reload |
| SQLite Viewer | Inspect the SQLite DB file during development |
| Error Lens | Inline error highlighting |
| Pubspec Assist | Quick `pub add` from VS Code |
| GitLens | Source control insights |

### 2.4 Supporting Tools

| Tool | Purpose |
|------|---------|
| Git | Source control |
| DB Browser for SQLite | Desktop tool for manual DB inspection |
| Android Studio (emulator only) | Android emulator / ADB (VS Code remains primary IDE) |
| Xcode (macOS only) | iOS / macOS build chain |

### 2.5 Flutter 3.41.4 Features Leveraged in This Project

| Feature | How It Is Used |
|---------|---------------|
| **Synchronous Image Decoding** (`decodeImageFromPixelsSync`) | Statistics screen decodes chart thumbnail assets in the same frame, eliminating a frame of lag on first render |
| **Platform-aware asset bundling** (`platforms:` key in pubspec.yaml) | Windows-specific `sqlite3.dll` and platform icons bundled only for their respective targets — leaner APK on Android |
| **`go_router` typed `pop<T>()`** | Copy/port wizard uses `context.pop(result)` from go_router 14.x to return the selected items and target date to the calling screen in a single call. All navigation goes through go_router exclusively |
| **Public 2026 release windows** | Dependency upgrade sprints are scheduled against the published 2026 stable cadence, avoiding mid-cycle SDK surprises |
| **Material / Cupertino package decoupling** | UI design library packages can be updated independently of the SDK, reducing upgrade risk for design-only changes |
| **Content-sized Flutter views** | Enables future embedding of the todo widget into a native host app (e.g., a home screen widget) without fixed dimensions |

---

## 3. Assumptions

| ID | Assumption |
|----|------------|
| A-1 | The app is **single-user** — no sync, no cloud backend. All data lives in a local SQLite file. |
| A-1a | The app is **fully offline**. It requires zero internet connectivity at any point. No feature degrades, warns, or fails when the device is offline or has no network interface at all. |
| A-1b | **No data ever leaves the device**. There is no sync, export-to-cloud, crash reporting, or telemetry of any kind. |
| A-1c | **No `INTERNET` permission** is declared in `AndroidManifest.xml`. The Android OS will block all network access at the OS level as a result, providing a hard enforcement layer beyond code. |
| A-1d | **All assets are bundled** in the app binary. No fonts, images, or resources are fetched from the network at runtime. |
| A-2 | Target platforms in **Phase 1 scope**: Android and Windows desktop. iOS, Linux, macOS are deferred to a future release but the architecture must not block them. |
| A-3 | A **"day"** is defined as a calendar date in the device's local timezone (`DateTime.now()` with `toLocal()`). No UTC offset handling is required for the MVP. |
| A-4 | **"Previous day lock"** means: any ToDo item whose `date` is strictly before today's calendar date becomes read-only. Start/stop recording, status changes, and edits to title/description are all blocked. The lock is enforced in the UI and the data layer. |
| A-5 | **Terminal status lock**: once a ToDo is marked as `completed` or `dropped`, no new time segments can be started or stopped for that item. Any running timer is stopped. The title, description, and status can still be read but not changed. In **statistics**, time spent on completed tasks is categorised as **productive time**, while time spent on dropped tasks is categorised as **sunk/dropped time** — they are reported separately. |
| A-6 | A title is **unique per day** — two ToDo items on the same calendar date cannot share an identical title (case-sensitive, Unicode-normalised to NFC before the uniqueness check). |
| A-7 | `sqflite` + `sqflite_common_ffi` will be used instead of `drift` to keep the dependency graph lean. This can be revisited if type-safety concerns arise during Phase 2. |
| A-8 | **"Dropped"** and **"ported"** are terminal statuses alongside "completed". Once set, they cannot be reversed (they can only be changed to another terminal status by explicit user action). Terminal status changes are protected by an **undo mechanism**: SnackBar (5-second timeout) + persistent undo button in the app bar. Additionally, "dropped" and "ported" require a **confirmation dialog** before the change is applied. |
| A-9 | **Ported status** stores the *target date* as metadata (the date the item was ported to). Porting optionally creates a **copy** of the ToDo on the target date with `status = pending`. |
| A-10 | **Time segments**: a segment is a (start_time, end_time) pair. A running segment has `end_time = NULL`. Only one segment may be open (running) at a time per ToDo per day. |
| A-10a | **Multiple simultaneous timers** are permitted across different todos. A user may track time on "Meeting" and "Note-taking" concurrently. The "one open segment per todo" rule (A-10) remains, but there is no global single-timer constraint across todos. If a future version needs single-active-timer behaviour, it can be enforced in the `StartTimeSegment` use-case without schema changes. |
| A-11 | Statistics are computed **on-the-fly** via SQL aggregate queries — no separate stats table is maintained. |
| A-12 | The app will support **light and dark themes** using Flutter's `ThemeData`. |
| A-13 | No user authentication is required. |
| A-14 | **Autocomplete for title** draws from all distinct titles ever stored in the database across all dates (global autocomplete pool), not just the current day. Autocomplete queries the DB directly per keystroke (debounced 300 ms) — no in-memory cache is maintained. |
| A-15 | All string storage in SQLite uses **UTF-8** (SQLite's default). Flutter/Dart strings are UTF-16 internally; the `sqflite` package transparently handles the conversion. |
| A-16 | Minimum Android API level: **21** (Android 5.0 Lollipop). Minimum Windows: Windows 10. |

---

## 4. Database Schema

### 4.1 Entity Relationship Overview

```
todos (1) ──────────────────── (N) time_segments
  │
  └── date (FK relationship via todo_date field)
```

### 4.2 Tables

#### Table: `todos`

Stores one row per ToDo item per day. A ToDo item that is "ported" to another day produces a new row on the target date (a copy), not a foreign-key reference.

```sql
CREATE TABLE todos (
    id           TEXT PRIMARY KEY,          -- UUID v4
    date         TEXT NOT NULL,             -- ISO-8601 date: 'YYYY-MM-DD'
    title        TEXT NOT NULL,             -- Unicode title (NFC-normalised)
    description  TEXT,                      -- Unicode description, nullable
    status       TEXT NOT NULL              -- 'pending' | 'completed'
                   DEFAULT 'pending',       --   | 'dropped' | 'ported'
    ported_to    TEXT,                      -- ISO-8601 target date, only if status='ported'
    source_date  TEXT,                      -- ISO-8601 date copied/ported from, nullable
    recurrence_rule_id TEXT                 -- FK → recurrence_rules.id, nullable
                   REFERENCES recurrence_rules(id)
                   ON DELETE SET NULL,       -- if rule deleted, generated todos remain
    sort_order   INTEGER NOT NULL           -- user-defined display order within the day
                   DEFAULT 0,
    created_at   TEXT NOT NULL,             -- ISO-8601 datetime UTC
    updated_at   TEXT NOT NULL,             -- ISO-8601 datetime UTC
    UNIQUE (date, title)                    -- enforces uniqueness per day
);

CREATE INDEX idx_todos_date ON todos (date);
CREATE INDEX idx_todos_title ON todos (title);  -- supports autocomplete + search
CREATE INDEX idx_todos_recurrence ON todos (recurrence_rule_id);
```

#### Table: `recurrence_rules`

Stores recurrence templates. Each rule generates `todos` rows on matching dates.

```sql
CREATE TABLE recurrence_rules (
    id           TEXT PRIMARY KEY,          -- UUID v4
    title        TEXT NOT NULL,             -- Template title (NFC-normalised)
    description  TEXT,                      -- Template description, nullable
    rrule        TEXT NOT NULL,             -- iCalendar RRULE string (RFC 5545)
    start_date   TEXT NOT NULL,             -- YYYY-MM-DD when recurrence begins
    end_date     TEXT,                      -- YYYY-MM-DD when recurrence ends (NULL = infinite)
    active       INTEGER NOT NULL           -- 1 = active, 0 = paused
                   DEFAULT 1,
    created_at   TEXT NOT NULL,             -- ISO-8601 datetime UTC
    updated_at   TEXT NOT NULL              -- ISO-8601 datetime UTC
);
```

> **RRULE examples:**
> - Daily: `FREQ=DAILY`
> - Every weekday: `FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR`
> - Every Monday and Thursday: `FREQ=WEEKLY;BYDAY=MO,TH`
> - Every 3 days: `FREQ=DAILY;INTERVAL=3`
> - First Monday of every month: `FREQ=MONTHLY;BYDAY=1MO`
> - Every year on March 15: `FREQ=YEARLY;BYMONTH=3;BYMONTHDAY=15`
> - Daily until a specific date: `FREQ=DAILY;UNTIL=20261231`

#### Table: `time_segments`

Stores one row per start/stop pair for a ToDo item on a given day.

```sql
CREATE TABLE time_segments (
    id               TEXT PRIMARY KEY,           -- UUID v4
    todo_id          TEXT NOT NULL               -- FK → todos.id
                       REFERENCES todos(id)
                       ON DELETE CASCADE,
    start_time       TEXT NOT NULL,              -- ISO-8601 datetime (local)
    end_time         TEXT,                       -- ISO-8601 datetime (local), NULL if running
    duration_seconds INTEGER                     -- computed and stored on segment close
                       DEFAULT NULL,
    interrupted      INTEGER NOT NULL            -- 1 = auto-closed by orphan repair
                       DEFAULT 0,
    manual           INTEGER NOT NULL            -- 1 = manually entered, 0 = recorded via start/stop
                       DEFAULT 0,
    created_at       TEXT NOT NULL
);

CREATE INDEX idx_time_segments_todo_id ON time_segments (todo_id);
```

> **Note (v1.2):** `source_date` on `todos`, and `interrupted` + `manual` on `time_segments`
> are included in `migration_v1.dart` from day one. Since the app has not shipped, there is no
> existing user data to migrate. `migration_v2.dart` is reserved for post-launch schema changes.

### 4.3 Key Queries

```sql
-- Autocomplete: distinct titles matching prefix
SELECT DISTINCT title FROM todos
WHERE title LIKE ? || '%'
ORDER BY title
LIMIT 20;

-- Cross-day search by title substring
SELECT * FROM todos
WHERE title LIKE '%' || ? || '%'
ORDER BY date DESC
LIMIT ?;

-- All ToDos for a day
SELECT * FROM todos WHERE date = ? ORDER BY sort_order, created_at;

-- Running segment for a ToDo (at most one)
SELECT * FROM time_segments
WHERE todo_id = ? AND end_time IS NULL
LIMIT 1;

-- Total time spent on a ToDo (across all segments for a day)
SELECT COALESCE(SUM(duration_seconds), 0) AS total_seconds
FROM time_segments ts
JOIN todos t ON ts.todo_id = t.id
WHERE t.id = ?;

-- Statistics: counts per day (paginated)
SELECT
    date,
    COUNT(*)                                       AS total,
    SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN status='dropped'    THEN 1 ELSE 0 END) AS dropped,
    SUM(CASE WHEN status='ported'    THEN 1 ELSE 0 END) AS ported,
    SUM(CASE WHEN status='pending'   THEN 1 ELSE 0 END) AS pending
FROM todos
GROUP BY date
ORDER BY date DESC
LIMIT ? OFFSET ?;

-- Statistics: time spent per (todo title, date) — paginated
SELECT t.title, t.date,
       COALESCE(SUM(ts.duration_seconds), 0) AS total_seconds
FROM todos t
LEFT JOIN time_segments ts ON ts.todo_id = t.id
GROUP BY t.title, t.date
ORDER BY t.date DESC, t.title
LIMIT ? OFFSET ?;
```

---

## 5. App Architecture

### 5.1 Pattern: Layered with Use-Cases

```
Presentation   →  Flutter Widgets + Riverpod consumers
Application    →  StateNotifiers, providers
Domain         →  Use-Case classes (multi-step orchestration) + Abstract repository interfaces + Entities
Data           →  Repository impls + DAOs + Query services + DB models + Migrations + Backup
Core           →  Utils, constants, exceptions — pure Dart, no Flutter imports
```

**Call chain:**
```
Widget → Provider/Notifier → UseCase (if multi-step) → Repository → DAO → sqflite
Widget → Provider/Notifier → Repository → DAO → sqflite  (simple CRUD)
```

Simple CRUD operations (findByDate, insert a pending todo) go directly through
Notifier → Repository → DAO. Use-cases are reserved for multi-step business orchestrations
where multiple repository/DAO calls must be coordinated (e.g., marking completed requires
closing an open segment AND updating status).

**Use-case classes** (`lib/domain/usecases/`):

| Use-case | Responsibility |
|----------|----------------|
| `MarkTodoCompleted` | Close open segment → set status to completed → refresh state |
| `MarkTodoDropped` | Close open segment → set status to dropped → refresh state |
| `PortTodo` | Validate target date → create copy on target → mark source as ported (transaction) |
| `CopyTodos` | Conflict check per title → batch insert → return skip list |
| `StartTimeSegment` | Check day lock → check completed lock → check no running segment → insert |
| `RepairOrphanedSegments` | Startup scan: close all orphaned segments with zero duration |
| `GenerateRecurringTasks` | On app startup: expand all active RRULE rules for today + next 7 days, create missing todos |

### 5.2 State Management: Riverpod

- **`StateNotifierProvider`** per screen (DailyTodoNotifier, StatisticsNotifier)
- **`FutureProvider`** for async DB reads and autocomplete queries
- **`FutureProvider.family`** for parameterised queries (autocomplete prefix, search query)
- **`StreamProvider`** for the live timer only (elapsed seconds on a running time segment)
- **`Provider`** for singleton services (DatabaseService, BackupService)

### 5.3 Navigation: go_router

| Route | Screen | Notes |
|-------|--------|-------|
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

### 5.4 Provider Registry

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
| `recurrenceRuleDaoProvider` | `Provider<RecurrenceRuleDao>` | DAO for recurrence rules |
| `recurrenceRulesProvider` | `StateNotifierProvider` | List of all recurrence rules |
| `statisticsProvider` | `StateNotifierProvider` | Paginated aggregated stats |

---

## 6. Phase-Wise Plan

---

### Phase 1 – Project Setup & Foundation

**Goal:** A runnable skeleton with navigation, theming, folder structure, and development
workflow tooling in place.

**Estimated Duration:** 2.5–3.5 days

#### Tasks

1. **Scaffold the project**
   ```powershell
   # Run from L:\Android\SreerajP_ToDo
   # If starting fresh:
   cd L:\Android\SreerajP_ToDo
   flutter create --org com.sreerajp --platforms android,windows .
   code .
   ```

2. **Add all dependencies** to `pubspec.yaml`
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_localizations:
       sdk: flutter
     sqflite: ^2.4.1
     sqflite_common_ffi: ^2.3.4
     path: ^1.9.0
     path_provider: ^2.1.4
     flutter_riverpod: ^2.6.1
     go_router: ^14.8.1
     intl: ^0.20.2
     fl_chart: ^0.70.2
     table_calendar: ^3.2.0
     uuid: ^4.5.1
     freezed_annotation: ^2.4.4
     json_annotation: ^4.9.0
     unorm_dart: ^2.0.0          # NFC normalisation — audit transitive deps first
     file_picker: ^8.0.0         # Backup file selection — audit transitive deps first

   dev_dependencies:
     flutter_test:
       sdk: flutter
     build_runner: ^2.4.14
     freezed: ^2.5.7
     json_serializable: ^6.9.0
     mocktail: ^1.0.4
     flutter_native_splash: ^2.4.0  # Splash screen — audit transitive deps first
   ```

3. **Run `flutter pub get`** and verify no dependency conflicts.

4. **Run the offline dependency audit** — must return zero matches before proceeding:
   ```powershell
   flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio|chopper|retrofit|amplitude|mixpanel|datadog"
   # Expected output: zero matches
   ```
   If any matches appear, identify the transitive chain with:
   ```powershell
   flutter pub deps
   ```
   and remove or replace the offending package.

   > **NFC fallback:** If `unorm_dart` fails the audit, remove it and implement a minimal NFC
   > normaliser in `lib/core/utils/unicode_utils.dart` using Dart's native `String.runes` and
   > the UAX #15 canonical composition algorithm (~200 lines of pure Dart).
   >
   > **File picker fallback:** If `file_picker` fails the audit, use `path_provider` to write
   > backups to a fixed directory (e.g., Downloads) without a picker UI.

5. **Verify `AndroidManifest.xml` contains no network permissions:**
   ```powershell
   Select-String -Path "android\app\src\main\AndroidManifest.xml" -Pattern "INTERNET|NETWORK"
   # Expected output: zero matches
   ```

6. **Configure `sqflite_common_ffi`** in `main.dart` for desktop:
   ```dart
   void main() {
     WidgetsFlutterBinding.ensureInitialized();
     if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
       sqfliteFfiInit();
       databaseFactory = databaseFactoryFfi;
     }
     runApp(const ProviderScope(child: TodoApp()));
   }
   ```

7. **Set up folder structure** (see Section 7).

8. **Configure `go_router`** — define all routes with placeholder screens (including `/search`
   and `/backup`).

9. **Implement theme** — light and dark `ThemeData` with consistent colour palette and Unicode-compatible font (e.g., `Noto Sans` or system default). Ensure text fields use `TextInputType.multiline` and `TextCapitalization.none` to not interfere with non-Latin scripts. Fonts must be **bundled** in `assets/fonts/` — no Google Fonts network loader.

10. **Set up pre-commit Git hook** for automated checks:
    ```powershell
    # Create .githooks/pre-commit (see content below)
    git config core.hooksPath .githooks
    ```

    `.githooks/pre-commit`:
    ```bash
    #!/usr/bin/env bash
    set -e

    echo "=== Pre-commit: flutter analyze ==="
    flutter analyze --no-fatal-infos

    echo "=== Pre-commit: offline dep audit ==="
    if flutter pub deps 2>&1 | grep -iE "http|socket|firebase|supabase|sentry|crashlytics|analytics|dio"; then
      echo "BLOCKED: networking dependency detected"
      exit 1
    fi

    echo "=== Pre-commit: manifest check ==="
    if grep -iE "INTERNET|NETWORK_STATE" android/app/src/main/AndroidManifest.xml; then
      echo "BLOCKED: network permission found in AndroidManifest.xml"
      exit 1
    fi

    echo "=== Pre-commit: flutter test ==="
    flutter test

    echo "=== All checks passed ==="
    ```

11. **Verify hot reload** works on Android emulator and Windows desktop.

#### Deliverables
- Running app on both targets showing placeholder screens.
- All routes navigable (including `/search` and `/backup`).
- Offline dependency audit passes with zero networking matches.
- `AndroidManifest.xml` confirmed to have no `INTERNET` or network permissions.
- Pre-commit hook installed and functional.

---

### Phase 2 – Database Layer

**Goal:** A fully tested data access layer with complete initial schema and all required CRUD operations.

**Estimated Duration:** 3–4 days

#### Tasks

1. **Create `DatabaseService`** singleton
   - Opens/creates the **encrypted** SQLite file at the platform-appropriate path via `path_provider`.
   - Uses `sqflite_sqlcipher` (mobile) / `sqflite_common_ffi` with SQLCipher (desktop) for
     **AES-256 encryption at rest**.
   - **Encryption key strategy (dual-key):**
     - **Live database:** device-derived key using Android Keystore (Android) or Windows DPAPI
       (Windows). Generated on first launch, stored in the platform's secure key store,
       retrieved transparently on every launch. The user never sees or manages this key.
     - **Backup files:** re-encrypted with a **user-set passphrase** during export. This makes
       backups portable across devices and survivable across factory resets. The passphrase is
       entered by the user at export time and again at import time. It is never stored on disk.
   - Runs `CREATE TABLE IF NOT EXISTS` migrations in `onCreate` via `migration_v1.dart`.
   - The initial schema includes **all** columns (`source_date` on `todos`; `interrupted` and
     `manual` on `time_segments`) — no `ALTER TABLE` migrations needed for v1.0.
   - Supports schema versioning via `onUpgrade` for future migration support.
   - Enables WAL journal mode and foreign key enforcement:
     ```sql
     PRAGMA journal_mode=WAL;
     PRAGMA foreign_keys=ON;
     ```

2. **Create Dart model classes** (with `freezed`)
   - `TodoEntity` — mirrors the `todos` table (includes `source_date` field).
   - `TimeSegmentEntity` — mirrors the `time_segments` table (includes `interrupted` and `manual` fields).
   - `TodoStatus` enum: `pending`, `completed`, `dropped`, `ported`.

3. **Create `TodoDao`** — all SQL for the `todos` table:
   - `insert(TodoEntity todo)`
   - `update(TodoEntity todo)` — also bumps `updated_at`
   - `delete(String id)`
   - `findByDate(String date) → List<TodoEntity>`
   - `findById(String id) → TodoEntity?`
   - `existsTitleOnDate(String title, String date, {String? excludeId}) → bool` — for uniqueness check
   - `getAllDistinctTitles(String prefix) → List<String>` — autocomplete
   - `searchByTitle(String query, {int limit = 50}) → List<TodoEntity>` — cross-day search

4. **Create `TimeSegmentDao`** — all SQL for the `time_segments` table:
   - `insert(TimeSegmentEntity seg)`
   - `closeSegment(String segId, DateTime endTime)` — sets `end_time` and computes `duration_seconds`
   - `findByTodoId(String todoId) → List<TimeSegmentEntity>`
   - `findRunningSegment(String todoId) → TimeSegmentEntity?`
   - `deleteByTodoId(String todoId)` — cascade handled by FK but exposed explicitly

5. **Create `StatisticsQueryService`** — read-only aggregate queries (not a CRUD DAO):
   - `getCountsPerDay({int limit = 20, int offset = 0}) → List<DayStats>`
   - `getTimePerTodoPerDay({int limit = 20, int offset = 0}) → List<TodoTimeStats>`
   - `getTimePerTodo(String title) → List<TodoTimeStats>`

6. **Create abstract repository interfaces** in `lib/domain/repositories/`:
   - `TodoRepository` (abstract)
   - `TimeSegmentRepository` (abstract)

7. **Create repository implementations** in `lib/data/repositories/`:
   - `TodoRepositoryImpl` — implements `TodoRepository`
   - `TimeSegmentRepositoryImpl` — implements `TimeSegmentRepository`

8. **Write unit tests** for all DAO methods and `StatisticsQueryService` using an **in-memory SQLite** database.

#### Deliverables
- Passing unit tests for all DAO and query service operations.
- Database file created correctly on first app launch on both platforms.
- Complete initial schema with all columns — no deferred `ALTER TABLE` for v1.0.

---

### Phase 3 – Core ToDo Features

**Goal:** Full CRUD for ToDo items on a day, with autocomplete, status changes, undo, bulk operations, cross-day search, and the day lock mechanism.

**Estimated Duration:** 5.5–6.5 days

#### Tasks

1. **Daily ToDo List Screen (`/day/:date`)**
   - Header: formatted date (using `intl` `DateFormat`), navigation arrows to previous/next day, today button.
   - A `table_calendar` mini-calendar widget accessible via an icon for date jumping.
   - A **search icon** in the app bar that navigates to `/search` for cross-day title search.
   - List of ToDo items for the day, ordered by `sort_order`.
   - Each list tile shows: title, status badge (colour-coded), total time spent (hh:mm:ss), a start/stop button, action menu (edit, delete, port, copy).
   - **Lock indicator**: items from a past date show a padlock icon; all interactive controls are disabled.
   - FAB to add a new ToDo (disabled for past dates).
   - **Multi-select mode**: long-press on a list tile enters multi-select mode. In multi-select
     mode, the app bar transforms to show:
     - "X selected" count
     - **"Complete All"** action button
     - **"Mark Dropped"** action button
     - **"Copy"** action button (navigates to `/copy` with pre-selected items)
     - Bulk **port** is excluded — each port requires a unique target date, making it too
       complex for bulk action.
   - All bulk status changes are wrapped in a **single DB transaction**.
   - A single **undo SnackBar** reverts the entire batch.

2. **Create / Edit ToDo Screen (`/todo/new` and `/todo/:id`)**
   - **Title field**: `TextFormField` with Unicode support (`textDirection` auto-detected via `Bidi`), validator for mandatory + uniqueness-per-day check, and an `Autocomplete<String>` widget backed by `TodoDao.getAllDistinctTitles()`. The autocomplete fires on every keystroke with a debounce of 300 ms, querying the DB directly (no in-memory cache).
   - **Description field**: multiline `TextFormField`, optional, no length limit, Unicode-aware.
   - **Status selector**: segmented control — `Pending`, `Completed`, `Dropped`, `Ported`.
   - When status is set to `Ported`, a **date picker** appears to select the target day. The target date must be ≥ tomorrow.
   - Save button performs: NFC-normalise title → uniqueness check → upsert.

3. **Status Change Logic (via Use-Cases)**
   - `MarkTodoCompleted(todoId)`: sets status = completed, closes any open time segment.
   - `MarkDropped(todoId)`: sets status = dropped.
   - `PortTodo(todoId, targetDate)`:
     - Sets status = ported, stores `ported_to` date.
     - Creates a copy of the ToDo on `targetDate` with status = pending, a fresh UUID, and
       `source_date` set to the original todo's date.
     - Does NOT copy time segments (time tracking starts fresh on the target day).
   - All state-changing methods check the **day lock** and throw `DayLockedException` if the todo's date is in the past.
   - **Confirmation dialogs**: Changing status to **dropped** or **ported** requires a
     confirmation dialog before the change is applied ("Mark [title] as dropped?" / "Port
     [title] to [date]?"). Marking as **completed** does not require confirmation (most
     common action, should be fast).
   - **Undo mechanism (hybrid — SnackBar + persistent button)**:
     After any status change, the `DailyTodoNotifier` pushes an entry onto an **undo stack**
     (last 5 changes):
     ```dart
     ({String todoId, TodoStatus oldStatus, TodoStatus newStatus, String? copiedTodoId})
     ```
     Two undo surfaces are provided:
     1. A `SnackBar` with an **"Undo"** action (5-second auto-dismiss timeout) — for
        immediate "oops" recovery.
     2. A persistent **undo button (↩)** in the app bar, visible whenever the undo stack
        is non-empty. Tapping it pops and reverts the most recent change.
     The undo stack clears when the user navigates to a different day or after 2 minutes
     of inactivity.
     `undoLastStatusChange()` reverts the status and, if the change was a port, deletes the
     copy created on the target date (within a transaction).

4. **Autocomplete Service**
   - `autocompleteProvider(prefix)` is a `FutureProvider.family` that calls
     `TodoDao.getAllDistinctTitles(prefix)` directly on each debounced keystroke (300 ms).
   - The DAO query uses `LIKE ? || '%'` with `LIMIT 20`, backed by `idx_todos_title`. Expected
     query time: < 1 ms even with 10,000+ rows.
   - No in-memory cache is maintained. No stale-cache refresh logic.

5. **Cross-Day Search**
   - `searchResultsProvider(query)` is a `FutureProvider.family` that calls
     `TodoDao.searchByTitle(query)`.
   - `SearchResultsScreen` (`/search?q=...`) displays results grouped by date.
   - Tapping a result navigates to `/day/:date`.

6. **Day Lock Enforcement**
   - `TodoRepository` methods accept a `bypassLock` flag (default false) — for future admin/export use.
   - The UI additionally greys out and disables all interactive controls when displaying a past date.

7. **Delete ToDo**
   - Requires confirmation dialog.
   - Cascades delete of all `time_segments` via DB foreign key.
   - Disabled for past dates.

8. **Drag-to-reorder** within the day list — updates `sort_order` for all affected rows in a single transaction.

#### Test Deliverables (written during this phase)
- Repository unit tests: day lock enforcement, status transitions, title uniqueness.
- Use-case unit tests: `MarkTodoCompleted`, `PortTodo`, `CopyTodos`.
- Widget tests: daily list screen (renders todos, lock icon for past date), create/edit screen
  (mandatory title validation, autocomplete suggestions).
- Undo tests: mark completed → undo → status reverts; mark ported → undo → copy deleted.
- Bulk tests: select 3 → Complete All → all 3 completed, open segments closed.

#### Deliverables
- Full CRUD working end-to-end.
- Autocomplete functioning for Unicode titles (Latin, CJK, Arabic tested).
- Cross-day search working with Unicode support.
- Undo SnackBar for all status changes.
- Multi-select bulk status change.
- Day lock visually and functionally enforced.

---

### Phase 3B – Recurring Tasks

**Goal:** Allow users to define recurrence rules (daily, weekly, monthly, yearly — full
iCalendar RRULE support) so that tasks are auto-created on matching dates without manual
copy/port.

**Estimated Duration:** 3–4 days

#### Tasks

1. **Add `rrule` package** — pure Dart iCalendar RRULE parser and date expander (RFC 5545).
   Audit transitive deps before adding. If it fails the offline dep audit, implement a
   subset RRULE parser in `lib/core/utils/rrule_utils.dart` covering FREQ, INTERVAL, BYDAY,
   BYMONTH, BYMONTHDAY, UNTIL, and COUNT.

2. **Create `RecurrenceRuleDao`** — CRUD for the `recurrence_rules` table:
   - `insert(RecurrenceRuleEntity rule)`
   - `update(RecurrenceRuleEntity rule)`
   - `delete(String id)`
   - `findAll() → List<RecurrenceRuleEntity>` — all rules (active and paused)
   - `findActive() → List<RecurrenceRuleEntity>` — only active rules
   - `findById(String id) → RecurrenceRuleEntity?`

3. **Create `RecurrenceRuleEntity`** model (freezed) in `lib/data/models/`:
   - Fields: `id`, `title`, `description`, `rrule`, `startDate`, `endDate`, `active`,
     `createdAt`, `updatedAt`.

4. **Create `GenerateRecurringTasks` use-case** (`lib/domain/usecases/`):
   - Called on **app startup** (after `RepairOrphanedSegments`).
   - For each active recurrence rule:
     1. Expand the RRULE to get all matching dates in the range `[today, today + 7 days]`.
     2. For each matching date, check if a todo with the same title already exists on that
        date (via `TodoDao.existsTitleOnDate()`).
     3. If not: insert a new `TodoEntity` with `status = pending`, `recurrence_rule_id` set,
        and `sort_order` appended at the end.
     4. If yes: skip (the user may have already created, edited, or ported the task manually).
   - NFC-normalise the title before the existence check.
   - Wrap all inserts in a single transaction per rule.
   - Log the number of tasks generated (for debugging, not user-visible).

5. **Recurring Tasks Management Screen** (`/recurring`):
   - Lists all recurrence rules with: title, RRULE description in human-readable form
     (e.g., "Every weekday", "Every Monday and Thursday"), start date, end date (or
     "No end date"), active/paused toggle.
   - Tap a rule to edit. Swipe to delete (with confirmation dialog).
   - FAB to create a new rule.
   - Accessible from the main navigation rail / app bar overflow menu.

6. **Recurrence Editor Screen** (`/recurring/new` and `/recurring/:id`):
   - **Title field** — with autocomplete (same as create/edit todo).
   - **Description field** — optional.
   - **Frequency picker**: segmented control — `Daily`, `Weekly`, `Monthly`, `Yearly`.
   - **Interval field**: "Every N [days/weeks/months/years]" (default 1).
   - **Day-of-week picker** (for weekly): toggle buttons for Mon–Sun.
   - **Day-of-month picker** (for monthly): date number or ordinal weekday
     (e.g., "1st Monday", "Last Friday").
   - **Month picker** (for yearly): month selector + day-of-month.
   - **Start date**: date picker (default today).
   - **End date**: optional date picker, or "No end date" toggle.
   - **Preview**: shows the next 5 occurrence dates based on the current RRULE.
   - Save button constructs the RRULE string and validates it.

7. **Visual indicator on generated todos**: Tasks created by a recurrence rule show a
   small **repeat icon (🔁)** next to the title on the daily list. Tapping it navigates
   to the rule editor for that rule.

8. **Integration with existing features**:
   - Generated recurring tasks behave identically to manually created tasks — they can
     be edited, have their status changed, be time-tracked, copied, ported, deleted.
   - Editing the title of a generated task **does not** affect the recurrence rule or
     future generated tasks. It only changes that specific instance.
   - Deleting a generated task **does not** stop the recurrence. The rule will regenerate
     it on the next app startup if the date is still in the 7-day window.
   - To stop a recurrence: pause or delete the rule from `/recurring`.

#### Test Deliverables (written during this phase)
- Unit tests: `RecurrenceRuleDao` CRUD.
- Unit tests: `GenerateRecurringTasks` — daily rule generates 8 tasks (today + 7 days),
  weekly rule generates correct subset, monthly rule handles month boundaries.
- Unit tests: duplicate detection — rule does not regenerate a task that already exists.
- Unit tests: paused rule generates zero tasks.
- Unit tests: rule with `end_date` in the past generates zero tasks.
- Widget tests: recurrence editor screen renders frequency picker and preview.

#### Deliverables
- Recurrence rules can be created, edited, paused, and deleted.
- Tasks are auto-generated on app startup for today + 7 days.
- Duplicate detection prevents double-creation.
- Generated tasks are visually distinguishable but functionally identical to manual tasks.

---

### Phase 4 – Time Tracking

**Goal:** Reliable multi-segment start/stop time tracking per ToDo per day, including manual entry.

**Estimated Duration:** 4–5 days

> **Precision note:** `duration_seconds` is stored as a whole integer (truncated, not rounded).
> The sub-second discrepancy between `end_time - start_time` and `duration_seconds` is
> acceptable for a personal todo app. All display formatting uses `duration_seconds` for
> consistency.

#### Tasks

1. **Start / Stop Button logic**
   - Shown on each list tile next to the ToDo title.
   - **Start** (▶): enabled only when status = pending and date = today.
     - Orchestrated via the `StartTimeSegment` use-case: checks day lock → completed lock →
       no running segment → inserts a new `TimeSegmentEntity` with `end_time = NULL`.
   - **Stop** (⏹): visible only when a segment is open.
     - Calls `TimeSegmentDao.closeSegment()` — records `end_time = DateTime.now()` and `duration_seconds`.
   - A running segment's live elapsed time is shown using a `Stream`-based timer (ticks every second via `Stream.periodic`) rendered in the list tile.

2. **TimeSegmentNotifier** (Riverpod)
   - Exposes `startSegment(String todoId)` and `stopSegment(String todoId)`.
   - Exposes a derived `isRunning(String todoId) → bool`.
   - Exposes `totalDuration(String todoId) → Duration` — sums all closed segment durations plus any live running duration.

3. **Time Segments Detail View**
   - Accessible from the ToDo detail screen.
   - Lists all segments in a table: `#`, `Start`, `End`, `Duration`, `Type` (auto/manual badge).
   - Running segment shown with blinking indicator.
   - Interrupted segments (auto-closed by orphan repair) show a warning icon.
   - Manual segments show an "M" badge.
   - Segments for past-date ToDos shown read-only.
   - Past-date segments cannot be manually edited (the start/stop controls are not shown for past dates).

4. **Guards and validation**
   - Cannot start a segment if: date ≠ today, status ≠ pending, or another segment is already running on this ToDo.
   - Cannot stop a segment if: no running segment exists or date ≠ today.
   - On app launch, the `RepairOrphanedSegments` use-case runs: if `end_time IS NULL` and `date < today`, automatically close them by setting `end_time = start_time` (zero-duration segment) and set `interrupted = 1`.

5. **UI display**
   - Duration formatted as `HH:MM:SS` using a utility function (handles > 24 hours gracefully).
   - Total time per day per ToDo displayed in the list tile subtitle.

6. **Manual Time Entry**
   - **"Add Manual Segment"** button on the time segments detail screen (`/todo/:id/segments`).
   - Available only for today's date (respects day lock) and only when status = pending.
   - UI: two `TimePicker` fields (start time, end time) with validation:
     - `start < end`.
     - No overlap with any existing segment for the same todo.
     - Both times must fall within the todo's calendar date.
   - Inserts via `TimeSegmentDao.insert()` with both `start_time` and `end_time` pre-filled.
     `duration_seconds` is computed as `end - start` in seconds.
   - The segment is stored with `manual = 1` in the database.
   - Manual segments display a small "M" badge in the segments list view.

#### Test Deliverables (written during this phase)
- Unit tests: start/stop, orphan repair (`RepairOrphanedSegments`), manual entry.
- Unit tests: manual segment overlap rejection, day lock, completed lock.
- Widget test: timer display tile (start/stop transitions, live timer increments).

#### Deliverables
- Start/stop works reliably with live timer display.
- Manual time entry with validation.
- Completed-status lock prevents new segments.
- Past-date lock prevents new segments.
- Orphan segment recovery works on app restart.

---

### Phase 5 – Copy / Port Features

**Goal:** Allow copying one or more ToDo items to another day.

**Estimated Duration:** 2–3 days

#### Tasks

1. **Copy Screen (`/copy`)**
   - Entry point: "Copy to another day" action in the daily list's overflow menu, or via the
     multi-select mode "Copy" button.
   - Step 1: multi-select ToDo items from the source date.
   - Step 2: pick the target date (must be ≥ today; can be today itself).
   - Step 3: preview list of items to copy with an option to deselect.
   - Confirm button triggers the `CopyTodos` use-case.
   - The wizard returns results to the calling screen via `context.pop(result)` from go_router.

2. **Copy logic (via `CopyTodos` use-case)**
   - For each selected `todoId`:
     - Read the source `TodoEntity`.
     - Check if a ToDo with the same title already exists on `targetDate`:
       - If yes: skip (with a warning shown to the user after the operation).
       - If no: insert a new `TodoEntity` with a fresh UUID, `date = targetDate`, `status = pending`, `ported_to = null`, `source_date = sourceEntity.date`, `sort_order` appended at end.
   - Time segments are **not** copied (fresh tracking on the new day).
   - Wraps all inserts in a single DB transaction.

3. **Port vs Copy distinction (UX)**
   - **Copy**: user-initiated action from the copy screen — source item status is unchanged. Source remains `pending` (or whatever it was). A new item appears on the target day.
   - **Port** (from status selector): marks the source item as `ported` and sets `ported_to`; simultaneously creates the copy on the target day. This is the "I'm moving this task forward" workflow. Orchestrated via the `PortTodo` use-case.

4. **Visual indicators**
   - Items created via port or copy show a subtle "Copied from YYYY-MM-DD" caption below the title (read from the `source_date` column).
   - Items with status = ported show `→ YYYY-MM-DD` badge on the source day.

#### Test Deliverables (written during this phase)
- Unit tests: copy logic with conflict detection (duplicate title skipping).
- Unit tests: port creates copy + marks source as ported atomically.
- Unit tests: port undo deletes the copy.

#### Deliverables
- Multi-select copy works with conflict detection.
- Port workflow sets status and creates copy atomically.
- Visual badges clearly communicate ported/copied provenance.

---

### Phase 5B – Local Backup & Restore

**Goal:** Allow the user to export the full SQLite database to user-accessible storage and
restore from a previous backup file.

**Estimated Duration:** 2–3 days

#### Tasks

1. **Create `BackupService`** in `lib/data/backup/backup_service.dart`:

   ```dart
   class BackupService {
     /// Exports the database file to [destinationPath].
     /// File name format: journal_vault_backup_YYYYMMDD_HHMMSS.db
     Future<String> exportDatabase(String destinationPath);

     /// Validates and imports a database from [sourcePath].
     /// Runs schema migration if the backup is from an older version.
     /// Rejects if the backup schema version is newer than the app.
     Future<void> importDatabase(String sourcePath);

     /// Lists .db backup files in [directory], sorted newest first.
     Future<List<BackupFileInfo>> listBackups(String directory);
   }
   ```

   **Export flow:**
   1. Run `PRAGMA wal_checkpoint(TRUNCATE)` to flush WAL to main DB file.
   2. **Prompt the user for a backup passphrase** (minimum 8 characters, with a confirmation
      field). Display a clear warning: "If you forget this passphrase, the backup cannot be
      recovered. Write it down."
   3. Close the database connection.
   4. Create a temporary copy of the `.db` file.
   5. Re-key the copy from the device-derived key to the user-set passphrase
      (`PRAGMA rekey = '<passphrase>'` via SQLCipher).
   6. Verify the re-keyed copy by opening it with the passphrase and running
      `PRAGMA integrity_check`.
   7. Move the verified copy to the destination path.
   8. Reopen the original database connection.

   > **Encryption note:** Backup files are encrypted with the **user's passphrase**, not the
   > device key. This means backups are **portable** — they can be restored on any device
   > running this app, and they survive factory resets. The passphrase is never stored on
   > disk. If the user forgets it, the backup is unrecoverable.

   **Import flow:**
   1. **Prompt the user for the backup passphrase.**
   2. Open the source file read-only using the entered passphrase.
   3. If the file cannot be decrypted (wrong passphrase): show error
      "Incorrect passphrase or corrupted backup file." Allow retry.
   4. Read `PRAGMA user_version` — compare with current schema version.
   5. If older: run incremental migrations on the source file.
   6. If newer: throw `BackupVersionTooNewException`.
   7. Run `PRAGMA integrity_check` on the source file.
   8. Close the current database connection.
   9. Re-key the imported file from the user passphrase to the current device-derived key.
   10. Replace the current DB file with the re-keyed file.
   11. Reopen the database.

2. **Backup screen** (`/backup`):
   - **"Export Backup"** button → file picker (or default directory) → progress indicator →
     success message with file path, or error message.
   - **"Restore from Backup"** button → file picker → confirmation dialog
     ("This will replace ALL current data. This cannot be undone.") → restore → app restart.
   - **Backup list** — shows recent backups with date, file size, and a delete button.
   - Navigation: accessible from the main app bar overflow menu or navigation rail.

3. **New exceptions** in `lib/core/errors/exceptions.dart`:

   | Exception | When thrown |
   |-----------|------------|
   | `BackupVersionTooNewException` | Imported DB has a schema version newer than the app |
   | `BackupCorruptedException` | `PRAGMA integrity_check` fails on the backup file |

4. **New constant strings** in `app_strings.dart` under `AppStrings.backup` namespace.

#### Test Deliverables (written during this phase)
- Unit test: export creates a valid copy, original DB unaffected.
- Unit test: import with older schema version triggers migration.
- Unit test: import with newer schema version throws `BackupVersionTooNewException`.
- Unit test: import with corrupted file throws `BackupCorruptedException`.
- Integration test: round-trip — create todos → export → delete all → import → verify data.

#### Deliverables
- Export produces a valid, portable `.db` file.
- Import restores the full app state from a backup.
- Round-trip test passing.

---

### Phase 6 – Statistics Screen

**Goal:** A dashboard giving insight into productivity across days and per ToDo item.

**Estimated Duration:** 3.5–4.5 days

#### Tasks

1. **Statistics Screen (`/statistics`)**
   - Accessible from the main navigation rail / bottom nav.
   - Two sub-sections via tabs:
     - **Daily Overview** — metrics aggregated by date.
     - **Per-Item Overview** — metrics aggregated by ToDo title across all dates.

2. **Daily Overview tab**
   - Date range filter (last 7 days / last 30 days / all time / custom range).
   - **Bar chart** (fl_chart `BarChart`): grouped bars per day — completed (green), dropped (red), ported (amber), pending (grey).
   - **Summary cards** row: total todos all-time, average completed per day, average time per day.
   - **Data table** below the chart: date | total | completed | dropped | ported | pending | total time.
   - Data table displays **20 rows per page** with pagination controls (Previous / Next).
     The underlying SQL query uses `LIMIT 20 OFFSET ?` matching the current page.

3. **Per-Item Overview tab**
   - Search/filter bar to find a specific todo title (Unicode-aware).
   - **Line chart** (fl_chart `LineChart`): for a selected title, shows time spent (y-axis, minutes) vs date (x-axis).
   - **Data table**: title | appearances | completed count | dropped count | ported count | total time.
   - Data table displays **20 rows per page** with pagination controls.
   - Tapping a row drills into a **single-item detail**: a calendar heatmap style view showing which days that item appeared and its status.

4. **`StatisticsNotifier`** (Riverpod)
   - Exposes `dailyStats` and `perItemStats` as `AsyncValue<List<...>>`.
   - Tracks current page index and exposes `loadNextPage()` / `loadPreviousPage()`.
   - Caches the last result for 10 seconds to avoid redundant queries.
   - Refreshed when navigating to the statistics screen and after any data mutation.

5. **Export (stretch goal)**
   - "Export CSV" button generates a UTF-8 CSV file (with BOM for Excel compatibility) and shares it via the platform share sheet.
   - Deferred to a future sprint if time-constrained.

#### Deliverables
- Both tabs render correctly with real data.
- Charts and tables are readable and scrollable.
- Date range filter updates the charts dynamically.
- Pagination works correctly on both data tables.

---

### Phase 7 – UI Polish & Unicode Support

**Goal:** Ensure the app is visually cohesive, handles all Unicode scenarios correctly, and has proper app branding.

**Estimated Duration:** 2.5–3.5 days

#### Tasks

1. **Unicode audit**
   - Test all text input fields with: ASCII, Extended Latin (ä, ü, é), CJK (日本語, 中文, 한국어), Arabic (العربية) and Hebrew (עברית) for RTL, Devanagari (हिन्दी), Emoji (🎉✅), and zero-width characters.
   - Ensure `Directionality` widget wraps screens that may contain RTL text.
   - Verify NFC normalisation (`unorm_dart` or custom implementation) works correctly:
     - `nfcNormalize("é")` (composed U+00E9) == `nfcNormalize("é")` (decomposed U+0065 U+0301).
     - Hangul Jamo sequence composes to precomposed syllable.
     - Already-NFC strings pass through unchanged.

2. **Responsive layout**
   - Mobile (< 600 dp): single-column, bottom navigation bar.
   - Desktop / tablet (≥ 600 dp): navigation rail on the left, wider content area, two-column stats layout.

3. **Light / Dark theme**
   - Status colours adapted for both themes (sufficient contrast ratio ≥ 4.5:1).

4. **Accessibility**
   - All interactive elements have `Semantics` labels.
   - Minimum tap target size 48 × 48 dp.

5. **Error states and empty states**
   - No todos today → friendly illustration + "Add your first task" CTA.
   - DB error → error snackbar with retry option.

6. **Performance**
   - List uses `ListView.builder` (lazy rendering).
   - Statistics queries run on the main isolate (`sqflite` handles are **not transferable**
     across Dart isolates — `compute()` cannot be used for SQL queries). For large datasets
     (> 1,000 rows), mitigate UI jank by:
     - Paginated queries with `LIMIT/OFFSET`, loading incrementally.
     - `await Future.delayed(Duration.zero)` between heavy query batches to yield to the UI.
     - 10-second result cache in `StatisticsNotifier`.
     - If profiling shows frame jank > 16 ms, open a second read-only `sqflite` connection
       dedicated to statistics queries so they don't block CRUD writes.

7. **App Icon & Splash Screen**
   - Design and configure the app icon:
     - Android: adaptive icon (`mipmap-anydpi-v26`) with foreground and background layers.
     - Windows: `.ico` file in `windows/runner/resources/`.
   - Configure splash screen using `flutter_native_splash` (if it passed dep audit) or
     manually via `android/app/src/main/res/drawable/launch_background.xml` and
     Windows splash in `windows/runner/main.cpp`.

#### Deliverables
- App visually consistent across light and dark modes.
- All Unicode test cases pass.
- NFC normalisation unit tests pass.
- No layout overflow errors on 5-inch phone or 27-inch desktop window.
- App icon and splash screen configured for both platforms.

---

### Phase 8 – Testing (Gaps & Integration)

**Goal:** Fill coverage gaps, run integration tests, and perform the final quality audit.
Unit tests for DAOs, repositories, and use-cases are written **during their respective phases**
(Phases 2–5B). Widget tests are written alongside their screens. Phase 8 focuses exclusively on
integration tests, coverage audits, edge-case tests, and performance profiling.

**Estimated Duration:** 2–3 days

#### 8.1 Coverage Audit (target: 80 % on domain + data layers)

Review and fill any gaps in unit test coverage. The following should already exist from earlier phases:

| Test Suite | What is tested | Written in |
|------------|---------------|------------|
| `TodoDao` tests | All CRUD, uniqueness constraint, autocomplete query, cross-day search | Phase 2 |
| `TimeSegmentDao` tests | Start, stop, orphan detection, cascade delete, manual entry | Phase 2, 4 |
| `StatisticsQueryService` tests | Aggregate queries with known seed data, pagination | Phase 2 |
| `TodoRepository` tests | Day lock enforcement, status transitions, port/copy logic | Phase 3 |
| Use-case tests | `MarkTodoCompleted`, `PortTodo`, `CopyTodos`, `StartTimeSegment`, `RepairOrphanedSegments` | Phase 3, 4 |
| `BackupService` tests | Export, import, schema validation, corruption detection | Phase 5B |
| Unicode tests | NFC normalisation, title uniqueness with composed/decomposed strings | Phase 2, 7 |

#### 8.2 Widget Tests

| Test | Scenario | Written in |
|------|----------|------------|
| DailyListScreen | Renders todos, shows lock icon for past date, multi-select mode | Phase 3 |
| CreateEditTodoScreen | Validates mandatory title, autocomplete suggestions appear | Phase 3 |
| TimeTrackingTile | Start/stop transitions, live timer increments | Phase 4 |
| StatisticsScreen | Charts render without exceptions with mock data | Phase 8 |
| BackupScreen | Export/import buttons render, confirmation dialog shown | Phase 8 |
| SearchResultsScreen | Results grouped by date, tapping navigates | Phase 8 |
| UndoSnackBar | Appears after status change, reverts on tap | Phase 3 |

#### 8.3 Integration Tests (Flutter integration_test package)

| Scenario | Steps |
|----------|-------|
| Happy path | Create todo → start timer → stop timer → mark complete → verify stats |
| Copy flow | Create 3 todos → copy 2 to tomorrow → verify tomorrow list |
| Day lock | Set device date to yesterday via mock → verify all edits blocked |
| Unicode round-trip | Create todo with Arabic title → reopen → verify no data corruption |
| **Offline enforcement** | **Disable all network interfaces on test device → launch app → create, edit, view todos, view stats → verify zero errors or network-related warnings** |
| Undo status change | Mark completed → undo within 5 s → verify reverted |
| Backup round-trip | Create todos → export → delete all → import → verify data restored |
| Manual time entry | Add manual segment → verify duration computed → verify "M" badge shown |
| Bulk status change | Select 3 → Complete All → verify all completed → undo → verify reverted |

#### 8.4 Performance Profiling

- Profile daily list with 100+ todos using Flutter DevTools — verify no frame jank > 16 ms.
- Profile statistics screen with 1,000+ rows — verify pagination prevents UI freeze.
- Profile autocomplete with 5,000+ distinct titles — verify < 100 ms response per keystroke.

#### Deliverables
- `flutter test` passes all unit and widget tests.
- Integration test suite passes on Android emulator.
- Coverage ≥ 80 % on `lib/data/` and `lib/domain/`.
- Performance benchmarks documented and within acceptable thresholds.

---

### Phase 9 – Build & Release

**Goal:** Produce signed, distributable builds for Android and Windows.

**Estimated Duration:** 1–2 days

#### Tasks

1. **Android**
   - Configure `android/app/build.gradle` with correct `applicationId`, version.
   - Generate a release keystore and configure signing in `key.properties` (stored at
     `L:\Android\key.properties` — one level above the project root, never
     committed to Git).
   - **Verify `INTERNET` permission is absent from the merged release manifest:**
     ```powershell
     flutter build apk --release
     Select-String `
       -Path "build\app\intermediates\merged_manifests\release\AndroidManifest.xml" `
       -Pattern "INTERNET|NETWORK"
     # Expected: zero matches — if any found, halt and investigate transitive dep
     ```
   - `flutter build appbundle --release`.
   - Install and test on a physical device with **Wi-Fi and mobile data both disabled** —
     the app must launch and function normally with no network available.

2. **Windows**
   - `flutter build windows --release`.
   - Confirm `sqflite_ffi` DLL (`sqlite3.dll`) is bundled in the output directory:
     ```powershell
     Test-Path "build\windows\x64\runner\Release\sqlite3.dll"
     # Expected: True
     ```
   - **Windows v1.0 release is a portable folder** (`build\windows\x64\runner\Release\`).
     No MSIX installer is produced for v1.0. MSIX packaging is deferred to a future release
     when distribution outside a single machine is needed.
   - Smoke-test the `.exe` on a clean Windows 10 VM with the network adapter disabled —
     the app must launch and function normally.

3. **Version management**
   - `pubspec.yaml` version: `1.0.0+1` (semantic versioning; build number auto-incremented in CI if set up later).

4. **README**
   - Installation instructions, screenshots, and feature list committed to the repository.

#### Deliverables
- Signed APK / AAB for Android — manifest verified to contain no network permissions.
- Windows portable folder — verified to make no outbound network connections.
- Both builds tested with network physically disabled (flight mode / adapter disabled).

---

## 7. Folder Structure

```
SreerajP_ToDo/
├── CLAUDE.md                           # Claude Code project rules
├── .githooks/
│   └── pre-commit                      # Automated checks: analyze, dep audit, manifest, tests
├── lib/
│   ├── main.dart
│   ├── app.dart                        # MaterialApp, ThemeData, go_router
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── app_strings.dart        # All user-visible strings (incl. backup namespace)
│   │   │   └── app_routes.dart         # Route path constants
│   │   ├── errors/
│   │   │   ├── exceptions.dart         # DayLockedException, DuplicateTitleException,
│   │   │   │                           #   BackupVersionTooNewException, BackupCorruptedException
│   │   │   └── failures.dart
│   │   └── utils/
│   │       ├── date_utils.dart         # isToday(), isPastDate(), formatDate()
│   │       ├── duration_utils.dart     # formatDuration() HH:MM:SS
│   │       └── unicode_utils.dart      # nfcNormalize() via unorm_dart, detectTextDirection()
│   ├── data/
│   │   ├── database/
│   │   │   ├── database_service.dart   # Singleton, onCreate, onUpgrade, PRAGMA
│   │   │   └── migrations/
│   │   │       └── migration_v1.dart   # Complete initial schema (all columns)
│   │   ├── dao/
│   │   │   ├── todo_dao.dart           # incl. searchByTitle()
│   │   │   ├── time_segment_dao.dart
│   │   │   ├── recurrence_rule_dao.dart
│   │   │   └── statistics_query_service.dart  # Read-only aggregate queries
│   │   ├── repositories/
│   │   │   ├── todo_repository_impl.dart
│   │   │   └── time_segment_repository_impl.dart
│   │   ├── backup/
│   │   │   └── backup_service.dart
│   │   └── models/
│   │       ├── todo_entity.dart        # freezed (incl. source_date, recurrence_rule_id)
│   │       ├── todo_entity.freezed.dart
│   │       ├── time_segment_entity.dart  # freezed (incl. interrupted, manual)
│   │       ├── recurrence_rule_entity.dart  # freezed
│   │       └── todo_status.dart        # enum
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── todo.dart               # Domain model (immutable)
│   │   │   └── time_segment.dart
│   │   ├── repositories/              # Abstract interfaces only
│   │   │   ├── todo_repository.dart
│   │   │   └── time_segment_repository.dart
│   │   └── usecases/
│   │       ├── mark_todo_completed.dart
│   │       ├── mark_todo_dropped.dart
│   │       ├── port_todo.dart
│   │       ├── generate_recurring_tasks.dart
│   │       ├── copy_todos.dart
│   │       ├── start_time_segment.dart
│   │       └── repair_orphaned_segments.dart
│   ├── application/                    # Riverpod notifiers / providers
│   │   ├── providers.dart              # All provider declarations
│   │   ├── daily_todo_notifier.dart    # incl. undo support, bulk operations
│   │   ├── time_tracking_notifier.dart
│   │   └── statistics_notifier.dart    # incl. pagination
│   └── presentation/
│       ├── screens/
│       │   ├── daily_list/
│       │   │   ├── daily_list_screen.dart  # incl. multi-select mode
│       │   │   └── widgets/
│       │   │       ├── todo_list_tile.dart
│       │   │       └── day_header.dart
│       │   ├── create_edit_todo/
│       │   │   ├── create_edit_todo_screen.dart
│       │   │   └── widgets/
│       │   │       └── title_autocomplete_field.dart
│       │   ├── time_segments/
│       │   │   ├── time_segments_screen.dart
│       │   │   └── widgets/
│       │   │       └── manual_segment_form.dart
│       │   ├── copy_todos/
│       │   │   └── copy_todos_screen.dart
│       │   ├── search_results/
│       │   │   ├── search_results_screen.dart
│       │   │   └── widgets/
│       │   │       └── search_result_tile.dart
│       │   ├── recurring_tasks/
│       │   │   ├── recurring_tasks_screen.dart
│       │   │   ├── recurrence_editor_screen.dart
│       │   │   └── widgets/
│       │   │       ├── rrule_frequency_picker.dart
│       │   │       └── rrule_preview.dart
│       │   ├── backup/
│       │   │   ├── backup_screen.dart
│       │   │   └── widgets/
│       │   │       └── backup_list_tile.dart
│       │   └── statistics/
│       │       ├── statistics_screen.dart
│       │       └── widgets/
│       │           ├── daily_bar_chart.dart
│       │           ├── daily_stats_table.dart
│       │           ├── per_item_line_chart.dart
│       │           └── per_item_stats_table.dart
│       └── shared/
│           ├── widgets/
│           │   ├── status_badge.dart
│           │   ├── locked_overlay.dart
│           │   ├── confirm_dialog.dart
│           │   └── undo_status_snackbar.dart
│           └── theme/
│               └── app_theme.dart
├── test/
│   ├── data/
│   │   ├── todo_dao_test.dart
│   │   ├── time_segment_dao_test.dart
│   │   ├── statistics_query_service_test.dart
│   │   ├── backup_service_test.dart
│   │   └── recurrence_rule_dao_test.dart
│   ├── domain/
│   │   ├── todo_repository_test.dart
│   │   └── usecases/
│   │       ├── mark_todo_completed_test.dart
│   │       ├── mark_todo_dropped_test.dart
│   │       ├── generate_recurring_tasks_test.dart
│   │       ├── port_todo_test.dart
│   │       └── copy_todos_test.dart
│   ├── core/
│   │   └── unicode_utils_test.dart
│   └── presentation/
│       ├── daily_list_screen_test.dart
│       └── create_edit_screen_test.dart
├── integration_test/
│   └── app_test.dart
├── assets/
│   └── fonts/                          # Bundled fonts — Noto Sans subset for Unicode coverage
│                                       # No network font loading (google_fonts NOT used)
├── android/
├── windows/
└── pubspec.yaml
```

---

## 8. Risk Register

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R-1 | `sqflite_common_ffi` Windows DLL missing from release build | Medium | High | Copy `sqlite3.dll` post-build script; add integration test for this |
| R-2 | Unicode NFC normalisation mismatch causes duplicate title false positives | Low | Medium | Use `unorm_dart` package (or custom UAX #15 implementation) for NFC normalisation before all comparisons; unit test with visually identical composed/decomposed strings |
| R-3 | Live timer causes excessive rebuilds, janky UI | Medium | Medium | Use `StreamProvider` scoped only to the time display widget; benchmark with Flutter DevTools |
| R-4 | Orphaned open time segments on force-quit | Medium | Medium | Startup scan via `RepairOrphanedSegments` use-case auto-closes orphans; tested in integration test |
| R-5 | `table_calendar` RTL layout incorrect | Low | Low | Wrap in `Directionality(textDirection: TextDirection.ltr)` — calendar is date-based, not text-based |
| R-6 | Statistics queries slow on large datasets (> 10,000 rows) | Low | Medium | Paginated queries with `LIMIT/OFFSET`; yield to UI between batches; 10 s result cache; read-only second DB connection if profiling shows jank. **`compute()` isolate is NOT used** — `sqflite` handles are not transferable across isolates |
| R-7 | Android Gradle Plugin 9 compatibility — Flutter 3.41 notes AGP 9 + plugins not yet fully supported | Medium | Medium | Avoid upgrading AGP to v9 in the project; stay on AGP 8.x until Flutter officially clears AGP 9 support |
| R-8 | A future package upgrade silently introduces a transitive networking dependency | Medium | High | **Pre-commit Git hook** runs offline dep audit automatically after every `flutter pub upgrade`. Manual checks are no longer required. The `INTERNET` permission absence in `AndroidManifest.xml` provides a hard OS-level backstop on Android |
| R-9 | `flutter_localizations` or `intl` package attempts to fetch locale data at runtime | Low | Medium | Bundle all required locale data explicitly; test app startup with locale set to Arabic and Japanese on a device with no network; use `GlobalMaterialLocalizations.delegate` with pre-loaded delegates |
| R-10 | Backup file corruption or incomplete copy during export | Low | High | Flush WAL with `PRAGMA wal_checkpoint(TRUNCATE)` before export; verify integrity with `PRAGMA integrity_check` after copy |
| R-11 | User forgets backup passphrase | Medium | High | The backup passphrase is never stored — if forgotten, the backup is unrecoverable. Mitigation: show a clear warning at export time ("Write down this passphrase — it cannot be recovered"). The live database is unaffected (uses device-derived key, no passphrase needed for daily use). |
| R-12 | `sqflite_sqlcipher` package compatibility or transitive deps | Low | Medium | Audit `sqflite_sqlcipher` transitive deps before adding. It is a well-maintained drop-in replacement for `sqflite` with zero networking deps. If it fails the audit, fall back to compiling SQLCipher from source via FFI. |

---

## 9. Timeline Summary

| Phase | Description | Estimated Duration |
|-------|------------|-------------------|
| Phase 1 | Project Setup & Foundation | 2.5–3.5 days |
| Phase 2 | Database Layer | 3–4 days |
| Phase 3 | Core ToDo Features | 5.5–6.5 days |
| Phase 3B | Recurring Tasks | 3–4 days |
| Phase 4 | Time Tracking | 4–5 days |
| Phase 5 | Copy / Port Features | 2–3 days |
| Phase 5B | Local Backup & Restore | 2–3 days |
| Phase 6 | Statistics Screen | 3.5–4.5 days |
| Phase 7 | UI Polish & Unicode Support | 2.5–3.5 days |
| Phase 8 | Testing (Gaps & Integration) | 2–3 days |
| Phase 9 | Build & Release | 1–2 days |
| **Total** | | **31–42 days** |

> **Comparison with v1.0:** The original plan estimated 23–32 days across 9 phases. This
> revision adds ~8–10 days for: recurring tasks (+3–4 days), backup/restore (+2–3 days),
> manual time entry (+1 day), cross-day search (+0.5 day), undo mechanism (+0.5 day),
> pre-commit hook (+0.5 day), and app icon/splash (+0.5 day). Testing time in Phase 8 is
> reduced by 1 day because tests are now written during their respective phases rather than
> batched at the end.

---

*End of Plan — v1.3 (updated 2026-03-20: unable→dropped rename, hybrid undo mechanism with
confirmation dialogs, dual-key encryption (device key for live DB, user passphrase for portable
backups), dropped≠completed in statistics)*
