import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_runner.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late TodoDao todoDao;
  late TimeSegmentDao segmentDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    todoDao = TodoDao(databaseService);
    segmentDao = TimeSegmentDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  const String virama = '്';
  const String zwj = '‍';

  // "അവൻ" written the two different ways.
  const String chilluSequenceWord = 'അവന$virama$zwj';
  const String chilluAtomicWord = 'അവൻ';

  TodoEntity makeTodo({
    String id = 'todo-1',
    String date = '2026-03-21',
    String title = 'Test Todo',
    String? description,
  }) {
    final String now = DateTime.now().toUtc().toIso8601String();
    return TodoEntity(
      id: id,
      date: date,
      title: title,
      description: description,
      status: TodoStatus.pending,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  TimeSegmentEntity makeSegment({
    String id = 'seg-1',
    String todoId = 'todo-1',
    String? notes,
  }) {
    final DateTime start = DateTime(2026, 3, 21, 9);
    return TimeSegmentEntity(
      id: id,
      todoId: todoId,
      startTime: start.toIso8601String(),
      endTime: start.add(const Duration(hours: 1)).toIso8601String(),
      durationSeconds: 3600,
      manual: true,
      notes: notes,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  group('Chillu-aware search', () {
    test(
      'atomic Chillu query finds a task stored with the ZWJ sequence',
      () async {
        await todoDao.insert(makeTodo(title: chilluSequenceWord));

        final List<TodoEntity> results = await todoDao.searchByTitle(
          chilluAtomicWord,
        );

        expect(results, hasLength(1));
        expect(results.first.title, chilluSequenceWord);
      },
    );

    test(
      'ZWJ sequence query finds a task stored with the atomic Chillu',
      () async {
        await todoDao.insert(makeTodo(title: chilluAtomicWord));

        final List<TodoEntity> results = await todoDao.searchByTitle(
          chilluSequenceWord,
        );

        expect(results, hasLength(1));
        expect(results.first.title, chilluAtomicWord);
      },
    );

    test('a whole Malayalam word is one token, not single letters', () async {
      await todoDao.insert(makeTodo(title: 'കാര്യം ചെയ്യണം'));

      expect(await todoDao.searchByTitle('കാര്യം'), hasLength(1));
    });

    test('accented and unaccented Latin match each other', () async {
      await todoDao.insert(makeTodo(title: 'Visit café'));

      expect(await todoDao.searchByTitle('cafe'), hasLength(1));
    });
  });

  group('Segment notes in search', () {
    test('a task is found by the text of its segment note', () async {
      await todoDao.insert(makeTodo(title: 'Untitled work'));
      await segmentDao.insert(
        makeSegment(notes: 'Reviewed the quarterly plan'),
      );

      final results = await todoDao.searchByTitle('quarterly');

      expect(results, hasLength(1));
      expect(results.first.id, 'todo-1');
    });

    test('a note is searchable with the other Chillu spelling', () async {
      await todoDao.insert(makeTodo(title: 'Untitled work'));
      await segmentDao.insert(makeSegment(notes: chilluSequenceWord));

      expect(await todoDao.searchByTitle(chilluAtomicWord), hasLength(1));
    });

    test('editing a note updates the index both ways', () async {
      await todoDao.insert(makeTodo(title: 'Untitled work'));
      await segmentDao.insert(makeSegment(notes: 'first note'));

      expect(await todoDao.searchByTitle('first'), hasLength(1));

      await segmentDao.updateNotes('seg-1', 'second note');

      expect(await todoDao.searchByTitle('first'), isEmpty);
      expect(await todoDao.searchByTitle('second'), hasLength(1));
    });

    test('clearing a note removes it from the index', () async {
      await todoDao.insert(makeTodo(title: 'Untitled work'));
      await segmentDao.insert(makeSegment(notes: 'temporary note'));

      await segmentDao.updateNotes('seg-1', '');

      expect(await todoDao.searchByTitle('temporary'), isEmpty);
      expect(await todoDao.searchByTitle('Untitled'), hasLength(1));
    });

    test('deleting the segments removes their notes from the index', () async {
      await todoDao.insert(makeTodo(title: 'Untitled work'));
      await segmentDao.insert(makeSegment(notes: 'disposable note'));

      await segmentDao.deleteByTodoId('todo-1');

      expect(await todoDao.searchByTitle('disposable'), isEmpty);
    });
  });

  group('searchWithMatchedNotes', () {
    test('reports the note that explains the hit', () async {
      await todoDao.insert(makeTodo(title: 'Untitled work'));
      await segmentDao.insert(makeSegment(notes: 'Reviewed the budget'));

      final results = await todoDao.searchWithMatchedNotes('budget');

      expect(results, hasLength(1));
      expect(results.first.matchedNote, 'Reviewed the budget');
    });

    test(
      'leaves the note null when the title already explains the hit',
      () async {
        await todoDao.insert(makeTodo(title: 'Budget review'));
        await segmentDao.insert(makeSegment(notes: 'Some other note'));

        final results = await todoDao.searchWithMatchedNotes('budget');

        expect(results, hasLength(1));
        expect(results.first.matchedNote, isNull);
      },
    );
  });

  group('Index maintenance', () {
    test('updating a todo replaces its index row', () async {
      await todoDao.insert(makeTodo(title: 'Original title'));
      final TodoEntity? stored = await todoDao.findById('todo-1');

      await todoDao.update(stored!.copyWith(title: 'Replacement title'));

      expect(await todoDao.searchByTitle('Original'), isEmpty);
      expect(await todoDao.searchByTitle('Replacement'), hasLength(1));
    });

    test('deleting a todo removes its index row', () async {
      await todoDao.insert(makeTodo(title: 'Doomed task'));
      await todoDao.delete('todo-1');

      expect(await todoDao.searchByTitle('Doomed'), isEmpty);
    });
  });

  group('Migration V8', () {
    test('upgrading from V7 adds notes and rebuilds a working index', () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 7,
          singleInstance: false,
          onCreate: (db, version) async =>
              runDatabaseMigrations(db, 0, version),
        ),
      );

      final String now = DateTime.now().toUtc().toIso8601String();
      await db.insert('todos', <String, Object?>{
        'id': 'legacy-1',
        'date': '2026-03-20',
        'title': chilluSequenceWord,
        'description': 'Visit café',
        'status': 'pending',
        'sort_order': 0,
        'created_at': now,
        'updated_at': now,
      });

      await runDatabaseMigrations(db, 7, kDatabaseVersion);

      final columns = await db.rawQuery('PRAGMA table_info(time_segments)');
      expect(
        columns.any((column) => column['name'] == 'notes'),
        isTrue,
        reason: 'notes column was not added',
      );

      final service = DatabaseService.forTesting(db);
      final upgradedDao = TodoDao(service);

      // The pre-existing row is searchable through the folded index.
      expect(await upgradedDao.searchByTitle(chilluAtomicWord), hasLength(1));
      expect(await upgradedDao.searchByTitle('cafe'), hasLength(1));

      await service.close();
    });
  });
}
