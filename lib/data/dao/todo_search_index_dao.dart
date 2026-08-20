import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:sreerajp_todo/core/utils/indic_search_utils.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';

/// Name of the FTS5 virtual table that backs cross-day search.
const String kTodosFtsTable = 'todos_fts';

/// Preferred tokenizer.
///
/// `categories` keeps combining marks (`Mn`, `Mc`) inside a token. Without it
/// unicode61 treats every Malayalam vowel sign and virama as a word break, so
/// `കാര്യം` is shredded into `ക`, `ര`, `യ` and word search stops working.
///
/// `remove_diacritics 2` folds Latin accents inside SQLite as well, which
/// matches what [foldForSearch] already did to the stored text.
const String _preferredTokenizer =
    "unicode61 remove_diacritics 2 categories 'L* N* Co Mn Mc'";

/// Fallback for an older SQLite build that does not know the `categories`
/// option (added in SQLite 3.30). Search still works, just less precisely.
const String _fallbackTokenizer = 'unicode61 remove_diacritics 2';

/// Creates the FTS table and the delete trigger that keeps it tidy.
///
/// Every indexed column holds text already passed through [foldForSearch].
/// Insert and update are handled in Dart (see [reindexTodoInIndex]) because
/// SQL cannot call the Dart folding function, but delete stays in SQL as a
/// safety net so a removed todo can never leave a stale index row behind.
Future<void> createTodoSearchIndexSchema(DatabaseExecutor db) async {
  try {
    await db.execute(_createTableSql(_preferredTokenizer));
  } catch (_) {
    await db.execute(_createTableSql(_fallbackTokenizer));
  }

  await db.execute('''
    CREATE TRIGGER IF NOT EXISTS todos_after_delete AFTER DELETE ON todos BEGIN
      DELETE FROM $kTodosFtsTable WHERE todo_id = old.id;
    END;
  ''');
}

String _createTableSql(String tokenizer) =>
    '''
    CREATE VIRTUAL TABLE IF NOT EXISTS $kTodosFtsTable USING fts5(
      todo_id UNINDEXED,
      title,
      description,
      notes,
      tokenize = "$tokenizer"
    )
    ''';

/// Rebuilds the whole index from the `todos` and `time_segments` tables.
///
/// Used by the migration and available as a repair step.
Future<void> rebuildTodoSearchIndex(DatabaseExecutor db) async {
  await db.delete(kTodosFtsTable);

  final List<Map<String, Object?>> todos = await db.query(
    'todos',
    columns: <String>['id', 'title', 'description'],
  );

  for (final Map<String, Object?> todo in todos) {
    await _insertIndexRow(
      db,
      todoId: todo['id'] as String,
      title: todo['title'] as String? ?? '',
      description: todo['description'] as String? ?? '',
      notes: await _collectSegmentNotes(db, todo['id'] as String),
    );
  }
}

/// Rewrites the index row for one todo, reading its current title,
/// description and every note attached to its time segments.
Future<void> reindexTodoInIndex(DatabaseExecutor db, String todoId) async {
  await removeTodoFromIndex(db, todoId);

  final List<Map<String, Object?>> rows = await db.query(
    'todos',
    columns: <String>['id', 'title', 'description'],
    where: 'id = ?',
    whereArgs: <Object?>[todoId],
    limit: 1,
  );
  if (rows.isEmpty) return;

  await _insertIndexRow(
    db,
    todoId: todoId,
    title: rows.first['title'] as String? ?? '',
    description: rows.first['description'] as String? ?? '',
    notes: await _collectSegmentNotes(db, todoId),
  );
}

/// Drops the index row for [todoId], if any.
Future<void> removeTodoFromIndex(DatabaseExecutor db, String todoId) async {
  await db.delete(
    kTodosFtsTable,
    where: 'todo_id = ?',
    whereArgs: <Object?>[todoId],
  );
}

Future<void> _insertIndexRow(
  DatabaseExecutor db, {
  required String todoId,
  required String title,
  required String description,
  required String notes,
}) async {
  await db.insert(kTodosFtsTable, <String, Object?>{
    'todo_id': todoId,
    'title': foldForSearch(title),
    'description': foldForSearch(description),
    'notes': foldForSearch(notes),
  });
}

Future<String> _collectSegmentNotes(DatabaseExecutor db, String todoId) async {
  final List<Map<String, Object?>> rows = await db.query(
    'time_segments',
    columns: <String>['notes'],
    where: "todo_id = ? AND notes IS NOT NULL AND notes != ''",
    whereArgs: <Object?>[todoId],
    orderBy: 'start_time ASC',
  );

  return rows.map((Map<String, Object?> r) => r['notes'] as String).join(' ');
}

/// Thin wrapper so callers holding a [DatabaseService] can reindex without
/// resolving the database handle themselves.
class TodoSearchIndexDao {
  TodoSearchIndexDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> reindexTodo(String todoId, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await _databaseService.database;
    await reindexTodoInIndex(db, todoId);
  }

  Future<void> removeTodo(String todoId, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await _databaseService.database;
    await removeTodoFromIndex(db, todoId);
  }

  Future<void> rebuildAll({DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await _databaseService.database;
    await rebuildTodoSearchIndex(db);
  }
}
