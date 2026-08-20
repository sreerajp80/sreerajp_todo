import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/data/dao/todo_search_index_dao.dart';

/// Database Migration V8: Indic phonetic and sandhi-aware cross-day search.
///
/// Two changes:
///  * `time_segments` gains a free-text `notes` column, so a work session can
///    carry a short note.
///  * `todos_fts` is rebuilt. It now covers segment notes as well as the
///    title and description, stores search-folded text (Chillu unified,
///    joiners removed, Latin accents stripped), and uses a tokenizer that
///    keeps Malayalam words whole.
///
/// The old insert/update triggers are dropped: folding happens in Dart, which
/// SQL cannot call. The DAO layer now writes the index. Only the delete
/// trigger stays in SQL.
Future<void> runMigrationV8(Database db) async {
  await _addSegmentNotesColumn(db);

  await db.execute('DROP TRIGGER IF EXISTS todos_after_insert');
  await db.execute('DROP TRIGGER IF EXISTS todos_after_update');
  await db.execute('DROP TRIGGER IF EXISTS todos_after_delete');
  await db.execute('DROP TABLE IF EXISTS $kTodosFtsTable');

  await createTodoSearchIndexSchema(db);
  await rebuildTodoSearchIndex(db);
}

Future<void> _addSegmentNotesColumn(Database db) async {
  final List<Map<String, Object?>> columns = await db.rawQuery(
    'PRAGMA table_info(time_segments)',
  );
  final bool hasNotes = columns.any(
    (Map<String, Object?> column) => column['name'] == 'notes',
  );
  if (hasNotes) return;

  await db.execute('ALTER TABLE time_segments ADD COLUMN notes TEXT');
}
