# Implementation Plan - SQLite FTS5 Full-Text Search Engine Upgrade

**Status:** Pending Approval

## Goal
Upgrade the application's task search from substring `LIKE '%query%'` SQL queries to SQLite FTS5 virtual tables (`todos_fts`). This provides instant, tokenized, sub-millisecond search across titles and descriptions with automatic SQLite triggers (`AFTER INSERT`, `AFTER DELETE`, `AFTER UPDATE`), supporting prefix matching (`token*`), phrase matching, and multi-word token queries.

## Issue / Current State
Currently, `TodoDao.searchByTitle` performs a SQL substring query:
`SELECT * FROM todos WHERE title LIKE '%query%' ORDER BY date DESC, sort_order ASC`
This substring search:
1. Cannot utilize indexes efficiently for leading wildcard matches (`%query%`).
2. Does not index descriptions or task notes.
3. Cannot perform tokenized multi-word matching (e.g. searching "buy milk" to match a task titled "Buy fresh milk from store").

## Proposed Changes

### Database Migration
#### [NEW] [migration_v3.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_v3.dart)
- Create `todos_fts` virtual table using FTS5:
  ```sql
  CREATE VIRTUAL TABLE IF NOT EXISTS todos_fts USING fts5(
    todo_id UNINDEXED,
    title,
    description,
    tokenize = 'unicode61'
  );
  ```
- Populate `todos_fts` from existing `todos` records:
  ```sql
  INSERT INTO todos_fts(todo_id, title, description)
  SELECT id, title, COALESCE(description, '') FROM todos;
  ```
- Create SQLite triggers:
  - `todos_after_insert`: Inserts new row into `todos_fts`.
  - `todos_after_delete`: Deletes corresponding row from `todos_fts`.
  - `todos_after_update`: Updates `todos_fts` title and description.

#### [MODIFY] [app_constants.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_constants.dart)
- Increment `kDatabaseVersion` from 2 to 3.

#### [MODIFY] [migration_runner.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_runner.dart)
- Import `migration_v3.dart` and trigger `runMigrationV3(db)` when `oldVersion < 3 && newVersion >= 3`.

### Data Access Object & Repository
#### [MODIFY] [todo_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/todo_dao.dart)
- Implement `_buildFtsQuery(String query)` helper to NFC-normalize, sanitize, and format user input queries into tokenized prefix queries (e.g., `word1* word2*`).
- Upgrade `searchByTitle` to execute FTS MATCH JOIN queries:
  ```sql
  SELECT t.*
  FROM todos_fts fts
  JOIN todos t ON t.id = fts.todo_id
  WHERE todos_fts MATCH ?
  ORDER BY t.date DESC, t.sort_order ASC
  LIMIT ?
  ```
- Add a safety fallback to `LIKE '%query%'` (searching both title and description) if FTS query parsing fails or returns invalid results.

### Testing
#### [MODIFY] [todo_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/todo_dao_test.dart)
- Add tests for FTS5 full-text search:
  - Tokenized prefix matching (e.g. `buy` matching `buying`).
  - Multi-word matching (e.g. `milk buy` matching `buy fresh milk`).
  - Search across descriptions.
  - Automatic synchronization on insert, update, and delete via database triggers.

## Verification Plan

### Automated Tests
- Run `flutter test` to verify all existing and new unit/integration tests pass cleanly.
- Run `flutter analyze` to ensure 0 static analysis errors.

### Manual Verification
- Test `/search` screen with multi-word queries, partial prefix words, and empty/special character queries on Windows desktop.
