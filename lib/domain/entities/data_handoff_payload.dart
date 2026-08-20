import 'package:flutter/foundation.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

/// Container model for structured JSON data export and import.
@immutable
class DataHandoffPayload {
  final int version;
  final String date;
  final String exportedAt;
  final List<TodoEntity> todos;
  final List<TimeSegmentEntity> timeSegments;
  final List<RecurrenceRuleEntity> recurrenceRules;

  const DataHandoffPayload({
    this.version = 1,
    required this.date,
    required this.exportedAt,
    this.todos = const [],
    this.timeSegments = const [],
    this.recurrenceRules = const [],
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'date': date,
    'exported_at': exportedAt,
    'todos': todos.map((t) => _todoToMapWithSubtasks(t)).toList(),
    'time_segments': timeSegments.map((s) => s.toMap()).toList(),
    'recurrence_rules': recurrenceRules.map((r) => r.toMap()).toList(),
  };

  factory DataHandoffPayload.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 1;
    final date = json['date'] as String? ?? '';
    final exportedAt = json['exported_at'] as String? ?? '';

    final rawTodos = json['todos'] as List<dynamic>? ?? [];
    final todos = <TodoEntity>[];
    for (final item in rawTodos) {
      if (item is Map<String, dynamic>) {
        try {
          todos.add(_todoFromMapWithSubtasks(item));
        } catch (_) {}
      }
    }

    final rawSegments = json['time_segments'] as List<dynamic>? ?? [];
    final timeSegments = <TimeSegmentEntity>[];
    for (final item in rawSegments) {
      if (item is Map<String, dynamic>) {
        try {
          timeSegments.add(TimeSegmentEntity.fromMap(item));
        } catch (_) {}
      }
    }

    final rawRules = json['recurrence_rules'] as List<dynamic>? ?? [];
    final recurrenceRules = <RecurrenceRuleEntity>[];
    for (final item in rawRules) {
      if (item is Map<String, dynamic>) {
        try {
          recurrenceRules.add(RecurrenceRuleEntity.fromMap(item));
        } catch (_) {}
      }
    }

    return DataHandoffPayload(
      version: version,
      date: date,
      exportedAt: exportedAt,
      todos: todos,
      timeSegments: timeSegments,
      recurrenceRules: recurrenceRules,
    );
  }

  static Map<String, dynamic> _todoToMapWithSubtasks(TodoEntity todo) {
    final map = todo.toMap();
    if (todo.subTasks.isNotEmpty) {
      map['sub_tasks'] = todo.subTasks.map((s) => s.toMap()).toList();
    }
    return map;
  }

  static TodoEntity _todoFromMapWithSubtasks(Map<String, dynamic> map) {
    final rawSubtasks = map['sub_tasks'] as List<dynamic>? ?? [];
    final subTasks = <SubTaskItem>[];
    for (final s in rawSubtasks) {
      if (s is Map<String, dynamic>) {
        try {
          subTasks.add(SubTaskItem.fromMap(s));
        } catch (_) {}
      }
    }
    return TodoEntity.fromMap(map, subTasks: subTasks);
  }
}
