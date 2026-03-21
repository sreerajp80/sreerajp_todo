import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';

class RecurrenceRulesNotifier
    extends StateNotifier<AsyncValue<List<RecurrenceRuleEntity>>> {
  RecurrenceRulesNotifier(this._dao) : super(const AsyncValue.loading()) {
    loadRules();
  }

  final RecurrenceRuleDao _dao;

  Future<void> loadRules() async {
    state = const AsyncValue.loading();
    try {
      final rules = await _dao.findAll();
      state = AsyncValue.data(rules);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createRule(RecurrenceRuleEntity rule) async {
    try {
      final normalized = rule.copyWith(
        title: nfcNormalize(rule.title),
        description:
            rule.description != null ? nfcNormalize(rule.description!) : null,
      );
      await _dao.insert(normalized);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error creating recurrence rule: $e');
      rethrow;
    }
  }

  Future<void> updateRule(RecurrenceRuleEntity rule) async {
    try {
      final normalized = rule.copyWith(
        title: nfcNormalize(rule.title),
        description:
            rule.description != null ? nfcNormalize(rule.description!) : null,
      );
      await _dao.update(normalized);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error updating recurrence rule: $e');
      rethrow;
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await _dao.delete(id);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error deleting recurrence rule: $e');
      rethrow;
    }
  }

  Future<void> toggleActive(String id) async {
    try {
      final rule = await _dao.findById(id);
      if (rule == null) return;
      final toggled = rule.copyWith(active: !rule.active);
      await _dao.update(toggled);
      await loadRules();
    } on Exception catch (e) {
      debugPrint('Error toggling recurrence rule: $e');
      rethrow;
    }
  }
}
