# Change Log - SQLite FTS5 Full-Text Search Engine Upgrade

**Date:** 2026-08-10
**Plan:** `plans/20260810_181500_fts5_full_text_search_upgrade.md`

## Summary of Changes

### Database & Migrations
- Created [migration_v3.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_v3.dart) to define and initialize the SQLite FTS5 virtual table `todos_fts`:
  - Table schema: `todos_fts(todo_id UNINDEXED, title, description, tokenize = 'unicode61')`.
  - Automatic migration populates `todos_fts` from existing `todos` table data.
  - Automatic database triggers created: `todos_after_insert`, `todos_after_delete`, `todos_after_update` to maintain instant synchronization on write operations.
- Updated [app_constants.dart](file:///l:/Android/sreerajp_todo/lib/core/constants/app_constants.dart) to increment `kDatabaseVersion` to `3`.
- Updated [migration_runner.dart](file:///l:/Android/sreerajp_todo/lib/data/database/migrations/migration_runner.dart) to run Migration V3 when upgrading database version.

### Data Access Object & Search Engine
- Upgraded `TodoDao.searchByTitle` in [todo_dao.dart](file:///l:/Android/sreerajp_todo/lib/data/dao/todo_dao.dart):
  - Added `_buildFtsQuery` helper to tokenize user input, sanitize special characters, NFC-normalize input strings, and format prefix wildcard queries (`"word"*`).
  - Executed tokenized SQLite FTS5 MATCH join queries on `todos_fts` and `todos`.
  - Added exception fallback to `LIKE '%query%'` substring matching across title and description for zero failure tolerance.

### Testing
- Extended [todo_dao_test.dart](file:///l:/Android/sreerajp_todo/test/data/todo_dao_test.dart) with unit tests:
  - Token prefix matching (`buy` -> `Buying groceries`).
  - Multi-word token queries (`buy fresh milk` -> `Buy fresh almond milk from store`).
  - Search across task descriptions.
  - Trigger synchronization on insert, update, and delete.
