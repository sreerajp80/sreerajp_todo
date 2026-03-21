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
        createdAt: map['created_at'] as String,
      );
}
