import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';

part 'recurrence_rule_entity.freezed.dart';

@freezed
class RecurrenceRuleEntity with _$RecurrenceRuleEntity {
  const RecurrenceRuleEntity._();

  const factory RecurrenceRuleEntity({
    required String id,
    required String title,
    String? description,
    required String rrule,
    required String startDate,
    String? endDate,
    @Default(true) bool active,
    // Series values copied onto every new occurrence. All three are null on
    // rules saved before database v12; see [hasSeriesValues].
    TodoPriority? priority,
    int? targetSeconds,
    List<String>? subTaskTitles,
    required String createdAt,
    required String updatedAt,
  }) = _RecurrenceRuleEntity;

  /// True when this rule stores priority, target time and sub-tasks itself.
  /// Older rules do not, and new occurrences then copy the latest one.
  bool get hasSeriesValues => priority != null;

  /// A copy that stores [priority], [targetSeconds] and the titles of
  /// [subTasks] as the series values.
  ///
  /// Call this only when the change is meant for the whole series (creating
  /// a repeat, or editing "this and future" / "all"), never for a one-off
  /// edit of a single occurrence.
  RecurrenceRuleEntity withSeriesValues({
    required TodoPriority priority,
    required int? targetSeconds,
    required List<SubTaskItem> subTasks,
  }) => copyWith(
    priority: priority,
    targetSeconds: targetSeconds,
    subTaskTitles: [for (final st in subTasks) nfcNormalize(st.title)],
  );

  /// [withSeriesValues] with the values taken from [todo].
  RecurrenceRuleEntity withSeriesValuesFrom(TodoEntity todo) =>
      withSeriesValues(
        priority: todo.priority,
        targetSeconds: todo.targetSeconds,
        subTasks: todo.subTasks,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'rrule': rrule,
    'start_date': startDate,
    'end_date': endDate,
    'active': active ? 1 : 0,
    'priority': priority?.toDbString(),
    'target_seconds': targetSeconds,
    'sub_task_titles': subTaskTitles == null ? null : jsonEncode(subTaskTitles),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory RecurrenceRuleEntity.fromMap(Map<String, dynamic> map) =>
      RecurrenceRuleEntity(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        rrule: map['rrule'] as String,
        startDate: map['start_date'] as String,
        endDate: map['end_date'] as String?,
        active: (map['active'] as int) == 1,
        // The three series columns are missing from older backups and
        // hand-off payloads, so each one is read as optional.
        priority: map['priority'] == null
            ? null
            : TodoPriority.fromDbString(map['priority'] as String),
        targetSeconds: map['target_seconds'] as int?,
        subTaskTitles: _decodeTitles(map['sub_task_titles']),
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
      );

  static List<String>? _decodeTitles(Object? raw) {
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<String>().toList();
    } on FormatException {
      return null;
    }
  }
}
