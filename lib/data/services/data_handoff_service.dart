import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/entities/data_handoff_payload.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

/// Result object returned by file pick & read operations.
class FileReadResult {
  final String filePath;
  final String fileName;
  final String content;

  const FileReadResult({
    required this.filePath,
    required this.fileName,
    required this.content,
  });
}

/// Service providing multi-format JSON data handoff and Markdown ingestion/export capabilities.
class DataHandoffService {
  final _uuid = const Uuid();

  /// Exports tasks, segments, and rules into a pretty-printed JSON payload string.
  String exportToJson({
    required List<TodoEntity> todos,
    required List<TimeSegmentEntity> timeSegments,
    required List<RecurrenceRuleEntity> recurrenceRules,
    required String date,
  }) {
    final payload = DataHandoffPayload(
      date: date,
      exportedAt: DateTime.now().toIso8601String(),
      todos: todos,
      timeSegments: timeSegments,
      recurrenceRules: recurrenceRules,
    );

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload.toJson());
  }

  /// Exports tasks and timecard statistics into a formatted Markdown document string.
  String exportToMarkdown({
    required List<TodoEntity> todos,
    required List<TimeSegmentEntity> timeSegments,
    required String date,
  }) {
    final buffer = StringBuffer();
    final nowIso = DateTime.now().toIso8601String();

    buffer.writeln('# SreerajP ToDo Checklist & Summary - $date');
    buffer.writeln('Exported: $nowIso');
    buffer.writeln();
    buffer.writeln('## Checklist Items');
    buffer.writeln();

    int totalTrackedSeconds = 0;
    for (final seg in timeSegments) {
      if (seg.endTime != null) {
        totalTrackedSeconds += seg.durationSeconds ?? 0;
      }
    }

    if (todos.isEmpty) {
      buffer.writeln('_No tasks found for date $date._');
    } else {
      for (final todo in todos) {
        final mark = todo.status == TodoStatus.completed ? 'x' : ' ';
        buffer.writeln('- [$mark] ${todo.title}');
        if (todo.description != null && todo.description!.trim().isNotEmpty) {
          final descLines = todo.description!.trim().split('\n');
          for (final line in descLines) {
            buffer.writeln('  > $line');
          }
        }
        for (final sub in todo.subTasks) {
          final subMark = sub.isCompleted ? 'x' : ' ';
          buffer.writeln('  - [$subMark] ${sub.title}');
        }
      }
    }

    buffer.writeln();
    buffer.writeln('## Timecard Statistics');
    buffer.writeln('- Total Tasks: ${todos.length}');
    buffer.writeln(
      '- Completed: ${todos.where((t) => t.status == TodoStatus.completed).length}',
    );
    buffer.writeln(
      '- Pending: ${todos.where((t) => t.status == TodoStatus.pending).length}',
    );
    buffer.writeln(
      '- Total Tracked Duration: ${formatDuration(totalTrackedSeconds)}',
    );

    return buffer.toString();
  }

  /// Parses a raw Markdown string containing `- [ ]` / `- [x]` items into task entities.
  List<TodoEntity> parseMarkdownChecklist(
    String markdownContent, {
    required String targetDate,
  }) {
    final nowIso = DateTime.now().toIso8601String();
    final lines = markdownContent.split('\n');
    final todos = <TodoEntity>[];

    TodoEntity? currentTodo;
    final currentSubtasks = <SubTaskItem>[];

    final checklistRegex = RegExp(r'^(\s*)[-*+]\s+\[([ xX])\]\s+(.*)$');

    void flushCurrentTodo() {
      if (currentTodo != null) {
        todos.add(
          currentTodo!.copyWith(subTasks: List.unmodifiable(currentSubtasks)),
        );
        currentTodo = null;
        currentSubtasks.clear();
      }
    }

    for (final rawLine in lines) {
      final match = checklistRegex.firstMatch(rawLine);
      if (match != null) {
        final indent = match.group(1) ?? '';
        final isChecked = (match.group(2) ?? ' ').toLowerCase() == 'x';
        final rawTitle = match.group(3) ?? '';
        final normalizedTitle = nfcNormalize(rawTitle.trim());

        if (normalizedTitle.isEmpty) continue;

        final isIndented = indent.length >= 2 || indent.contains('\t');

        if (isIndented && currentTodo != null) {
          // Treat as subtask of active todo
          currentSubtasks.add(
            SubTaskItem(
              id: _uuid.v4(),
              todoId: currentTodo!.id,
              title: normalizedTitle,
              isCompleted: isChecked,
              sortOrder: currentSubtasks.length,
              createdAt: nowIso,
              updatedAt: nowIso,
            ),
          );
        } else {
          // Top-level task
          flushCurrentTodo();
          final todoId = _uuid.v4();
          currentTodo = TodoEntity(
            id: todoId,
            date: targetDate,
            title: normalizedTitle,
            status: isChecked ? TodoStatus.completed : TodoStatus.pending,
            sortOrder: todos.length,
            createdAt: nowIso,
            updatedAt: nowIso,
          );
        }
      } else if (currentTodo != null) {
        final trimmed = rawLine.trim();
        if (trimmed.startsWith('>') || trimmed.startsWith('#')) {
          final noteText = trimmed.replaceAll(RegExp(r'^[>#]+\s*'), '').trim();
          if (noteText.isNotEmpty) {
            final normalizedNote = nfcNormalize(noteText);
            final existingDesc = currentTodo!.description;
            final updatedDesc = existingDesc == null || existingDesc.isEmpty
                ? normalizedNote
                : '$existingDesc\n$normalizedNote';
            currentTodo = currentTodo!.copyWith(description: updatedDesc);
          }
        }
      }
    }

    flushCurrentTodo();
    return todos;
  }

  /// Parses a JSON string into a validated [DataHandoffPayload].
  DataHandoffPayload parseJsonPayload(String jsonContent) {
    final Map<String, dynamic> decoded = jsonDecode(jsonContent);
    final payload = DataHandoffPayload.fromJson(decoded);

    // NFC-normalize all string values inside payload
    final normalizedTodos = payload.todos.map((t) {
      final normTitle = nfcNormalize(t.title);
      final normDesc = t.description != null
          ? nfcNormalize(t.description!)
          : null;
      final normSubtasks = t.subTasks.map((s) {
        return s.copyWith(title: nfcNormalize(s.title));
      }).toList();

      return t.copyWith(
        title: normTitle,
        description: normDesc,
        subTasks: normSubtasks,
      );
    }).toList();

    return DataHandoffPayload(
      version: payload.version,
      date: payload.date,
      exportedAt: payload.exportedAt,
      todos: normalizedTodos,
      timeSegments: payload.timeSegments,
      recurrenceRules: payload.recurrenceRules,
    );
  }

  /// Imports a [DataHandoffPayload] into SQLite repositories on the target date.
  /// Throws [DayLockedException] if target date is in the past.
  Future<int> importPayload(
    DataHandoffPayload payload, {
    required String targetDate,
    required TodoRepository todoRepo,
    required TimeSegmentRepository segmentRepo,
  }) async {
    if (isPastDate(targetDate)) {
      throw const DayLockedException('Cannot import tasks into a past day.');
    }

    final nowIso = DateTime.now().toIso8601String();
    int importedCount = 0;

    int currentMaxSort = await todoRepo.maxSortOrder(targetDate);

    for (final sourceTodo in payload.todos) {
      final normTitle = nfcNormalize(sourceTodo.title.trim());
      if (normTitle.isEmpty) continue;

      String finalTitle = normTitle;
      int dupCounter = 1;
      while (await todoRepo.titleExistsOnDate(finalTitle, targetDate)) {
        dupCounter++;
        finalTitle = '$normTitle ($dupCounter)';
      }

      currentMaxSort++;
      final newTodoId = _uuid.v4();
      final remappedSubtasks = sourceTodo.subTasks.map((s) {
        return s.copyWith(
          id: _uuid.v4(),
          todoId: newTodoId,
          title: nfcNormalize(s.title),
          createdAt: nowIso,
          updatedAt: nowIso,
        );
      }).toList();

      final newTodo = sourceTodo.copyWith(
        id: newTodoId,
        date: targetDate,
        title: finalTitle,
        sortOrder: currentMaxSort,
        subTasks: remappedSubtasks,
        createdAt: nowIso,
        updatedAt: nowIso,
      );

      await todoRepo.createTodo(newTodo);
      importedCount++;
    }

    // Insert time segments if present and matching
    for (final seg in payload.timeSegments) {
      if (seg.endTime != null) {
        final remappedSeg = seg.copyWith(id: _uuid.v4());
        try {
          await segmentRepo.insertManualSegment(remappedSeg);
        } catch (_) {}
      }
    }

    return importedCount;
  }

  /// Launches the system file picker to select a `.json` or `.md` file for import.
  Future<FileReadResult?> pickAndReadImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'md', 'txt'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.path == null) return null;

    final ioFile = File(file.path!);
    final content = await ioFile.readAsString();

    return FileReadResult(
      filePath: file.path!,
      fileName: file.name,
      content: content,
    );
  }

  /// Exports text content to a destination chosen via file picker or default directory.
  Future<String?> exportToFile({
    required String content,
    required String defaultFileName,
  }) async {
    String? selectedPath;
    try {
      selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Export File',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: [p.extension(defaultFileName).replaceAll('.', '')],
      );
    } catch (_) {}

    if (selectedPath == null) {
      // Fallback to Documents/Downloads folder if save dialog is unsupported
      final docsDir = await getApplicationDocumentsDirectory();
      selectedPath = p.join(docsDir.path, defaultFileName);
    }

    final targetFile = File(selectedPath);
    await targetFile.writeAsString(content);
    return selectedPath;
  }
}
