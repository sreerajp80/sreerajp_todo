import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/statistics_notifier.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';

import '../helpers/test_fixtures.dart';
import '../presentation/undo_snackbar_test.dart'
    show FakeTimeSegmentRepository, InMemoryTodoRepository;

class _MockStatisticsQueryService extends Mock
    implements StatisticsQueryService {}

/// Statistics are refreshed by the same callback; keep them off the database.
class _IdleStatisticsNotifier extends StatisticsNotifier {
  _IdleStatisticsNotifier()
    : super(_MockStatisticsQueryService(), workingDays: () => const {});

  @override
  Future<void> refresh({bool force = false}) async {}
}

// Undo of a move must put the task back on every day it covered, not only
// on the day it was moved from.
void main() {
  late InMemoryTodoRepository todoRepository;
  late ProviderContainer container;
  late String today;

  Future<void> setUpWith(TodoEntity todo) async {
    todoRepository = InMemoryTodoRepository([todo]);
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        todoRepositoryProvider.overrideWithValue(todoRepository),
        timeSegmentRepositoryProvider.overrideWithValue(
          FakeTimeSegmentRepository(),
        ),
        statisticsProvider.overrideWith((ref) => _IdleStatisticsNotifier()),
      ],
    );
    addTearDown(container.dispose);
  }

  setUp(() => today = dateOffsetIso(0));

  test('undo of an explicit move restores the start date', () async {
    await setUpWith(
      buildTodo(
        id: 'multi',
        date: today,
        title: 'Multi-day',
      ).copyWith(sourceDate: dateOffsetIso(-2)),
    );
    final notifier = container.read(dailyTodoProvider(today).notifier);

    await notifier.moveTodo('multi', dateOffsetIso(3), detach: true);
    expect((await todoRepository.getTodoById('multi'))!.sourceDate, isNull);

    await notifier.undoLastStatusChange();

    final todo = await todoRepository.getTodoById('multi');
    expect(todo!.date, today);
    expect(todo.sourceDate, dateOffsetIso(-2));
  });

  test('undo of a carry-over clears the start date it added', () async {
    final yesterday = dateOffsetIso(-1);
    await setUpWith(buildTodo(id: 'carried', date: yesterday, title: 'Old'));
    final notifier = container.read(dailyTodoProvider(yesterday).notifier);

    await notifier.moveTodo('carried', today);
    expect(
      (await todoRepository.getTodoById('carried'))!.sourceDate,
      yesterday,
    );

    await notifier.undoLastStatusChange();

    final todo = await todoRepository.getTodoById('carried');
    expect(todo!.date, yesterday);
    expect(todo.sourceDate, isNull);
  });
}
