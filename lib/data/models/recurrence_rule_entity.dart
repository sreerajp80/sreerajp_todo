import 'package:freezed_annotation/freezed_annotation.dart';

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
    required String createdAt,
    required String updatedAt,
  }) = _RecurrenceRuleEntity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'rrule': rrule,
        'start_date': startDate,
        'end_date': endDate,
        'active': active ? 1 : 0,
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
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
      );
}
