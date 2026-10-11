import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_history_entity.freezed.dart';

enum TodoHistoryEventType {
  created,
  moved,
  timerStarted,
  timerStopped,
  timerPaused,
  manualSegmentAdded,
  statusChanged,
  subtaskToggled,
  edited;

  String toDbString() => switch (this) {
    created => 'created',
    moved => 'moved',
    timerStarted => 'timer_started',
    timerStopped => 'timer_stopped',
    timerPaused => 'timer_paused',
    manualSegmentAdded => 'manual_segment_added',
    statusChanged => 'status_changed',
    subtaskToggled => 'subtask_toggled',
    edited => 'edited',
  };

  static TodoHistoryEventType fromDbString(String value) => switch (value) {
    'created' => created,
    'moved' => moved,
    'timer_started' => timerStarted,
    'timer_stopped' => timerStopped,
    'timer_paused' => timerPaused,
    'manual_segment_added' => manualSegmentAdded,
    'status_changed' => statusChanged,
    'subtask_toggled' => subtaskToggled,
    'edited' => edited,
    _ => edited,
  };
}

@freezed
class TodoHistoryEntity with _$TodoHistoryEntity {
  const TodoHistoryEntity._();

  const factory TodoHistoryEntity({
    required String id,
    required String todoId,
    required TodoHistoryEventType eventType,
    required String eventTime,
    required String description,
    String? metadata,
    required String createdAt,
  }) = _TodoHistoryEntity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'todo_id': todoId,
    'event_type': eventType.toDbString(),
    'event_time': eventTime,
    'description': description,
    'metadata': metadata,
    'created_at': createdAt,
  };

  factory TodoHistoryEntity.fromMap(Map<String, dynamic> map) =>
      TodoHistoryEntity(
        id: map['id'] as String,
        todoId: map['todo_id'] as String,
        eventType: TodoHistoryEventType.fromDbString(
          map['event_type'] as String,
        ),
        eventTime: map['event_time'] as String,
        description: map['description'] as String,
        metadata: map['metadata'] as String?,
        createdAt: map['created_at'] as String,
      );
}
