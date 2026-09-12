import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/daily_progress_header.dart';

void main() {
  testWidgets('DailyProgressHeader returns empty when todos list is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DailyProgressHeader(todos: [], date: '2026-09-11'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DailyProgressHeader), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('DailyProgressHeader renders percentage and completed count', (
    tester,
  ) async {
    final todos = [
      const TodoEntity(
        id: '1',
        date: '2026-09-11',
        title: 'Task 1',
        status: TodoStatus.completed,
        createdAt: '2026-09-11T00:00:00Z',
        updatedAt: '2026-09-11T00:00:00Z',
      ),
      const TodoEntity(
        id: '2',
        date: '2026-09-11',
        title: 'Task 2',
        status: TodoStatus.pending,
        createdAt: '2026-09-11T00:00:00Z',
        updatedAt: '2026-09-11T00:00:00Z',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DailyProgressHeader(todos: todos, date: '2026-09-11'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('50%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'DailyProgressHeader renders 100% and congrats when all completed',
    (tester) async {
      final todos = [
        const TodoEntity(
          id: '1',
          date: '2026-09-11',
          title: 'Task 1',
          status: TodoStatus.completed,
          createdAt: '2026-09-11T00:00:00Z',
          updatedAt: '2026-09-11T00:00:00Z',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DailyProgressHeader(todos: todos, date: '2026-09-11'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
      expect(find.text('All caught up! 🎉'), findsOneWidget);
    },
  );
}
