import 'package:flutter/foundation.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_scope.dart';

/// Caps and bounds constraints for P2P Wi-Fi Sync payloads as per 3.14 specification.
abstract final class P2pSyncBounds {
  static const int maxTodos = 10000;
  static const int maxFieldLen = 4096;
  static const Duration handshakeTimeout = Duration(seconds: 30);
  static const Duration hostIdleTimeout = Duration(seconds: 120);
}

/// Container for serialized synchronization items sent across P2P TCP connections.
@immutable
class P2pSyncPayload {
  final String date;
  final String exportedAt;
  final P2pSyncScope scope;
  final List<TodoEntity> todos;
  final List<TimeSegmentEntity> timeSegments;
  final List<RecurrenceRuleEntity> recurrenceRules;
  final List<SpacedRepetitionItemEntity> masteryItems;

  const P2pSyncPayload({
    required this.date,
    required this.exportedAt,
    required this.scope,
    this.todos = const [],
    this.timeSegments = const [],
    this.recurrenceRules = const [],
    this.masteryItems = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'exported_at': exportedAt,
    'scope': scope.toJson(),
    'todos': todos.map((t) => t.toMap()).toList(),
    'time_segments': timeSegments.map((s) => s.toMap()).toList(),
    'recurrence_rules': recurrenceRules.map((r) => r.toMap()).toList(),
    'mastery_items': masteryItems.map((m) => m.toMap()).toList(),
  };

  factory P2pSyncPayload.fromJson(Map<String, dynamic> json) {
    final scopeJson = json['scope'] as Map<String, dynamic>? ?? {};
    final scope = P2pSyncScope.fromJson(scopeJson);

    final rawTodos = json['todos'] as List<dynamic>? ?? [];
    final todos = <TodoEntity>[];
    for (final item in rawTodos.take(P2pSyncBounds.maxTodos)) {
      if (item is Map<String, dynamic>) {
        try {
          todos.add(TodoEntity.fromMap(_sanitizeFieldLengths(item)));
        } catch (_) {}
      }
    }

    final rawSegments = json['time_segments'] as List<dynamic>? ?? [];
    final timeSegments = <TimeSegmentEntity>[];
    for (final item in rawSegments) {
      if (item is Map<String, dynamic>) {
        try {
          timeSegments.add(
            TimeSegmentEntity.fromMap(_sanitizeFieldLengths(item)),
          );
        } catch (_) {}
      }
    }

    final rawRules = json['recurrence_rules'] as List<dynamic>? ?? [];
    final recurrenceRules = <RecurrenceRuleEntity>[];
    for (final item in rawRules) {
      if (item is Map<String, dynamic>) {
        try {
          recurrenceRules.add(
            RecurrenceRuleEntity.fromMap(_sanitizeFieldLengths(item)),
          );
        } catch (_) {}
      }
    }

    final rawMastery = json['mastery_items'] as List<dynamic>? ?? [];
    final masteryItems = <SpacedRepetitionItemEntity>[];
    for (final item in rawMastery) {
      if (item is Map<String, dynamic>) {
        try {
          masteryItems.add(
            SpacedRepetitionItemEntity.fromMap(_sanitizeFieldLengths(item)),
          );
        } catch (_) {}
      }
    }

    return P2pSyncPayload(
      date: json['date'] as String? ?? '',
      exportedAt: json['exported_at'] as String? ?? '',
      scope: scope,
      todos: todos,
      timeSegments: timeSegments,
      recurrenceRules: recurrenceRules,
      masteryItems: masteryItems,
    );
  }

  static Map<String, dynamic> _sanitizeFieldLengths(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{...map};
    sanitized.putIfAbsent('sort_order', () => 0);
    // A peer on an older build sends no priority or target time. Default them
    // here so the row still inserts instead of failing on a NOT NULL column.
    sanitized.putIfAbsent('priority', () => 'normal');
    sanitized.putIfAbsent('target_seconds', () => null);
    for (final entry in map.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val is String && val.length > P2pSyncBounds.maxFieldLen) {
        sanitized[key] = val.substring(0, P2pSyncBounds.maxFieldLen);
      }
    }
    return sanitized;
  }
}

/// Statistics and counters returned after executing an Add-Only Non-Destructive Merge.
@immutable
class P2pSyncMergeResult {
  final int todosAdded;
  final int todosSkipped;
  final int segmentsAdded;
  final int segmentsSkipped;
  final int rulesAdded;
  final int rulesSkipped;
  final int masteryAdded;
  final int masterySkipped;
  final int dayLockViolations;

  const P2pSyncMergeResult({
    this.todosAdded = 0,
    this.todosSkipped = 0,
    this.segmentsAdded = 0,
    this.segmentsSkipped = 0,
    this.rulesAdded = 0,
    this.rulesSkipped = 0,
    this.masteryAdded = 0,
    this.masterySkipped = 0,
    this.dayLockViolations = 0,
  });

  int get totalAdded => todosAdded + segmentsAdded + rulesAdded + masteryAdded;

  int get totalSkipped =>
      todosSkipped + segmentsSkipped + rulesSkipped + masterySkipped;

  Map<String, dynamic> toJson() => {
    'todos_added': todosAdded,
    'todos_skipped': todosSkipped,
    'segments_added': segmentsAdded,
    'segments_skipped': segmentsSkipped,
    'rules_added': rulesAdded,
    'rules_skipped': rulesSkipped,
    'mastery_added': masteryAdded,
    'mastery_skipped': masterySkipped,
    'day_lock_violations': dayLockViolations,
  };
}
