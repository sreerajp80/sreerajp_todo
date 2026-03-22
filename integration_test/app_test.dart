import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/app.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/backup/backup_service.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_runner.dart';
import 'package:sreerajp_todo/data/database/migrations/migration_v1.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 8 integration flows', () {
    testWidgets(
      'happy path creates, tracks, completes, and surfaces in statistics',
      (tester) async {
        final harness = await _TestHarness.pump(tester);
        addTearDown(harness.dispose);

        expect(find.text(formatDateFromIso(todayAsIso())), findsOneWidget);

        await _createTodoThroughUi(tester, title: 'Integration Test Task');
        expect(find.text('Integration Test Task'), findsOneWidget);

        await tester.tap(find.byTooltip(AppStrings.startTimer));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.byTooltip(AppStrings.stopTimer));
        await tester.pumpAndSettle();

        expect(find.text('00:00:02'), findsOneWidget);

        await _openTaskMenu(tester, itemIndex: 0);
        await tester.tap(find.text(AppStrings.statusCompleted).last);
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.statusCompleted), findsOneWidget);

        await _openAppMenu(tester);
        await tester.tap(find.text(AppStrings.statistics).last);
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.stats.perItemOverview));
        await tester.pumpAndSettle();

        expect(find.text('Integration Test Task'), findsWidgets);
      },
    );

    testWidgets(
      'copy flow copies selected todos to tomorrow and preserves source date',
      (tester) async {
        final harness = await _TestHarness.pump(tester);
        addTearDown(harness.dispose);

        await harness.todoRepository.createTodo(
          _buildTodo(id: 'copy-1', title: 'Copy A'),
        );
        await harness.todoRepository.createTodo(
          _buildTodo(id: 'copy-2', title: 'Copy B'),
        );
        await harness.todoRepository.createTodo(
          _buildTodo(id: 'copy-3', title: 'Copy C'),
        );
        await harness.reloadToday(tester);

        await _openAppMenu(tester);
        await tester.tap(find.text(AppStrings.copyToAnotherDay).last);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile).at(0));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CheckboxListTile).at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.next));
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.selectTargetDate));
        await tester.pumpAndSettle();
        await _pickTomorrow(tester);
        await tester.tap(find.text(AppStrings.next));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining(AppStrings.copyConfirm));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip(AppStrings.nextDay));
        await tester.pumpAndSettle();

        expect(find.text('Copy A'), findsOneWidget);
        expect(find.text('Copy B'), findsOneWidget);
        expect(find.text('Copy C'), findsNothing);

        final copiedTodos = await harness.todoRepository.getTodosByDate(
          _dateOffsetIso(1),
        );
        expect(copiedTodos, hasLength(2));
        expect(
          copiedTodos.every((todo) => todo.sourceDate == todayAsIso()),
          isTrue,
        );
      },
    );

    testWidgets(
      'day lock hides creation controls and rejects programmatic mutation',
      (tester) async {
        final harness = await _TestHarness.pump(tester);
        addTearDown(harness.dispose);

        await harness.todoRepository.createTodo(
          _buildTodo(
            id: 'yesterday-1',
            date: _dateOffsetIso(-1),
            title: 'Locked task',
          ),
        );

        await tester.tap(find.byTooltip(AppStrings.previousDay));
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byIcon(Icons.lock_outline), findsWidgets);
        expect(find.byTooltip(AppStrings.openTaskActions), findsNothing);

        expect(
          () => harness.todoRepository.createTodo(
            _buildTodo(
              id: 'yesterday-2',
              date: _dateOffsetIso(-1),
              title: 'Should fail',
            ),
          ),
          throwsA(isA<DayLockedException>()),
        );
      },
    );

    testWidgets('Unicode titles round-trip and remain searchable', (
      tester,
    ) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'المهمة العربية',
      );
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(editableText.textDirection, TextDirection.rtl);

      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      await harness.todoRepository.createTodo(
        _buildTodo(id: 'unicode-jp', title: '日本語タスク'),
      );
      await harness.reloadToday(tester);

      expect(find.text('المهمة العربية'), findsOneWidget);
      expect(find.text('日本語タスク'), findsOneWidget);

      await tester.tap(find.byTooltip(AppStrings.searchResults));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'المهمة');
      await tester.pump(
        const Duration(milliseconds: kAutocompleteDebounceMills + 50),
      );
      await tester.pumpAndSettle();

      expect(find.text('المهمة العربية'), findsOneWidget);
    });

    testWidgets('undo restores completed and ported todos', (tester) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      await harness.todoRepository.createTodo(
        _buildTodo(id: 'undo-1', title: 'Undo integration task'),
      );
      await harness.reloadToday(tester);

      await _openTaskMenu(tester, itemIndex: 0);
      await tester.tap(find.text(AppStrings.statusCompleted).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.undo));
      await tester.pumpAndSettle();

      final restoredAfterComplete = await harness.todoRepository.getTodoById(
        'undo-1',
      );
      expect(restoredAfterComplete?.status, TodoStatus.pending);

      await _openTaskMenu(tester, itemIndex: 0);
      await tester.tap(find.text(AppStrings.port).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.confirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.undo));
      await tester.pumpAndSettle();

      final sourceTodo = await harness.todoRepository.getTodoById('undo-1');
      final tomorrowTodos = await harness.todoRepository.getTodosByDate(
        _dateOffsetIso(1),
      );
      expect(sourceTodo?.status, TodoStatus.pending);
      expect(
        tomorrowTodos.where((todo) => todo.sourceDate == todayAsIso()),
        isEmpty,
      );
    });

    testWidgets('backup round-trip restores todo statuses', (tester) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      await harness.todoRepository.createTodo(
        _buildTodo(id: 'backup-1', title: 'Pending restore'),
      );
      await harness.todoRepository.createTodo(
        _buildTodo(
          id: 'backup-2',
          title: 'Completed restore',
          status: TodoStatus.completed,
        ),
      );
      await harness.todoRepository.createTodo(
        _buildTodo(
          id: 'backup-3',
          title: 'Dropped restore',
          status: TodoStatus.dropped,
        ),
      );

      final backupDirectory = await Directory(
        p.join(harness.workingDirectory.path, 'backups'),
      ).create(recursive: true);
      final backupPath = await harness.backupService.exportDatabase(
        destinationPath: backupDirectory.path,
        passphrase: 'testpass123',
      );

      for (final todo in await harness.todoRepository.getTodosByDate(
        todayAsIso(),
      )) {
        await harness.todoRepository.deleteTodo(todo.id);
      }
      expect(
        await harness.todoRepository.getTodosByDate(todayAsIso()),
        isEmpty,
      );

      await harness.backupService.importDatabase(
        sourcePath: backupPath,
        passphrase: 'testpass123',
      );

      final restored = await harness.todoRepository.getTodosByDate(
        todayAsIso(),
      );
      expect(
        restored.map((todo) => todo.status),
        containsAll(<TodoStatus>[
          TodoStatus.pending,
          TodoStatus.completed,
          TodoStatus.dropped,
        ]),
      );
    });

    testWidgets('manual segments render with duration and reject overlap', (
      tester,
    ) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      await harness.todoRepository.createTodo(
        _buildTodo(id: 'segment-1', title: 'Manual segment task'),
      );
      await harness.timeSegmentRepository.insertManualSegment(
        TimeSegmentEntity(
          id: 'manual-1',
          todoId: 'segment-1',
          startTime: DateTime.parse(
            '${todayAsIso()}T09:00:00',
          ).toIso8601String(),
          endTime: DateTime.parse('${todayAsIso()}T10:30:00').toIso8601String(),
          durationSeconds: 5400,
          manual: true,
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
      await harness.reloadToday(tester);

      await _openTaskMenu(tester, itemIndex: 0);
      await tester.tap(find.text(AppStrings.viewSegments).last);
      await tester.pumpAndSettle();

      expect(find.text('01:30:00'), findsOneWidget);
      expect(find.text(AppStrings.manualSegmentShort), findsOneWidget);

      expect(
        () => harness.timeSegmentRepository.insertManualSegment(
          TimeSegmentEntity(
            id: 'manual-2',
            todoId: 'segment-1',
            startTime: DateTime.parse(
              '${todayAsIso()}T09:30:00',
            ).toIso8601String(),
            endTime: DateTime.parse(
              '${todayAsIso()}T11:00:00',
            ).toIso8601String(),
            durationSeconds: 5400,
            manual: true,
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        ),
        throwsA(isA<SegmentOverlapException>()),
      );
    });

    testWidgets('bulk status change can be undone', (tester) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      await harness.todoRepository.createTodo(
        _buildTodo(id: 'bulk-1', title: 'Bulk 1'),
      );
      await harness.todoRepository.createTodo(
        _buildTodo(id: 'bulk-2', title: 'Bulk 2'),
      );
      await harness.todoRepository.createTodo(
        _buildTodo(id: 'bulk-3', title: 'Bulk 3'),
      );
      await harness.reloadToday(tester);

      await tester.longPress(find.text('Bulk 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppStrings.selectAll));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.completeAll));
      await tester.pumpAndSettle();

      final completed = await harness.todoRepository.getTodosByDate(
        todayAsIso(),
      );
      expect(
        completed.every((todo) => todo.status == TodoStatus.completed),
        isTrue,
      );

      await tester.tap(find.text(AppStrings.undo));
      await tester.pumpAndSettle();

      final restored = await harness.todoRepository.getTodosByDate(
        todayAsIso(),
      );
      expect(
        restored.every((todo) => todo.status == TodoStatus.pending),
        isTrue,
      );
    });

    testWidgets('recurring tasks generate and regenerate expected todos', (
      tester,
    ) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      final now = DateTime.now().toUtc().toIso8601String();
      await harness.recurrenceRuleDao.insert(
        RecurrenceRuleEntity(
          id: 'rule-1',
          title: 'Daily Standup',
          rrule: 'FREQ=DAILY',
          startDate: todayAsIso(),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await harness.container.read(generateRecurringTasksProvider).call();

      for (var offset = 0; offset <= 7; offset++) {
        final todos = await harness.todoRepository.getTodosByDate(
          _dateOffsetIso(offset),
        );
        expect(todos.any((todo) => todo.title == 'Daily Standup'), isTrue);
      }

      final todayTodos = await harness.todoRepository.getTodosByDate(
        todayAsIso(),
      );
      final todayStandup = todayTodos.firstWhere(
        (todo) => todo.title == 'Daily Standup',
      );
      await harness.todoRepository.updateTodo(
        todayStandup.copyWith(title: 'Edited Standup'),
      );

      final tomorrowTodos = await harness.todoRepository.getTodosByDate(
        _dateOffsetIso(1),
      );
      final tomorrowStandup = tomorrowTodos.firstWhere(
        (todo) => todo.title == 'Daily Standup',
      );
      await harness.todoRepository.deleteTodo(
        tomorrowStandup.id,
        bypassLock: true,
      );

      await harness.container.read(generateRecurringTasksProvider).call();

      final editedToday = await harness.todoRepository.getTodosByDate(
        todayAsIso(),
      );
      final regeneratedTomorrow = await harness.todoRepository.getTodosByDate(
        _dateOffsetIso(1),
      );
      expect(editedToday.any((todo) => todo.title == 'Edited Standup'), isTrue);
      expect(
        regeneratedTomorrow.any((todo) => todo.title == 'Daily Standup'),
        isTrue,
      );
    });

    testWidgets('offline-only smoke keeps CRUD and statistics working', (
      tester,
    ) async {
      final harness = await _TestHarness.pump(tester);
      addTearDown(harness.dispose);

      await _createTodoThroughUi(tester, title: 'Offline smoke task');
      await _openTaskMenu(tester, itemIndex: 0);
      await tester.tap(find.text(AppStrings.statusCompleted).last);
      await tester.pumpAndSettle();

      await _openAppMenu(tester);
      await tester.tap(find.text(AppStrings.statistics).last);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.statistics), findsWidgets);
      expect(find.text(AppStrings.stats.dailyOverview), findsOneWidget);
    });
  });
}

class _TestHarness {
  _TestHarness({
    required this.container,
    required this.databaseService,
    required this.workingDirectory,
  }) : todoRepository = container.read(todoRepositoryProvider),
       timeSegmentRepository = container.read(timeSegmentRepositoryProvider),
       backupService = container.read(backupServiceProvider),
       recurrenceRuleDao = container.read(recurrenceRuleDaoProvider);

  final ProviderContainer container;
  final DatabaseService databaseService;
  final Directory workingDirectory;
  final TodoRepository todoRepository;
  final TimeSegmentRepository timeSegmentRepository;
  final BackupService backupService;
  final RecurrenceRuleDao recurrenceRuleDao;

  static Future<_TestHarness> pump(WidgetTester tester) async {
    final tempRoot = await getTemporaryDirectory();
    final workingDirectory = await Directory(
      p.join(
        tempRoot.path,
        'phase8_integration_${DateTime.now().microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);
    final databasePath = p.join(workingDirectory.path, kDatabaseName);
    final databaseService = await _openTestDatabaseService(databasePath);

    final container = ProviderContainer(
      overrides: [databaseServiceProvider.overrideWithValue(databaseService)],
    );

    await container.read(databaseServiceProvider).database;
    await container.read(repairOrphanedSegmentsProvider).call();
    await container.read(generateRecurringTasksProvider).call();

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const TodoApp()),
    );
    await tester.pumpAndSettle();

    return _TestHarness(
      container: container,
      databaseService: databaseService,
      workingDirectory: workingDirectory,
    );
  }

  Future<void> reloadToday(WidgetTester tester) async {
    await container.read(dailyTodoProvider(todayAsIso()).notifier).loadTodos();
    await tester.pumpAndSettle();
  }

  Future<void> dispose() async {
    container.dispose();
    await databaseService.close();
    if (await workingDirectory.exists()) {
      await workingDirectory.delete(recursive: true);
    }
  }
}

Future<DatabaseService> _openTestDatabaseService(String databasePath) async {
  final bootstrap = DatabaseService();
  final database = await bootstrap.openDatabaseAt(
    databasePath,
    version: kDatabaseVersion,
    onCreate: (db, version) async => runMigrationV1(db),
    onUpgrade: (db, oldVersion, newVersion) async =>
        runDatabaseMigrations(db, oldVersion, newVersion),
    onOpen: (db) async {
      await db.execute('PRAGMA journal_mode=WAL');
      await db.execute('PRAGMA foreign_keys=ON');
    },
    singleInstance: false,
  );
  return DatabaseService.forTesting(database, databasePath: databasePath);
}

Future<void> _createTodoThroughUi(
  WidgetTester tester, {
  required String title,
  String? description,
}) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).first, title);
  if (description != null) {
    await tester.enterText(find.byType(TextFormField).at(1), description);
  }

  await tester.tap(find.text(AppStrings.save));
  await tester.pumpAndSettle();
}

Future<void> _openTaskMenu(
  WidgetTester tester, {
  required int itemIndex,
}) async {
  await tester.tap(find.byTooltip(AppStrings.openTaskActions).at(itemIndex));
  await tester.pumpAndSettle();
}

Future<void> _openAppMenu(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(PopupMenuButton<String>),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pickTomorrow(WidgetTester tester) async {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  await tester.tap(find.text('${tomorrow.day}').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

TodoEntity _buildTodo({
  required String id,
  required String title,
  String? date,
  TodoStatus status = TodoStatus.pending,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  return TodoEntity(
    id: id,
    date: date ?? todayAsIso(),
    title: title,
    status: status,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

String _dateOffsetIso(int offsetDays) {
  final date = DateTime.now().add(Duration(days: offsetDays));
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
