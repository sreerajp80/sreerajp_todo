import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';

class RecurrenceRuleDao {
  RecurrenceRuleDao(this._databaseService);

  final DatabaseService _databaseService;

  Future<void> insert(RecurrenceRuleEntity rule) async {
    final db = await _databaseService.database;
    await db.insert('recurrence_rules', rule.toMap());
  }

  Future<void> update(RecurrenceRuleEntity rule) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final updated = rule.copyWith(updatedAt: now);
    await db.update(
      'recurrence_rules',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _databaseService.database;
    await db.delete('recurrence_rules', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecurrenceRuleEntity>> findAll() async {
    final db = await _databaseService.database;
    final maps = await db.query('recurrence_rules', orderBy: 'created_at DESC');
    return maps.map(RecurrenceRuleEntity.fromMap).toList();
  }

  Future<List<RecurrenceRuleEntity>> findActive() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'recurrence_rules',
      where: 'active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map(RecurrenceRuleEntity.fromMap).toList();
  }

  Future<RecurrenceRuleEntity?> findById(String id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'recurrence_rules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RecurrenceRuleEntity.fromMap(maps.first);
  }
}
