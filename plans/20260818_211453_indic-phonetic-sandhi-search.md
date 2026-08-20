# Indic Phonetic & Sandhi-Aware Cross-Day Task Search (Feature 3.6)

**Status:** completed

**Date:** 2026-08-18

---

## 1. What we want

Feature 3.6 asks for one search box that finds a task anywhere in history, no matter
how the Malayalam text was typed. It must search **titles, descriptions and time
segment notes**, and it must treat these as the same text:

- Chillu written as one letter (`ൺ ൻ ർ ൽ ൾ ൿ`) and Chillu written as
  consonant + virama + ZWJ (`ണ + ് + ZWJ`).
- Text with and without zero-width joiners (ZWJ `U+200D`, ZWNJ `U+200C`).
- Latin words with and without accents (`café` = `cafe`).
- Upper and lower case.

## 2. What already exists

- `todos_fts` FTS5 virtual table over `title` + `description`
  (`lib/data/database/migrations/migration_v3.dart`), kept in sync by three SQL triggers.
- `TodoDao.searchByTitle` builds a prefix FTS query, with a `LIKE` fallback.
- `SearchResultsScreen` + `searchResultsProvider` already show grouped results.

## 3. What is missing (the issue)

1. **No folding.** FTS5 `unicode61` indexes the raw characters. `ൺ` and the
   `ണ` + virama + ZWJ sequence produce different tokens, so a search for one
   never finds the other. ZWJ/ZWNJ also split tokens. Accented Latin is not folded.
2. **No segment notes.** The `time_segments` table has no `notes` column at all,
   so there is nothing to search and no way to write a note.
3. **Search does not cover notes.** `searchByTitle` only joins `todos`.
4. **No grapheme-aware handling.** The `characters` package is not a declared
   dependency, so text is walked by code unit.

## 4. The plan

### 4.1 Core: one folding function

New file `lib/core/utils/indic_search_utils.dart` (pure Dart, no Flutter imports):

- `String foldForSearch(String input)` — the single normal form used for both
  what we store in the index and what the user types:
  1. NFC-normalize (`unicodeUtils.nfcNormalize`).
  2. Walk the string as grapheme clusters (`package:characters`).
  3. Rewrite Chillu so that consonant + virama + ZWJ becomes the single atomic
     Chillu letter, for `ണ ന ര ല ള ക`. Both spellings then match.
  4. Drop any remaining ZWJ / ZWNJ.
  5. Strip Latin accents only: NFD-decompose, remove combining marks in the
     Latin ranges `U+0300–U+036F`, `U+1AB0–U+1AFF`, `U+20D0–U+20F0`, recompose.
     Malayalam vowel signs and virama are **never** removed.
  6. Lower-case and collapse runs of whitespace to one space.
- `String buildFtsMatchQuery(String input)` — folds, splits on whitespace,
  strips FTS5 syntax characters, and joins the tokens as quoted prefix terms
  combined with `AND`.

Both are pure functions, so they are cheap to unit test.

### 4.2 Data: migration V8

New file `lib/data/database/migrations/migration_v8.dart`, and
`kDatabaseVersion` goes `7 → 8` in `lib/core/constants/app_constants.dart`,
with the matching block added to `migration_runner.dart`.

Migration steps:

1. `ALTER TABLE time_segments ADD COLUMN notes TEXT` (nullable, default null).
2. Drop the old triggers `todos_after_insert`, `todos_after_update`,
   `todos_after_delete` and drop the old `todos_fts` table.
3. Recreate it with a notes column, all indexed columns holding **folded** text,
   using the `unicode61` tokenizer with `remove_diacritics 2`. Columns:
   `todo_id UNINDEXED, title, description, notes`.
4. Backfill in Dart: read every todo and its segment notes, fold the text with
   `foldForSearch`, and insert one FTS row per todo.
5. Recreate only the **delete** trigger, which removes the FTS row when a todo
   row is deleted. Insert and update cannot stay in SQL, because SQL cannot call
   the Dart folding function. They move to the DAO layer (below).

### 4.3 Data: keeping the index in sync from Dart

New file `lib/data/dao/todo_search_index_dao.dart` with a small API:

- `Future<void> reindexTodo(String todoId, {DatabaseExecutor? executor})` —
  reads the todo row and all of its segment notes, folds them, and does a
  delete + insert into `todos_fts`.
- `Future<void> removeTodo(String todoId, ...)` — used where the delete trigger
  cannot help.

Call sites (all existing write paths already funnel through DAOs):

- `lib/data/dao/todo_dao.dart` — `insert`, `update`, `bulkInsert`.
- `lib/data/dao/time_segment_dao.dart` — `insert`, stop/update, the new note
  update, and delete.

### 4.4 Data: segment notes

- `lib/data/models/time_segment_entity.dart` — add `String? notes` to the
  freezed factory, `toMap` and `fromMap`. Requires `build_runner`.
- `lib/data/dao/time_segment_dao.dart` — add
  `Future<void> updateNotes(String segmentId, String? notes)`; NFC-normalize
  before writing, then reindex the parent todo.
- `lib/domain/repositories/time_segment_repository.dart` and
  `lib/data/repositories/time_segment_repository_impl.dart` — expose the same
  method, keeping the existing day-lock check.
- `lib/application/time_tracking_notifier.dart` — add an `updateSegmentNotes`
  action; `lib/application/providers.dart` updated only if a new provider is
  needed.

### 4.5 Data: the search query

Rewrite `TodoDao.searchByTitle` as `searchTodos(String query, {int limit})`
(the old name stays as a thin alias so nothing breaks). It matches against
`todos_fts`, joins `todos`, orders by `bm25(todos_fts)` then `date DESC,
sort_order ASC`, and keeps a `LIKE` fallback for safety.

### 4.6 Presentation

- `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart` —
  add an optional multi-line "Note" field.
- `lib/presentation/screens/time_segments/time_segments_screen.dart` — show the
  note under each segment row and allow editing it via a small dialog.
- `lib/presentation/screens/search_results/search_results_screen.dart` — when a
  result matched on a note, show that note as the subtitle so the user sees why
  the row matched.
- New strings added to `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`
  (`segmentNoteLabel`, `segmentNoteHint`, `editSegmentNote`, `matchedInNote`),
  then regenerate localizations.

### 4.7 Dependencies

- `pubspec.yaml` — add `characters` (first-party Dart package, fully offline,
  no network). No other new package.

## 5. Files to be changed

**New**

- `lib/core/utils/indic_search_utils.dart`
- `lib/data/database/migrations/migration_v8.dart`
- `lib/data/dao/todo_search_index_dao.dart`
- `test/core/indic_search_utils_test.dart`
- `test/data/todo_search_index_test.dart`

**Changed**

- `pubspec.yaml`
- `lib/core/constants/app_constants.dart`
- `lib/data/database/migrations/migration_runner.dart`
- `lib/data/dao/todo_dao.dart`
- `lib/data/dao/time_segment_dao.dart`
- `lib/data/models/time_segment_entity.dart` (+ regenerated freezed file)
- `lib/domain/repositories/time_segment_repository.dart`
- `lib/data/repositories/time_segment_repository_impl.dart`
- `lib/application/time_tracking_notifier.dart`
- `lib/application/providers.dart`
- `lib/presentation/screens/time_segments/time_segments_screen.dart`
- `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart`
- `lib/presentation/screens/search_results/search_results_screen.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` (+ regenerated localizations)
- `test/data/todo_dao_test.dart`
- `docs/features.md` (mark 3.6 as implemented)

## 6. Tests

- **Folding unit tests:** Chillu both spellings fold equal; ZWJ/ZWNJ stripped;
  `café` equals `cafe`; Malayalam vowel signs and virama survive; case folding.
- **DAO tests (in-memory SQLite):** search by atomic Chillu finds a task written
  with the ZWJ sequence and the other way round; search finds a task by its
  segment note; index updates on todo insert/update/delete and on note edit.
- **Migration test:** a V7 database upgrades to V8, gains the `notes` column,
  and the rebuilt FTS table returns the same rows for a folded query.
- `flutter analyze` must report 0 issues and `flutter test` must pass.

## 7. Risks

- **Rebuilding the index** on upgrade touches every todo once. For a personal
  app this is a few thousand rows, so it is fast, but it runs inside the
  migration.
- **Moving insert/update out of SQL triggers** means any future write path that
  bypasses the DAOs would silently miss the index. The delete trigger stays in
  SQL as a safety net, and the reindex call sites are all in two DAO files.
- No change to the offline guarantee: no new network capability, one first-party
  Dart package added.
