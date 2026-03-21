import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/daily_todo_notifier.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/application/time_tracking_notifier.dart';
import 'package:sreerajp_todo/application/time_tracking_state.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_dropped.dart';
import 'package:sreerajp_todo/domain/usecases/port_todo.dart';

// --- Data layer ---

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final todoDaoProvider = Provider<TodoDao>((ref) {
  return TodoDao(ref.read(databaseServiceProvider));
});

final timeSegmentDaoProvider = Provider<TimeSegmentDao>((ref) {
  return TimeSegmentDao(ref.read(databaseServiceProvider));
});

final recurrenceRuleDaoProvider = Provider<RecurrenceRuleDao>((ref) {
  return RecurrenceRuleDao(ref.read(databaseServiceProvider));
});

final statisticsQueryServiceProvider = Provider<StatisticsQueryService>((ref) {
  return StatisticsQueryService(ref.read(databaseServiceProvider));
});

// --- Repositories ---

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(ref.read(todoDaoProvider));
});

final timeSegmentRepositoryProvider = Provider<TimeSegmentRepository>((ref) {
  return TimeSegmentRepositoryImpl(
    ref.read(timeSegmentDaoProvider),
    ref.read(todoDaoProvider),
  );
});

// --- Use-cases ---

final markTodoCompletedProvider = Provider<MarkTodoCompleted>((ref) {
  return MarkTodoCompleted(
    ref.read(todoRepositoryProvider),
    ref.read(timeSegmentRepositoryProvider),
  );
});

final markTodoDroppedProvider = Provider<MarkTodoDropped>((ref) {
  return MarkTodoDropped(
    ref.read(todoRepositoryProvider),
    ref.read(timeSegmentRepositoryProvider),
  );
});

final portTodoProvider = Provider<PortTodo>((ref) {
  return PortTodo(
    ref.read(todoRepositoryProvider),
    ref.read(timeSegmentRepositoryProvider),
  );
});

final copyTodosProvider = Provider<CopyTodos>((ref) {
  return CopyTodos(ref.read(todoRepositoryProvider));
});

// --- Application state ---

final dailyTodoProvider = StateNotifierProvider.family<
    DailyTodoNotifier, DailyTodoState, String>((ref, date) {
  return DailyTodoNotifier(
    date: date,
    todoRepository: ref.read(todoRepositoryProvider),
    markTodoCompleted: ref.read(markTodoCompletedProvider),
    markTodoDropped: ref.read(markTodoDroppedProvider),
    portTodo: ref.read(portTodoProvider),
    copyTodos: ref.read(copyTodosProvider),
  );
});

final timeTrackingProvider = StateNotifierProvider.family<
    TimeTrackingNotifier, TimeTrackingState, String>((ref, todoId) {
  return TimeTrackingNotifier(
    ref.read(timeSegmentRepositoryProvider),
    todoId,
  );
});

final liveTimerProvider =
    StreamProvider.family<int, String>((ref, todoId) {
  final trackingState = ref.watch(timeTrackingProvider(todoId));
  final running = trackingState.runningSegment;
  if (running == null) return Stream.value(0);

  final startTime = DateTime.parse(running.startTime);
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(startTime).inSeconds;
  });
});

// --- Autocomplete & Search ---

final autocompleteProvider =
    FutureProvider.family<List<String>, String>((ref, prefix) {
  final repo = ref.read(todoRepositoryProvider);
  return repo.getAutocompleteSuggestions(prefix);
});

final searchResultsProvider =
    FutureProvider.family<List<TodoEntity>, String>((ref, query) {
  final repo = ref.read(todoRepositoryProvider);
  return repo.searchByTitle(query);
});
