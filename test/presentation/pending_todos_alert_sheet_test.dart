import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart';
import 'package:sreerajp_todo/presentation/screens/settings/pending_alerts_screen.dart';

import '../helpers/test_l10n.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class MockTimeSegmentRepository extends Mock implements TimeSegmentRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const TodoEntity(
        id: 'fallback',
        date: '2026-08-28',
        title: 'fallback',
        createdAt: '2026-08-28T09:00:00Z',
        updatedAt: '2026-08-28T09:00:00Z',
      ),
    );
  });

  final dummyTodos = [
    const TodoEntity(
      id: 't-1',
      date: '2026-08-28',
      title: 'Review quarterly goals',
      status: TodoStatus.pending,
      priority: TodoPriority.high,
      targetSeconds: 1800,
      createdAt: '2026-08-28T09:00:00Z',
      updatedAt: '2026-08-28T09:00:00Z',
    ),
    const TodoEntity(
      id: 't-2',
      date: '2026-08-28',
      title: 'Draft release notes',
      status: TodoStatus.working,
      priority: TodoPriority.normal,
      createdAt: '2026-08-28T09:30:00Z',
      updatedAt: '2026-08-28T09:30:00Z',
    ),
  ];

  final dummyPreviousTodos = [
    const TodoEntity(
      id: 't-prev-1',
      date: '2026-08-27',
      title: 'Leftover task from yesterday',
      status: TodoStatus.pending,
      priority: TodoPriority.urgent,
      createdAt: '2026-08-27T09:00:00Z',
      updatedAt: '2026-08-27T09:00:00Z',
    ),
  ];

  Future<void> pumpAlertSheet(
    WidgetTester tester, {
    List<TodoEntity> todayTodos = const [],
    List<TodoEntity> previousTodos = const [],
    TodoRepository? mockRepo,
  }) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    final repo = mockRepo ?? MockTodoRepository();
    final timeSegmentRepo = MockTimeSegmentRepository();
    when(
      () => timeSegmentRepo.getRunningSegment(any()),
    ).thenAnswer((_) async => null);
    when(() => timeSegmentRepo.getSegments(any())).thenAnswer((_) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todoRepositoryProvider.overrideWithValue(repo),
          timeSegmentRepositoryProvider.overrideWithValue(timeSegmentRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => PendingTodosAlertSheet.show(
                    context,
                    todayTodos: todayTodos,
                    previousTodos: previousTodos,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'PendingTodosAlertSheet renders both today and previous date tasks with Port button',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final mockRepo = MockTodoRepository();
      when(() => mockRepo.getTodosByDate(any())).thenAnswer((_) async => []);
      when(
        () => mockRepo.getTodoById('t-prev-1'),
      ).thenAnswer((_) async => dummyPreviousTodos.first);
      when(
        () => mockRepo.titleExistsOnDate(
          any(),
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);
      when(() => mockRepo.moveTodo(any(), any())).thenAnswer((_) async => {});

      await pumpAlertSheet(
        tester,
        todayTodos: dummyTodos,
        previousTodos: dummyPreviousTodos,
        mockRepo: mockRepo,
      );

      expect(find.text(testL10n.pendingAlertsSheetTitle), findsOneWidget);
      expect(find.text(testL10n.pendingAlertsTodaySection), findsOneWidget);
      expect(find.text(testL10n.pendingAlertsPreviousSection), findsOneWidget);

      expect(find.text('Review quarterly goals'), findsOneWidget);
      expect(find.text('Draft release notes'), findsOneWidget);
      expect(find.text('Leftover task from yesterday'), findsOneWidget);

      expect(find.text(testL10n.pendingAlertsStartTimer), findsOneWidget);
      expect(find.text(testL10n.pendingAlertsPortToToday), findsOneWidget);

      // Tap Port to Today
      await tester.tap(find.text(testL10n.pendingAlertsPortToToday));
      await tester.pumpAndSettle();

      verify(() => mockRepo.moveTodo('t-prev-1', any())).called(1);
    },
  );

  testWidgets(
    'PendingTodosAlertSheet displays empty state when no pending tasks',
    (tester) async {
      await pumpAlertSheet(
        tester,
        todayTodos: const [],
        previousTodos: const [],
      );

      expect(find.text(testL10n.pendingAlertsSheetTitle), findsOneWidget);
      expect(find.text(testL10n.pendingAlertsSheetEmpty), findsWidgets);
    },
  );

  testWidgets('PendingAlertsScreen renders switches and interval selector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PendingAlertsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(testL10n.pendingAlertsTitle), findsOneWidget);
    expect(find.text(testL10n.pendingAlertsEnabled), findsOneWidget);
    expect(find.text(testL10n.pendingAlertsDayStart), findsWidgets);
    expect(find.text(testL10n.pendingAlertsInterval), findsOneWidget);
    expect(find.text(testL10n.pendingAlertsPreview), findsOneWidget);
  });
}
