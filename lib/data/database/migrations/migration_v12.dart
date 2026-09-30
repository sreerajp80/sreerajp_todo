import 'package:sqflite_sqlcipher/sqlite_api.dart';

/// Database Migration V12: store series values on recurrence rules.
///
/// `recurrence_rules` gains three nullable columns, so a new occurrence gets
/// the series' priority, target time and sub-tasks from the rule itself
/// instead of from whichever occurrence happens to be the latest:
///  * `priority` — the `TodoPriority` name.
///  * `target_seconds` — target time in seconds.
///  * `sub_task_titles` — JSON list of sub-task titles.
///
/// Existing rules keep null in all three and fall back to the old behaviour.
/// Each column is added only when missing, so re-running is safe.
Future<void> runMigrationV12(Database db) async {
  final List<Map<String, Object?>> columns = await db.rawQuery(
    'PRAGMA table_info(recurrence_rules)',
  );
  final existing = columns
      .map((Map<String, Object?> column) => column['name'])
      .toSet();

  if (!existing.contains('priority')) {
    await db.execute('ALTER TABLE recurrence_rules ADD COLUMN priority TEXT');
  }
  if (!existing.contains('target_seconds')) {
    await db.execute(
      'ALTER TABLE recurrence_rules ADD COLUMN target_seconds INTEGER',
    );
  }
  if (!existing.contains('sub_task_titles')) {
    await db.execute(
      'ALTER TABLE recurrence_rules ADD COLUMN sub_task_titles TEXT',
    );
  }
}
