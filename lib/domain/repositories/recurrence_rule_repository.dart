import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';

abstract class RecurrenceRuleRepository {
  Future<List<RecurrenceRuleEntity>> findAll();
  Future<List<RecurrenceRuleEntity>> findActive();
  Future<RecurrenceRuleEntity?> findById(String id);
  Future<void> insert(RecurrenceRuleEntity rule);
  Future<void> update(RecurrenceRuleEntity rule);
  Future<void> delete(String id);
}
