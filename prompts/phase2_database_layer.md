# Phase 2 — Database Layer

## Objective
Build the fully tested data access layer: encrypted SQLite database, complete initial schema, all model classes (freezed), DAOs, query services, abstract repository interfaces, and repository implementations.

## Pre-Requisites
- Phase 1 complete (project scaffolded, dependencies installed, folder structure created).
- Read `CLAUDE.md` — it defines the schema, naming conventions, and non-negotiable rules.
- Read the database schema section of `flutter_todo_app_plan.md` (Section 4).

## Tasks

### 1. Create `DatabaseService` Singleton (`lib/data/database/database_service.dart`)

- Opens/creates the **encrypted** SQLite file using:
  - `sqflite_sqlcipher` on mobile (AES-256)
  - `sqflite_common_ffi` with SQLCipher on desktop
- **Encryption key strategy (dual-key):**
  - **Live database:** device-derived key (Android Keystore / Windows DPAPI). Generated on first launch, stored in the platform's secure key store, retrieved transparently. User never sees it.
  - **Backup files:** re-encrypted with a user-set passphrase at export time (handled in Phase 5B).
- DB file path: resolved via `path_provider.getApplicationDocumentsDirectory()`.
- `onCreate`: runs `migration_v1.dart` (complete initial schema — all columns from day one).
- `onUpgrade`: runs incremental migration files. Never modify an existing migration file.
- Enables at startup:
  ```sql
  PRAGMA journal_mode=WAL;
  PRAGMA foreign_keys=ON;
  ```
- Exposed as a Riverpod `Provider<DatabaseService>` in `providers.dart`.

### 2. Create `migration_v1.dart` (`lib/data/database/migrations/migration_v1.dart`)

Complete initial schema — includes ALL columns (no deferred ALTER TABLE):

```sql
CREATE TABLE recurrence_rules (
    id           TEXT PRIMARY KEY,
    title        TEXT NOT NULL,
    description  TEXT,
    rrule        TEXT NOT NULL,
    start_date   TEXT NOT NULL,
    end_date     TEXT,
    active       INTEGER NOT NULL DEFAULT 1,
    created_at   TEXT NOT NULL,
    updated_at   TEXT NOT NULL
);

CREATE TABLE todos (
    id                  TEXT PRIMARY KEY,
    date                TEXT NOT NULL,
    title               TEXT NOT NULL,
    description         TEXT,
    status              TEXT NOT NULL DEFAULT 'pending',
    ported_to           TEXT,
    source_date         TEXT,
    recurrence_rule_id  TEXT REFERENCES recurrence_rules(id) ON DELETE SET NULL,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    created_at          TEXT NOT NULL,
    updated_at          TEXT NOT NULL,
    UNIQUE (date, title)
);

CREATE INDEX idx_todos_date ON todos (date);
CREATE INDEX idx_todos_title ON todos (title);
CREATE INDEX idx_todos_recurrence ON todos (recurrence_rule_id);

CREATE TABLE time_segments (
    id               TEXT PRIMARY KEY,
    todo_id          TEXT NOT NULL REFERENCES todos(id) ON DELETE CASCADE,
    start_time       TEXT NOT NULL,
    end_time         TEXT,
    duration_seconds INTEGER DEFAULT NULL,
    interrupted      INTEGER NOT NULL DEFAULT 0,
    manual           INTEGER NOT NULL DEFAULT 0,
    created_at       TEXT NOT NULL
);

CREATE INDEX idx_time_segments_todo_id ON time_segments (todo_id);
```

### 3. Create Dart Model Classes (with `freezed`)

All models go in `lib/data/models/`.

#### `TodoStatus` enum (`todo_status.dart`)
```dart
enum TodoStatus { pending, completed, dropped, ported }
```
With extension methods for `toDbString()` and `fromDbString()`.

#### `TodoEntity` (`todo_entity.dart`)
Freezed class mirroring the `todos` table:
- `id` (String), `date` (String), `title` (String), `description` (String?), `status` (TodoStatus), `portedTo` (String?), `sourceDate` (String?), `recurrenceRuleId` (String?), `sortOrder` (int), `createdAt` (String), `updatedAt` (String)
- Include `toMap()` and `fromMap()` factory methods for sqflite compatibility.

#### `TimeSegmentEntity` (`time_segment_entity.dart`)
Freezed class mirroring the `time_segments` table:
- `id` (String), `todoId` (String), `startTime` (String), `endTime` (String?), `durationSeconds` (int?), `interrupted` (bool), `manual` (bool), `createdAt` (String)
- Include `toMap()` and `fromMap()`.

#### `RecurrenceRuleEntity` (`recurrence_rule_entity.dart`)
Freezed class mirroring the `recurrence_rules` table:
- `id` (String), `title` (String), `description` (String?), `rrule` (String), `startDate` (String), `endDate` (String?), `active` (bool), `createdAt` (String), `updatedAt` (String)
- Include `toMap()` and `fromMap()`.

After creating models, run:
```powershell
dart run build_runner build --delete-conflicting-outputs
```

### 4. Create `TodoDao` (`lib/data/dao/todo_dao.dart`)

All SQL for the `todos` table. Methods:

| Method | Signature | Notes |
|--------|-----------|-------|
| `insert` | `Future<void> insert(TodoEntity todo)` | NFC-normalised title assumed |
| `update` | `Future<void> update(TodoEntity todo)` | Bumps `updated_at` |
| `delete` | `Future<void> delete(String id)` | |
| `findByDate` | `Future<List<TodoEntity>> findByDate(String date)` | Ordered by `sort_order, created_at` |
| `findById` | `Future<TodoEntity?> findById(String id)` | |
| `existsTitleOnDate` | `Future<bool> existsTitleOnDate(String title, String date, {String? excludeId})` | NFC-normalised title check |
| `getAllDistinctTitles` | `Future<List<String>> getAllDistinctTitles(String prefix)` | `LIKE ? \|\| '%'` with `LIMIT 20` |
| `searchByTitle` | `Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50})` | `LIKE '%' \|\| ? \|\| '%'` |
| `updateSortOrders` | `Future<void> updateSortOrders(List<TodoEntity> todos)` | Batch update in transaction |

SQL query strings belong **in this DAO class** — not in repositories or widgets.

### 5. Create `TimeSegmentDao` (`lib/data/dao/time_segment_dao.dart`)

| Method | Signature | Notes |
|--------|-----------|-------|
| `insert` | `Future<void> insert(TimeSegmentEntity seg)` | |
| `closeSegment` | `Future<void> closeSegment(String segId, DateTime endTime)` | Sets `end_time`, computes `duration_seconds` |
| `findByTodoId` | `Future<List<TimeSegmentEntity>> findByTodoId(String todoId)` | Ordered by `start_time` |
| `findRunningSegment` | `Future<TimeSegmentEntity?> findRunningSegment(String todoId)` | `end_time IS NULL` |
| `findAllOrphanedSegments` | `Future<List<TimeSegmentEntity>> findAllOrphanedSegments(String todayDate)` | `end_time IS NULL AND date < today` |
| `deleteByTodoId` | `Future<void> deleteByTodoId(String todoId)` | Explicit cascade |

### 6. Create `RecurrenceRuleDao` (`lib/data/dao/recurrence_rule_dao.dart`)

| Method | Signature |
|--------|-----------|
| `insert` | `Future<void> insert(RecurrenceRuleEntity rule)` |
| `update` | `Future<void> update(RecurrenceRuleEntity rule)` |
| `delete` | `Future<void> delete(String id)` |
| `findAll` | `Future<List<RecurrenceRuleEntity>> findAll()` |
| `findActive` | `Future<List<RecurrenceRuleEntity>> findActive()` |
| `findById` | `Future<RecurrenceRuleEntity?> findById(String id)` |

### 7. Create `StatisticsQueryService` (`lib/data/dao/statistics_query_service.dart`)

Read-only aggregate queries (not a CRUD DAO):

| Method | Returns | SQL |
|--------|---------|-----|
| `getCountsPerDay` | `List<DayStats>` | `SELECT date, COUNT(*), SUM(completed), SUM(dropped), SUM(ported), SUM(pending) GROUP BY date LIMIT ? OFFSET ?` |
| `getTimePerTodoPerDay` | `List<TodoTimeStats>` | `SELECT title, date, SUM(duration_seconds) GROUP BY title, date LIMIT ? OFFSET ?` |
| `getTimePerTodo` | `List<TodoTimeStats>` | Filtered by title |

Define `DayStats` and `TodoTimeStats` as simple immutable classes (or freezed).

### 8. Create Abstract Repository Interfaces (`lib/domain/repositories/`)

#### `TodoRepository` (`todo_repository.dart`)
```dart
abstract class TodoRepository {
  Future<List<TodoEntity>> getTodosByDate(String date);
  Future<TodoEntity?> getTodoById(String id);
  Future<void> createTodo(TodoEntity todo);
  Future<void> updateTodo(TodoEntity todo, {bool bypassLock = false});
  Future<void> deleteTodo(String id, {bool bypassLock = false});
  Future<void> updateStatus(String id, TodoStatus status, {String? portedTo, bool bypassLock = false});
  Future<bool> titleExistsOnDate(String title, String date, {String? excludeId});
  Future<List<String>> getAutocompleteSuggestions(String prefix);
  Future<List<TodoEntity>> searchByTitle(String query, {int limit = 50});
  Future<void> reorderTodos(List<TodoEntity> todos, {bool bypassLock = false});
}
```

#### `TimeSegmentRepository` (`time_segment_repository.dart`)
```dart
abstract class TimeSegmentRepository {
  Future<void> startSegment(String todoId);
  Future<void> stopSegment(String todoId);
  Future<List<TimeSegmentEntity>> getSegments(String todoId);
  Future<TimeSegmentEntity?> getRunningSegment(String todoId);
  Future<void> insertManualSegment(TimeSegmentEntity segment);
  Future<void> repairOrphanedSegments(String todayDate);
}
```

### 9. Create Repository Implementations (`lib/data/repositories/`)

#### `TodoRepositoryImpl`
- Implements `TodoRepository`.
- **Day lock check**: every mutating method (create, update, delete, updateStatus, reorder) checks `isPastDate(todo.date)` and throws `DayLockedException` unless `bypassLock = true`.
- **NFC normalisation**: normalise `title` and `description` before every write.
- **Title uniqueness**: call `TodoDao.existsTitleOnDate()` before insert/update.
- Uses the DAO for all database operations.

#### `TimeSegmentRepositoryImpl`
- Implements `TimeSegmentRepository`.
- `startSegment`: checks day lock → completed lock → no running segment → inserts.
- `stopSegment`: finds running segment → closes it.
- `repairOrphanedSegments`: finds all orphaned segments → closes with zero duration, sets `interrupted = 1`.

### 10. Register Providers (`lib/application/providers.dart`)

Register all DAOs, services, and repositories:
```dart
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
final todoDaoProvider = Provider<TodoDao>((ref) => TodoDao(ref.read(databaseServiceProvider)));
final timeSegmentDaoProvider = Provider<TimeSegmentDao>((ref) => TimeSegmentDao(ref.read(databaseServiceProvider)));
final recurrenceRuleDaoProvider = Provider<RecurrenceRuleDao>((ref) => RecurrenceRuleDao(ref.read(databaseServiceProvider)));
final statisticsQueryServiceProvider = Provider<StatisticsQueryService>((ref) => StatisticsQueryService(ref.read(databaseServiceProvider)));
final todoRepositoryProvider = Provider<TodoRepository>((ref) => TodoRepositoryImpl(ref.read(todoDaoProvider)));
// ... etc
```

### 11. Write Unit Tests

**Every DAO method must have a test.** Use in-memory SQLite (`inMemoryDatabasePath`).

#### `test/data/todo_dao_test.dart`
- Insert and retrieve by date
- Update and verify `updated_at` changes
- Delete and verify cascade
- `existsTitleOnDate` — true/false cases, with `excludeId`
- `getAllDistinctTitles` — prefix matching, limit
- `searchByTitle` — substring matching
- Title uniqueness constraint violation

#### `test/data/time_segment_dao_test.dart`
- Insert and retrieve by todo ID
- Close segment and verify `duration_seconds` computation
- `findRunningSegment` — returns open segment, returns null when none
- `findAllOrphanedSegments` — detects orphans correctly
- Cascade delete when todo is deleted

#### `test/data/recurrence_rule_dao_test.dart`
- CRUD operations
- `findActive` filters correctly

#### `test/data/statistics_query_service_test.dart`
- Seed data → verify aggregate counts
- Pagination (limit/offset) works

#### `test/core/unicode_utils_test.dart`
- NFC normalisation: composed vs decomposed `é`
- Hangul Jamo composition
- Already-NFC strings unchanged
- `detectTextDirection` for LTR and RTL text

## Constraints
- SQL query strings belong in DAO classes only.
- `domain/` has zero `sqflite` imports.
- `core/` has zero Flutter imports.
- Never use `compute()` or `Isolate.spawn()` for `sqflite` queries.
- All writes use transactions where more than one row is affected.
- Generated files (`*.freezed.dart`, `*.g.dart`) are never edited manually.
- Migration files are append-only: never modify `migration_v1.dart` after first use.

## Deliverables
- [ ] Passing unit tests for all DAO methods
- [ ] Passing unit tests for `StatisticsQueryService`
- [ ] Passing unit tests for unicode utilities
- [ ] Database file created correctly on first app launch (both platforms)
- [ ] Complete initial schema with all columns — no deferred ALTER TABLE
- [ ] Repository implementations with day lock, NFC normalisation, and uniqueness checks
- [ ] All providers registered in `providers.dart`
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds
