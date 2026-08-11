import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_intention_entity.freezed.dart';

@freezed
class DailyIntentionEntity with _$DailyIntentionEntity {
  const DailyIntentionEntity._();

  const factory DailyIntentionEntity({
    required String date,
    required String intentionText,
    required String createdAt,
  }) = _DailyIntentionEntity;

  Map<String, dynamic> toMap() => {
        'date': date,
        'intention_text': intentionText,
        'created_at': createdAt,
      };

  factory DailyIntentionEntity.fromMap(Map<String, dynamic> map) =>
      DailyIntentionEntity(
        date: map['date'] as String,
        intentionText: map['intention_text'] as String,
        createdAt: map['created_at'] as String,
      );
}
