import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_reflection_entity.freezed.dart';

@freezed
class DailyReflectionEntity with _$DailyReflectionEntity {
  const DailyReflectionEntity._();

  const factory DailyReflectionEntity({
    required String date,
    required String reflectionNote,
    @Default(0) int completedSeconds,
    @Default(0) int droppedSeconds,
    required String createdAt,
    required String updatedAt,
  }) = _DailyReflectionEntity;

  Map<String, dynamic> toMap() => {
    'date': date,
    'reflection_note': reflectionNote,
    'completed_seconds': completedSeconds,
    'dropped_seconds': droppedSeconds,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory DailyReflectionEntity.fromMap(Map<String, dynamic> map) =>
      DailyReflectionEntity(
        date: map['date'] as String,
        reflectionNote: map['reflection_note'] as String,
        completedSeconds: map['completed_seconds'] as int? ?? 0,
        droppedSeconds: map['dropped_seconds'] as int? ?? 0,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
      );
}
