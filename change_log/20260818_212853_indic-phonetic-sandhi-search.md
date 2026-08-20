# Change Log — Indic Phonetic & Sandhi-Aware Cross-Day Task Search (Feature 3.6)

**Date:** 2026-08-18
**Plan:** `plans/20260818_211453_indic-phonetic-sandhi-search.md`

---

## What this change does

Cross-day search now finds a task no matter how its Malayalam text was typed, and it
now searches time segment notes as well as titles and descriptions.

Text is matched after both sides — what is stored and what the user types — pass
through one folding step:

- Malayalam Chillu is unified. `ണ` + virama + ZWJ and the single letter `ൺ` are now the
  same for search (same for `ന`/`ൻ`, `ര`/`ർ`, `ല`/`ൽ`, `ള`/`ൾ`, `ക`/`ൿ`).
- Zero-width joiner and non-joiner are removed, so an invisible character can no longer
  split one word into two tokens.
- Latin accents are stripped, so `café` finds `cafe` and the other way round. Malayalam
  vowel signs and the virama are never stripped, because they change the word.
- Folding walks grapheme clusters, so a multi-code-point letter is never cut in half.
- Text is lower-cased and runs of whitespace are collapsed.

## A bug found and fixed along the way

The old FTS index used the plain `unicode61` tokenizer. That tokenizer treats every
Malayalam vowel sign and the virama as a word break, so `കാര്യം` was indexed as the
separate letters `ക`, `ര`, `യ` — Malayalam word search did not really work. The new
index adds `categories 'L* N* Co Mn Mc'`, which keeps combining marks inside a token,
so a Malayalam word is now indexed as one word. There is an automatic fallback to the
old tokenizer if the SQLite build is too old to know that option.

---

## Files added

- `lib/core/utils/indic_search_utils.dart` — `foldForSearch`, `foldedEquals`, and
  `buildFtsMatchQuery`. Pure Dart, no Flutter imports.
- `lib/data/dao/todo_search_index_dao.dart` — creates the FTS schema, rebuilds the whole
  index, and reindexes or removes a single todo.
- `lib/data/database/migrations/migration_v8.dart` — migration V8.
- `lib/data/models/todo_search_result.dart` — a search hit plus the segment note that
  explains it, when there is one.
- `test/core/indic_search_utils_test.dart` — 17 folding tests.
- `test/data/todo_search_index_test.dart` — 14 database tests.

## Files changed

**Database**

- `lib/core/constants/app_constants.dart` — `kDatabaseVersion` 7 → 8.
- `lib/data/database/migrations/migration_runner.dart` — runs migration V8.

Migration V8 adds a `notes TEXT` column to `time_segments`, drops the old `todos_fts`
table and its three triggers, recreates the table with a `notes` column and the new
tokenizer holding folded text, and rebuilds the index from existing data. Only the
delete trigger is recreated in SQL — insert and update need the Dart folding function,
so they moved to the DAO layer.

**Data**

- `lib/data/dao/todo_dao.dart` — the hand-rolled FTS query builder was replaced by
  `buildFtsMatchQuery`; results now rank by `bm25`; `insert` and `update` reindex the
  todo; new `searchWithMatchedNotes` returns the note that explains each hit.
- `lib/data/dao/time_segment_dao.dart` — new `findById` and `updateNotes`; `insert` and
  `deleteByTodoId` keep the index in sync. Note text is NFC-normalized before it is
  written.
- `lib/data/models/time_segment_entity.dart` — new `notes` field.
- `lib/data/repositories/todo_repository_impl.dart` — implements
  `searchWithMatchedNotes`.
- `lib/data/repositories/time_segment_repository_impl.dart` — implements
  `updateSegmentNotes`. The day lock still applies, so a past day stays read-only. The
  terminal status lock is deliberately **not** applied here: writing a note does not add
  tracked time to a finished task.

**Domain / Application**

- `lib/domain/repositories/todo_repository.dart` — new `searchWithMatchedNotes`.
- `lib/domain/repositories/time_segment_repository.dart` — new `updateSegmentNotes`.
- `lib/application/time_tracking_notifier.dart` — new `updateSegmentNotes` action.
- `lib/application/providers.dart` — `searchResultsProvider` now returns
  `List<TodoSearchResult>`.

**Presentation**

- `lib/presentation/screens/time_segments/widgets/manual_segment_form.dart` — optional
  two-line note field on the add-segment sheet.
- `lib/presentation/screens/time_segments/time_segments_screen.dart` — each segment row
  shows its note and has a note button that opens a small edit dialog.
- `lib/presentation/screens/search_results/search_results_screen.dart` — when the hit
  came from a note, that note is shown as the subtitle in the accent color; otherwise
  the description is shown as before.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` and the regenerated localization files —
  new strings `segmentNoteLabel`, `segmentNoteHint`, `editSegmentNote`, `matchedInNote`.

**Dependencies and docs**

- `pubspec.yaml` — added `characters` (first-party Dart package, no network).
- `docs/features.md` — section 11 rewritten to describe the folding rules and note
  search.
- `docs/unique_features_and_improvements.md` — feature 3.6 marked implemented, with an
  explicit note on what is not included.
- `docs/dependencies.md`, `CLAUDE.md`, `AGENTS.md` — `characters` added to the approved
  package lists.

**Tests updated**

- `test/presentation/search_results_screen_test.dart` — mocks the new repository method
  and adds a test for the matched-note subtitle.
- `test/presentation/create_edit_todo_screen_test.dart`,
  `test/presentation/todo_list_tile_test.dart`,
  `test/presentation/undo_snackbar_test.dart` — fake repositories implement the two new
  interface methods.

---

## Scope note

This implements the behaviours listed in the feature: Chillu unification, joiner
stripping, accent stripping, and grapheme-aligned matching. It does **not** include
cross-script phonetic transliteration (typing Latin `ka` to find `ക`); the source
engine referenced in the feature description was not available in this repository.

---

## Verification

- `flutter analyze` — 0 issues.
- `flutter test` — 325 tests pass, including:
  - 17 folding unit tests (Chillu both ways, joiners, accents, case, whitespace, and
    that Malayalam vowel signs survive).
  - 14 database tests on in-memory SQLite: search across both Chillu spellings, whole
    Malayalam word tokenization, accent-insensitive Latin, finding a task by its segment
    note, index updates on note edit / clear / delete, index updates on todo update and
    delete, and a V7 → V8 upgrade that adds the `notes` column and rebuilds a working
    index from pre-existing rows.
- `dart format` run over `lib/`, `test/`, `integration_test/`.
- No new network capability. Offline guarantee unchanged.
