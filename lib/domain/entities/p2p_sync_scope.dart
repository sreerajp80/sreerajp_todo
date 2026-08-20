import 'package:flutter/foundation.dart';

/// Categories of items that can be selectively included in a P2P Wi-Fi sync session.
enum P2pSyncCategory { todaysTasks, timeSegments, recurrenceRules, masteryDeck }

/// Represents the active selection scope for a P2P Wi-Fi sync transfer.
@immutable
class P2pSyncScope {
  final bool todaysTasks;
  final bool timeSegments;
  final bool recurrenceRules;
  final bool masteryDeck;

  const P2pSyncScope({
    this.todaysTasks = true,
    this.timeSegments = true,
    this.recurrenceRules = true,
    this.masteryDeck = true,
  });

  const P2pSyncScope.full()
    : todaysTasks = true,
      timeSegments = true,
      recurrenceRules = true,
      masteryDeck = true;

  bool get isFullSync =>
      todaysTasks && timeSegments && recurrenceRules && masteryDeck;

  P2pSyncScope copyWith({
    bool? todaysTasks,
    bool? timeSegments,
    bool? recurrenceRules,
    bool? masteryDeck,
  }) {
    return P2pSyncScope(
      todaysTasks: todaysTasks ?? this.todaysTasks,
      timeSegments: timeSegments ?? this.timeSegments,
      recurrenceRules: recurrenceRules ?? this.recurrenceRules,
      masteryDeck: masteryDeck ?? this.masteryDeck,
    );
  }

  Map<String, dynamic> toJson() => {
    'todays_tasks': todaysTasks,
    'time_segments': timeSegments,
    'recurrence_rules': recurrenceRules,
    'mastery_deck': masteryDeck,
  };

  factory P2pSyncScope.fromJson(Map<String, dynamic> json) => P2pSyncScope(
    todaysTasks: json['todays_tasks'] as bool? ?? true,
    timeSegments: json['time_segments'] as bool? ?? true,
    recurrenceRules: json['recurrence_rules'] as bool? ?? true,
    masteryDeck: json['mastery_deck'] as bool? ?? true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is P2pSyncScope &&
          runtimeType == other.runtimeType &&
          todaysTasks == other.todaysTasks &&
          timeSegments == other.timeSegments &&
          recurrenceRules == other.recurrenceRules &&
          masteryDeck == other.masteryDeck;

  @override
  int get hashCode =>
      todaysTasks.hashCode ^
      timeSegments.hashCode ^
      recurrenceRules.hashCode ^
      masteryDeck.hashCode;
}
