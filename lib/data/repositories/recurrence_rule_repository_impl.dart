import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/domain/repositories/recurrence_rule_repository.dart';

class RecurrenceRuleRepositoryImpl implements RecurrenceRuleRepository {
  RecurrenceRuleRepositoryImpl(this._dao);

  final RecurrenceRuleDao _dao;

  RecurrenceRuleEntity _normalize(RecurrenceRuleEntity rule) {
    return rule.copyWith(
      title: nfcNormalize(rule.title),
      description:
          rule.description != null ? nfcNormalize(rule.description!) : null,
    );
  }

  @override
  Future<List<RecurrenceRuleEntity>> findAll() => _dao.findAll();

  @override
  Future<List<RecurrenceRuleEntity>> findActive() => _dao.findActive();

  @override
  Future<RecurrenceRuleEntity?> findById(String id) => _dao.findById(id);

  @override
  Future<void> insert(RecurrenceRuleEntity rule) =>
      _dao.insert(_normalize(rule));

  @override
  Future<void> update(RecurrenceRuleEntity rule) =>
      _dao.update(_normalize(rule));

  @override
  Future<void> delete(String id) => _dao.delete(id);
}
