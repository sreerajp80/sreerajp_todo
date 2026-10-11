import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_task_item.freezed.dart';

@freezed
class SubTaskItem with _$SubTaskItem {
  const SubTaskItem._();

  const factory SubTaskItem({
    required String id,
    required String todoId,
    required String title,
    @Default(false) bool isCompleted,
    @Default(0) int sortOrder,
    required String createdAt,
    required String updatedAt,
  }) = _SubTaskItem;

  Map<String, dynamic> toMap() => {
    'id': id,
    'todo_id': todoId,
    'title': title,
    'is_completed': isCompleted ? 1 : 0,
    'sort_order': sortOrder,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory SubTaskItem.fromMap(Map<String, dynamic> map) => SubTaskItem(
    id: map['id'] as String,
    todoId: map['todo_id'] as String,
    title: map['title'] as String,
    isCompleted: (map['is_completed'] as int) == 1,
    sortOrder: map['sort_order'] as int,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
  );
}
