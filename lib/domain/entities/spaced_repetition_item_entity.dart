import 'package:freezed_annotation/freezed_annotation.dart';

part 'spaced_repetition_item_entity.freezed.dart';

@freezed
class SpacedRepetitionItemEntity with _$SpacedRepetitionItemEntity {
  const SpacedRepetitionItemEntity._();

  const factory SpacedRepetitionItemEntity({
    required String id,
    required String title,
    String? description,
    @Default(1) int level,
    @Default(2.5) double easeFactor,
    @Default(1) int intervalDays,
    required String nextReviewDate,
    String? lastReviewedAt,
    @Default(true) bool active,
    required String createdAt,
    required String updatedAt,
  }) = _SpacedRepetitionItemEntity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'level': level,
    'ease_factor': easeFactor,
    'interval_days': intervalDays,
    'next_review_date': nextReviewDate,
    'last_reviewed_at': lastReviewedAt,
    'active': active ? 1 : 0,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory SpacedRepetitionItemEntity.fromMap(Map<String, dynamic> map) =>
      SpacedRepetitionItemEntity(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        level: map['level'] as int? ?? 1,
        easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
        intervalDays: map['interval_days'] as int? ?? 1,
        nextReviewDate: map['next_review_date'] as String,
        lastReviewedAt: map['last_reviewed_at'] as String?,
        active: (map['active'] as int) == 1,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
      );
}
