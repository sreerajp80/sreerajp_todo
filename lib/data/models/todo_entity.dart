import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

part 'todo_entity.freezed.dart';

@freezed
class TodoEntity with _$TodoEntity {
  const TodoEntity._();

  const factory TodoEntity({
    required String id,
    required String date,
    required String title,
    String? description,
    @Default(TodoStatus.pending) TodoStatus status,
    String? portedTo,
    String? sourceDate,
    String? recurrenceRuleId,
    @Default(0) int sortOrder,
    required String createdAt,
    required String updatedAt,
  }) = _TodoEntity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'title': title,
        'description': description,
        'status': status.toDbString(),
        'ported_to': portedTo,
        'source_date': sourceDate,
        'recurrence_rule_id': recurrenceRuleId,
        'sort_order': sortOrder,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory TodoEntity.fromMap(Map<String, dynamic> map) => TodoEntity(
        id: map['id'] as String,
        date: map['date'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        status: TodoStatus.fromDbString(map['status'] as String),
        portedTo: map['ported_to'] as String?,
        sourceDate: map['source_date'] as String?,
        recurrenceRuleId: map['recurrence_rule_id'] as String?,
        sortOrder: map['sort_order'] as int,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
      );
}
