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

// A daily-list change to a deck task must show on the Mastery Deck screen
// without the user having to open and close the task.
void main() {
  const deckId = 'deck-1';
  late InMemoryTodoRepository todoRepository;
  late ProviderContainer container;
  late String today;

  setUp(() async {
    today = dateOffsetIso(0);
    todoRepository = InMemoryTodoRepository([
      buildTodo(
        id: 'todo-1',
        date: today,
        title: 'Deck task',
      ).copyWith(spacedRepetitionItemId: deckId),
    ]);
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
  });

  Future<TodoEntity> deckTask() async {
    final todos = await container.read(masteryDeckTodosProvider(deckId).future);
    return todos.single;
  }

  test('moving a deck task refreshes the deck list', () async {
    // Keep the deck provider alive and cached, like an open deck screen.
    container.listen(masteryDeckTodosProvider(deckId), (_, _) {});
    expect((await deckTask()).date, today);

    final tomorrow = dateOffsetIso(1);
    await container
        .read(dailyTodoProvider(today).notifier)
        .moveTodo('todo-1', tomorrow, detach: true);

    expect((await deckTask()).date, tomorrow);
  });

  test('completing a deck task refreshes the deck list', () async {
    container.listen(masteryDeckTodosProvider(deckId), (_, _) {});
    // Completing stops the timer, which refreshes the task's timer state; keep
    // it open as the daily list tile does.
    container.listen(timeTrackingProvider('todo-1'), (_, _) {});
    expect((await deckTask()).status, TodoStatus.pending);

    await container
        .read(dailyTodoProvider(today).notifier)
        .markCompleted('todo-1');

    expect((await deckTask()).status, TodoStatus.completed);
  });

  test('editing a deck task refreshes the deck list', () async {
    container.listen(masteryDeckTodosProvider(deckId), (_, _) {});
    final original = await deckTask();

    await container
        .read(dailyTodoProvider(today).notifier)
        .updateTodo(original.copyWith(title: 'Renamed task'));

    expect((await deckTask()).title, 'Renamed task');
  });
}
