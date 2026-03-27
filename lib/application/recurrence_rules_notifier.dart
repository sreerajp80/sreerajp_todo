import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/domain/repositories/recurrence_rule_repository.dart';

class RecurrenceRulesNotifier
    extends StateNotifier<AsyncValue<List<RecurrenceRuleEntity>>> {
  RecurrenceRulesNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadRules();
  }

  final RecurrenceRuleRepository _repository;

  Future<void> loadRules() async {
    state = const AsyncValue.loading();
    try {
      final rules = await _repository.findAll();
      state = AsyncValue.data(rules);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RecurrenceRuleEntity?> findById(String id) => _repository.findById(id);

  Future<void> createRule(RecurrenceRuleEntity rule) async {
    try {
      await _repository.insert(rule);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error creating recurrence rule: $e');
      rethrow;
    }
  }

  Future<void> updateRule(RecurrenceRuleEntity rule) async {
    try {
      await _repository.update(rule);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error updating recurrence rule: $e');
      rethrow;
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await _repository.delete(id);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error deleting recurrence rule: $e');
      rethrow;
    }
  }

  Future<void> toggleActive(String id) async {
    try {
      final rule = await _repository.findById(id);
      if (rule == null) return;
      final toggled = rule.copyWith(active: !rule.active);
      await _repository.update(toggled);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error toggling recurrence rule: $e');
      rethrow;
    }
  }
}
