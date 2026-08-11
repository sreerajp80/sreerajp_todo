import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

enum AirQrPayloadType { tasks, timecard, backup, unknown }

/// Formatted AirQR payload container after reassembly and parsing.
@immutable
class AirQrParsedPayload {
  final AirQrPayloadType type;
  final List<TodoEntity> todos;
  final Map<String, dynamic> rawJson;
  final String date;

  const AirQrParsedPayload({
    required this.type,
    this.todos = const [],
    this.rawJson = const {},
    this.date = '',
  });
}

/// Serializes and deserializes domain entities for AirQR stream transfer.
class AirQrPayloadService {
  static const String headerPrefix = 'SREERAJP_TODO|v1|';

  /// Serializes a list of tasks into an AirQR stream payload.
  static String encodeTasks(List<TodoEntity> todos, {required String date}) {
    final payloadMap = {
      'type': 'tasks',
      'date': date,
      'exported_at': DateTime.now().toIso8601String(),
      'todos': todos.map((t) => t.toMap()).toList(),
    };
    return '$headerPrefix${jsonEncode(payloadMap)}';
  }

  /// Serializes a daily timecard summary into an AirQR stream payload.
  static String encodeTimecard({
    required String date,
    required int totalSecondsTracked,
    required int completedCount,
    required int pendingCount,
    required List<TodoEntity> todos,
  }) {
    final payloadMap = {
      'type': 'timecard',
      'date': date,
      'exported_at': DateTime.now().toIso8601String(),
      'total_seconds_tracked': totalSecondsTracked,
      'completed_count': completedCount,
      'pending_count': pendingCount,
      'todos': todos.map((t) => t.toMap()).toList(),
    };
    return '$headerPrefix${jsonEncode(payloadMap)}';
  }

  /// Serializes a full database backup map into an AirQR stream payload.
  static String encodeBackup(Map<String, dynamic> backupMap) {
    final payloadMap = {
      'type': 'backup',
      'exported_at': DateTime.now().toIso8601String(),
      'backup_data': backupMap,
    };
    return '$headerPrefix${jsonEncode(payloadMap)}';
  }

  /// Parses a reassembled raw payload string into an AirQrParsedPayload object.
  static AirQrParsedPayload parsePayload(String raw) {
    if (!raw.startsWith(headerPrefix)) {
      // Attempt fallback direct JSON parse
      try {
        final Map<String, dynamic> json = jsonDecode(raw);
        return _parseJsonMap(json);
      } catch (e) {
        return const AirQrParsedPayload(type: AirQrPayloadType.unknown);
      }
    }

    try {
      final jsonString = raw.substring(headerPrefix.length);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return _parseJsonMap(json);
    } catch (e) {
      if (kDebugMode) debugPrint('AirQrPayloadService parse error: $e');
      return const AirQrParsedPayload(type: AirQrPayloadType.unknown);
    }
  }

  static AirQrParsedPayload _parseJsonMap(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'unknown';
    final dateStr = json['date'] as String? ?? '';

    if (typeStr == 'tasks' || typeStr == 'timecard') {
      final rawTodos = json['todos'] as List<dynamic>? ?? [];
      final todos = <TodoEntity>[];
      for (final item in rawTodos) {
        if (item is Map<String, dynamic>) {
          try {
            todos.add(TodoEntity.fromMap(item));
          } catch (_) {
            // Ignore corrupted individual todo items
          }
        }
      }

      return AirQrParsedPayload(
        type: typeStr == 'tasks'
            ? AirQrPayloadType.tasks
            : AirQrPayloadType.timecard,
        todos: todos,
        rawJson: json,
        date: dateStr,
      );
    } else if (typeStr == 'backup') {
      return AirQrParsedPayload(
        type: AirQrPayloadType.backup,
        rawJson: json['backup_data'] as Map<String, dynamic>? ?? {},
      );
    }

    return const AirQrParsedPayload(type: AirQrPayloadType.unknown);
  }
}
