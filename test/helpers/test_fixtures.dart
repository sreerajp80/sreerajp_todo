import 'package:sreerajp_todo/data/backup/backup_file_info.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

String dateOffsetIso(int offsetDays) {
  final date = DateTime.now().add(Duration(days: offsetDays));
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

TodoEntity buildTodo({
  required String id,
  String? date,
  String? title,
  String? description,
  TodoStatus status = TodoStatus.pending,
  String? portedTo,
  String? sourceDate,
  String? recurrenceRuleId,
  int sortOrder = 0,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return TodoEntity(
    id: id,
    date: date ?? dateOffsetIso(0),
    title: title ?? 'Task $id',
    description: description,
    status: status,
    portedTo: portedTo,
    sourceDate: sourceDate,
    recurrenceRuleId: recurrenceRuleId,
    sortOrder: sortOrder,
    createdAt: now,
    updatedAt: now,
  );
}

TimeSegmentEntity buildSegment({
  required String id,
  required String todoId,
  required DateTime start,
  DateTime? end,
  int? durationSeconds,
  bool interrupted = false,
  bool manual = false,
}) {
  return TimeSegmentEntity(
    id: id,
    todoId: todoId,
    startTime: start.toIso8601String(),
    endTime: end?.toIso8601String(),
    durationSeconds: durationSeconds,
    interrupted: interrupted,
    manual: manual,
    createdAt: DateTime.now().toUtc().toIso8601String(),
  );
}

BackupFileInfo buildBackupInfo({
  required String filePath,
  required String fileName,
  DateTime? createdAt,
  int fileSizeBytes = 1024,
}) {
  return BackupFileInfo(
    filePath: filePath,
    fileName: fileName,
    createdAt: createdAt ?? DateTime(2026, 3, 22, 10, 30),
    fileSizeBytes: fileSizeBytes,
  );
}
