import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/recurrence_rule_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/generate_recurring_tasks.dart';
import 'package:uuid/uuid.dart';

enum RecurringEditTarget { thisInstanceOnly, allFutureInstances, allInstances }

class UpdateRecurringTodos {
  UpdateRecurringTodos(
    this._todoRepository,
    this._recurrenceRuleRepository,
    this._generateRecurringTasks,
  );

  final TodoRepository _todoRepository;
  final RecurrenceRuleRepository _recurrenceRuleRepository;
  final GenerateRecurringTasks _generateRecurringTasks;
  static const _uuid = Uuid();

  Future<void> execute({
    required TodoEntity baseTodo,
    required TodoEntity updatedTodo,
    required RecurrenceRuleEntity? updatedRule,
    required RecurringEditTarget target,
  }) async {
    switch (target) {
      case RecurringEditTarget.thisInstanceOnly:
        await _executeThisInstanceOnly(
          baseTodo: baseTodo,
          updatedTodo: updatedTodo,
          updatedRule: updatedRule,
        );
        break;
      case RecurringEditTarget.allFutureInstances:
        await _executeThisAndFuture(
          baseTodo: baseTodo,
          updatedTodo: updatedTodo,
          updatedRule: updatedRule,
        );
        break;
      case RecurringEditTarget.allInstances:
        await _executeAll(
          baseTodo: baseTodo,
          updatedTodo: updatedTodo,
          updatedRule: updatedRule,
        );
        break;
    }
  }

  Future<void> _executeThisInstanceOnly({
    required TodoEntity baseTodo,
    required TodoEntity updatedTodo,
    required RecurrenceRuleEntity? updatedRule,
  }) async {
    var finalTodo = updatedTodo;
    if (updatedRule == null) {
      // Repeat was explicitly removed on this single instance
      finalTodo = finalTodo.copyWith(recurrenceRuleId: null);
    }
    await _todoRepository.updateTodo(finalTodo);
  }

  Future<void> _executeThisAndFuture({
    required TodoEntity baseTodo,
    required TodoEntity updatedTodo,
    required RecurrenceRuleEntity? updatedRule,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    if (updatedRule != null) {
      final currentRule = baseTodo.recurrenceRuleId != null
          ? await _recurrenceRuleRepository.findById(baseTodo.recurrenceRuleId!)
          : null;

      final patternChanged =
          currentRule != null && currentRule.rrule != updatedRule.rrule;

      await _recurrenceRuleRepository.update(updatedRule);

      await _todoRepository.updateTodo(updatedTodo);

      if (patternChanged) {
        // Pattern changed: delete future pending unworked instances and regenerate
        final futureTodos = await _todoRepository
            .getTodosByRecurrenceRuleIdFromDate(updatedRule.id, baseTodo.date);
        for (final todo in futureTodos) {
          if (todo.id != baseTodo.id && todo.status == TodoStatus.pending) {
            await _todoRepository.deleteTodo(todo.id);
          }
        }
        await _generateRecurringTasks.call();
      } else {
        // Pattern unchanged: update metadata and subtasks on existing future instances
        final futureTodos = await _todoRepository
            .getTodosByRecurrenceRuleIdFromDate(updatedRule.id, baseTodo.date);
        for (final todo in futureTodos) {
          if (todo.id == baseTodo.id) continue;
          final newSubTasks = updatedTodo.subTasks
              .map((st) => st.copyWith(id: _uuid.v4(), isCompleted: false))
              .toList();
          final updatedInstance = todo.copyWith(
            title: updatedTodo.title,
            description: updatedTodo.description,
            priority: updatedTodo.priority,
            targetSeconds: updatedTodo.targetSeconds,
            subTasks: newSubTasks,
            updatedAt: now,
          );
          await _todoRepository.updateTodo(updatedInstance);
        }
      }
    } else {
      // Repeat removed for future: end the rule at yesterday
      if (baseTodo.recurrenceRuleId != null) {
        final rule = await _recurrenceRuleRepository.findById(
          baseTodo.recurrenceRuleId!,
        );
        if (rule != null) {
          final baseDt = parseIsoDate(baseTodo.date);
          final yesterday = dateTimeToIso(
            DateTime(baseDt.year, baseDt.month, baseDt.day - 1),
          );
          await _recurrenceRuleRepository.update(
            rule.copyWith(endDate: yesterday, updatedAt: now),
          );
        }

        // Delete future pending instances
        final futureTodos = await _todoRepository
            .getTodosByRecurrenceRuleIdFromDate(
              baseTodo.recurrenceRuleId!,
              baseTodo.date,
            );
        for (final todo in futureTodos) {
          if (todo.id != baseTodo.id && todo.status == TodoStatus.pending) {
            await _todoRepository.deleteTodo(todo.id);
          }
        }
      }

      await _todoRepository.updateTodo(
        updatedTodo.copyWith(recurrenceRuleId: null),
      );
    }
  }

  Future<void> _executeAll({
    required TodoEntity baseTodo,
    required TodoEntity updatedTodo,
    required RecurrenceRuleEntity? updatedRule,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    if (updatedRule != null) {
      final currentRule = baseTodo.recurrenceRuleId != null
          ? await _recurrenceRuleRepository.findById(baseTodo.recurrenceRuleId!)
          : null;

      final patternChanged =
          currentRule != null && currentRule.rrule != updatedRule.rrule;

      await _recurrenceRuleRepository.update(updatedRule);

      await _todoRepository.updateTodo(updatedTodo);

      if (patternChanged) {
        final futureTodos = await _todoRepository
            .getTodosByRecurrenceRuleIdFromDate(updatedRule.id, baseTodo.date);
        for (final todo in futureTodos) {
          if (todo.id != baseTodo.id && todo.status == TodoStatus.pending) {
            await _todoRepository.deleteTodo(todo.id);
          }
        }
        await _generateRecurringTasks.call();
      }

      final allTodos = await _todoRepository.getTodosByRecurrenceRuleId(
        updatedRule.id,
      );
      for (final todo in allTodos) {
        if (todo.id == baseTodo.id) continue;
        final newSubTasks = updatedTodo.subTasks
            .map((st) => st.copyWith(id: _uuid.v4()))
            .toList();
        final updatedInstance = todo.copyWith(
          title: updatedTodo.title,
          description: updatedTodo.description,
          priority: updatedTodo.priority,
          targetSeconds: updatedTodo.targetSeconds,
          subTasks: newSubTasks,
          updatedAt: now,
        );
        await _todoRepository.updateTodo(updatedInstance, bypassLock: true);
      }
    } else {
      // Repeat removed for all instances: delete rule and unlink all instances
      if (baseTodo.recurrenceRuleId != null) {
        await _recurrenceRuleRepository.delete(baseTodo.recurrenceRuleId!);

        final allTodos = await _todoRepository.getTodosByRecurrenceRuleId(
          baseTodo.recurrenceRuleId!,
        );
        for (final todo in allTodos) {
          if (todo.id == baseTodo.id) continue;
          if (todo.status == TodoStatus.pending &&
              !isPastDate(todo.date) &&
              todo.date != baseTodo.date) {
            await _todoRepository.deleteTodo(todo.id);
          } else {
            await _todoRepository.updateTodo(
              todo.copyWith(recurrenceRuleId: null, updatedAt: now),
              bypassLock: true,
            );
          }
        }
      }

      await _todoRepository.updateTodo(
        updatedTodo.copyWith(recurrenceRuleId: null),
      );
    }
  }
}
