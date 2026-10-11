import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_segment_entity.freezed.dart';

@freezed
class TimeSegmentEntity with _$TimeSegmentEntity {
  const TimeSegmentEntity._();

  const factory TimeSegmentEntity({
    required String id,
    required String todoId,
    required String startTime,
    String? endTime,
    int? durationSeconds,
    @Default(false) bool interrupted,
    @Default(false) bool manual,
    String? notes,

    /// Set once the start/end times were changed while the parent todo was
    /// already completed or dropped. Sticky: it is never cleared again.
    @Default(false) bool editedAfterCompletion,

    /// ISO 8601 UTC timestamp of the last start/end time edit, if any.
    String? timesEditedAt,
    required String createdAt,
  }) = _TimeSegmentEntity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'todo_id': todoId,
    'start_time': startTime,
    'end_time': endTime,
    'duration_seconds': durationSeconds,
    'interrupted': interrupted ? 1 : 0,
    'manual': manual ? 1 : 0,
    'notes': notes,
    'edited_after_completion': editedAfterCompletion ? 1 : 0,
    'times_edited_at': timesEditedAt,
    'created_at': createdAt,
  };

  factory TimeSegmentEntity.fromMap(Map<String, dynamic> map) =>
      TimeSegmentEntity(
        id: map['id'] as String,
        todoId: map['todo_id'] as String,
        startTime: map['start_time'] as String,
        endTime: map['end_time'] as String?,
        durationSeconds: map['duration_seconds'] as int?,
        interrupted: (map['interrupted'] as int) == 1,
        manual: (map['manual'] as int) == 1,
        notes: map['notes'] as String?,
        // Read defensively: a backup or hand-off payload written by an older
        // build has no such key.
        editedAfterCompletion: (map['edited_after_completion'] as int?) == 1,
        timesEditedAt: map['times_edited_at'] as String?,
        createdAt: map['created_at'] as String,
      );
}
