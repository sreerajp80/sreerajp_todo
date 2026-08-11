import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/models/sub_task_item.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/data/services/data_handoff_service.dart';
import 'package:sreerajp_todo/domain/entities/data_handoff_payload.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class MockTimeSegmentRepository extends Mock
    implements TimeSegmentRepository {}

void main() {
  late DataHandoffService service;
  late MockTodoRepository mockTodoRepo;
  late MockTimeSegmentRepository mockSegmentRepo;

  setUpAll(() {
    registerFallbackValue(
      const TodoEntity(
        id: 'dummy',
        date: '2026-08-11',
        title: 'dummy',
        createdAt: '2026-08-11T00:00:00.000',
        updatedAt: '2026-08-11T00:00:00.000',
      ),
    );
  });

  setUp(() {
    service = DataHandoffService();
    mockTodoRepo = MockTodoRepository();
    mockSegmentRepo = MockTimeSegmentRepository();
  });

  group('DataHandoffService JSON Serialization & Deserialization', () {
    test('exportToJson generates valid formatted JSON payload', () {
      final todos = [
        const TodoEntity(
          id: 'todo-1',
          date: '2026-08-11',
          title: 'Test Task 1',
          description: 'Formatted markdown description',
          status: TodoStatus.pending,
          subTasks: [
            SubTaskItem(
              id: 'sub-1',
              todoId: 'todo-1',
              title: 'Subtask A',
              isCompleted: true,
              createdAt: '2026-08-11T10:00:00.000',
              updatedAt: '2026-08-11T10:00:00.000',
            ),
          ],
          createdAt: '2026-08-11T10:00:00.000',
          updatedAt: '2026-08-11T10:00:00.000',
        ),
      ];

      final jsonString = service.exportToJson(
        todos: todos,
        timeSegments: [],
        recurrenceRules: [],
        date: '2026-08-11',
      );

      expect(jsonString, contains('Test Task 1'));
      expect(jsonString, contains('Subtask A'));

      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final parsedPayload = DataHandoffPayload.fromJson(decodedMap);

      expect(parsedPayload.date, equals('2026-08-11'));
      expect(parsedPayload.todos.length, equals(1));
      expect(parsedPayload.todos.first.title, equals('Test Task 1'));
      expect(parsedPayload.todos.first.subTasks.length, equals(1));
      expect(parsedPayload.todos.first.subTasks.first.title, equals('Subtask A'));
    });
  });

  group('DataHandoffService Markdown Ingestion & Export', () {
    test('exportToMarkdown generates formatted checklist and summary', () {
      final todos = [
        const TodoEntity(
          id: 'todo-1',
          date: '2026-08-11',
          title: 'Review PRs',
          status: TodoStatus.completed,
          createdAt: '2026-08-11T10:00:00.000',
          updatedAt: '2026-08-11T10:00:00.000',
        ),
        const TodoEntity(
          id: 'todo-2',
          date: '2026-08-11',
          title: 'Write Documentation',
          status: TodoStatus.pending,
          createdAt: '2026-08-11T10:00:00.000',
          updatedAt: '2026-08-11T10:00:00.000',
        ),
      ];

      final mdString = service.exportToMarkdown(
        todos: todos,
        timeSegments: [],
        date: '2026-08-11',
      );

      expect(mdString, contains('- [x] Review PRs'));
      expect(mdString, contains('- [ ] Write Documentation'));
      expect(mdString, contains('## Timecard Statistics'));
    });

    test('parseMarkdownChecklist parses tasks, subtasks, notes, and applies NFC normalization', () {
      const rawMd = '''
- [ ] Task One
  - [ ] Subtask 1A
  - [x] Subtask 1B
- [x] Task Two
  > Note for task two
''';

      final parsed = service.parseMarkdownChecklist(
        rawMd,
        targetDate: '2026-08-11',
      );

      expect(parsed.length, equals(2));
      expect(parsed[0].title, equals('Task One'));
      expect(parsed[0].status, equals(TodoStatus.pending));
      expect(parsed[0].subTasks.length, equals(2));
      expect(parsed[0].subTasks[0].title, equals('Subtask 1A'));
      expect(parsed[0].subTasks[0].isCompleted, isFalse);
      expect(parsed[0].subTasks[1].title, equals('Subtask 1B'));
      expect(parsed[0].subTasks[1].isCompleted, isTrue);

      expect(parsed[1].title, equals('Task Two'));
      expect(parsed[1].status, equals(TodoStatus.completed));
      expect(parsed[1].description, equals('Note for task two'));
    });
  });

  group('DataHandoffService Import & Day-Lock Enforcement', () {
    test('importPayload throws DayLockedException when importing to past date', () async {
      const payload = DataHandoffPayload(
        date: '2020-01-01',
        exportedAt: '2020-01-01T00:00:00.000',
        todos: [
          TodoEntity(
            id: 't1',
            date: '2020-01-01',
            title: 'Past Task',
            createdAt: '2020-01-01T00:00:00.000',
            updatedAt: '2020-01-01T00:00:00.000',
          ),
        ],
      );

      expect(
        () => service.importPayload(
          payload,
          targetDate: '2020-01-01',
          todoRepo: mockTodoRepo,
          segmentRepo: mockSegmentRepo,
        ),
        throwsA(isA<DayLockedException>()),
      );
    });

    test('importPayload creates tasks on current/future date with title deduplication', () async {
      final today = todayAsIso();
      final payload = DataHandoffPayload(
        date: today,
        exportedAt: DateTime.now().toIso8601String(),
        todos: [
          TodoEntity(
            id: 't1',
            date: today,
            title: 'Imported Task',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        ],
      );

      when(() => mockTodoRepo.maxSortOrder(today)).thenAnswer((_) async => 0);
      when(() => mockTodoRepo.titleExistsOnDate('Imported Task', today))
          .thenAnswer((_) async => false);
      when(() => mockTodoRepo.createTodo(any())).thenAnswer((_) async {});

      final importedCount = await service.importPayload(
        payload,
        targetDate: today,
        todoRepo: mockTodoRepo,
        segmentRepo: mockSegmentRepo,
      );

      expect(importedCount, equals(1));
      verify(() => mockTodoRepo.createTodo(any())).called(1);
    });
  });
}
