import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/task_history/task_history_screen.dart';

import '../helpers/test_fixtures.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this._todo, this._history);
  final TodoEntity _todo;
  final List<TodoHistoryEntity> _history;

  @override
  Future<TodoEntity?> getTodoById(String id) async => _todo;

  @override
  Future<List<TodoHistoryEntity>> getHistoryForTodo(String todoId) async =>
      _history;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('renders task summary and history events', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();

    final todo = buildTodo(
      id: 'task-hist-1',
      date: '2026-08-29',
      title: 'History Test Task',
      description: 'A detailed task description',
      status: TodoStatus.completed,
    );

    final events = [
      const TodoHistoryEntity(
        id: 'e1',
        todoId: 'task-hist-1',
        eventType: TodoHistoryEventType.created,
        eventTime: '2026-08-29T08:00:00.000Z',
        description: 'Task created for 2026-08-29',
        createdAt: '2026-08-29T08:00:00.000Z',
      ),
      const TodoHistoryEntity(
        id: 'e2',
        todoId: 'task-hist-1',
        eventType: TodoHistoryEventType.moved,
        eventTime: '2026-08-29T09:00:00.000Z',
        description: 'Moved from 2026-08-28 to 2026-08-29',
        createdAt: '2026-08-29T09:00:00.000Z',
      ),
    ];

    final fakeRepo = _FakeTodoRepository(todo, events);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todoRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TaskHistoryScreen(todoId: 'task-hist-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('History Test Task'), findsOneWidget);
    expect(find.text('A detailed task description'), findsOneWidget);
    expect(find.text('Task created for 2026-08-29'), findsOneWidget);
    expect(find.text('Moved from 2026-08-28 to 2026-08-29'), findsOneWidget);
  });

  testWidgets('renders moved task with original creation date indicator', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();

    final todo = buildTodo(
      id: 'task-hist-moved',
      date: '2026-08-29',
      title: 'Moved Task',
      sourceDate: '2026-08-25',
      status: TodoStatus.pending,
    );

    final events = [
      const TodoHistoryEntity(
        id: 'e1',
        todoId: 'task-hist-moved',
        eventType: TodoHistoryEventType.created,
        eventTime: '2026-08-25T08:00:00.000Z',
        description: 'Task created for 2026-08-25',
        createdAt: '2026-08-25T08:00:00.000Z',
      ),
      const TodoHistoryEntity(
        id: 'e2',
        todoId: 'task-hist-moved',
        eventType: TodoHistoryEventType.moved,
        eventTime: '2026-08-29T09:00:00.000Z',
        description: 'Moved from 2026-08-25 to 2026-08-29',
        createdAt: '2026-08-29T09:00:00.000Z',
      ),
    ];

    final fakeRepo = _FakeTodoRepository(todo, events);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todoRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TaskHistoryScreen(todoId: 'task-hist-moved'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Moved Task'), findsOneWidget);
    expect(find.text('Task created for 2026-08-25'), findsOneWidget);
    expect(find.text('Moved from 2026-08-25 to 2026-08-29'), findsOneWidget);
    expect(find.byIcon(Icons.move_up_rounded), findsWidgets);
  });
}
