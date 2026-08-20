import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/daily_todo_notifier.dart';
import 'package:sreerajp_todo/application/focus_pulse_notifier.dart';
import 'package:sreerajp_todo/application/daily_todo_state.dart';
import 'package:sreerajp_todo/application/recurrence_rules_notifier.dart';
import 'package:sreerajp_todo/application/statistics_notifier.dart';
import 'package:sreerajp_todo/application/statistics_state.dart';
import 'package:sreerajp_todo/application/pomodoro_notifier.dart';
import 'package:sreerajp_todo/application/time_tracking_notifier.dart';
import 'package:sreerajp_todo/application/date_time_settings_notifier.dart';
import 'package:sreerajp_todo/application/task_defaults_notifier.dart';
import 'package:sreerajp_todo/application/time_tracking_settings_notifier.dart';
import 'package:sreerajp_todo/application/time_tracking_state.dart';
import 'package:sreerajp_todo/application/timer_paused_store.dart';
import 'package:sreerajp_todo/application/voice_capture_notifier.dart';
import 'package:sreerajp_todo/application/voice_capture_state.dart';
import 'package:sreerajp_todo/application/security_settings_notifier.dart';
import 'package:sreerajp_todo/application/app_lock_notifier.dart';
import 'package:sreerajp_todo/core/platform/screen_wake_channel.dart';
import 'package:sreerajp_todo/core/platform/speech_channel.dart';
import 'package:sreerajp_todo/data/backup/backup_service.dart';
import 'package:sreerajp_todo/data/dao/daily_reflection_dao.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';
import 'package:sreerajp_todo/data/models/daily_reflection_entity.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
import 'package:sreerajp_todo/data/repositories/daily_reflection_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/recurrence_rule_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/time_segment_repository_impl.dart';
import 'package:sreerajp_todo/data/repositories/todo_repository_impl.dart';
import 'package:sreerajp_todo/domain/repositories/daily_reflection_repository.dart';
import 'package:sreerajp_todo/domain/repositories/recurrence_rule_repository.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/copy_todos.dart';
import 'package:sreerajp_todo/domain/usecases/delete_recurring_todos.dart';
import 'package:sreerajp_todo/domain/usecases/generate_recurring_tasks.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_completed.dart';
import 'package:sreerajp_todo/domain/usecases/mark_todo_dropped.dart';
import 'package:sreerajp_todo/domain/usecases/port_todo.dart';
import 'package:sreerajp_todo/domain/usecases/repair_orphaned_segments.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';
import 'package:sreerajp_todo/data/dao/spaced_repetition_dao.dart';
import 'package:sreerajp_todo/data/repositories/spaced_repetition_repository_impl.dart';
import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';
import 'package:sreerajp_todo/domain/usecases/complete_srs_todo.dart';
import 'package:sreerajp_todo/domain/usecases/generate_spaced_repetition_tasks.dart';
import 'package:sreerajp_todo/data/services/p2p_wifi_sync_service.dart';
import 'package:sreerajp_todo/data/services/data_handoff_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/appearance_notifier.dart';
import 'package:sreerajp_todo/application/locale_notifier.dart';
import 'package:sreerajp_todo/core/config/app_config.dart';
import 'package:sreerajp_todo/core/config/config_service.dart';

import 'package:sreerajp_todo/data/database/database_key_service.dart';

import 'package:sreerajp_todo/data/dao/backup_logs_dao.dart';
import 'package:sreerajp_todo/data/models/backup_log_entity.dart';

final databaseKeyServiceProvider = Provider<DatabaseKeyService>((ref) {
  return DatabaseKeyService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(
    databaseKeyService: ref.read(databaseKeyServiceProvider),
  );
});

final backupLogsDaoProvider = Provider<BackupLogsDao>((ref) {
  return BackupLogsDao(ref.read(databaseServiceProvider));
});

final backupHealthLogsProvider = FutureProvider<List<BackupLogEntity>>((
  ref,
) async {
  final dao = ref.watch(backupLogsDaoProvider);
  return dao.getAllLogs(limit: 50);
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.read(databaseServiceProvider),
    backupLogsDao: ref.read(backupLogsDaoProvider),
  );
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

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(ref.read(todoDaoProvider));
});

final recurrenceRuleRepositoryProvider = Provider<RecurrenceRuleRepository>((
  ref,
) {
  return RecurrenceRuleRepositoryImpl(ref.read(recurrenceRuleDaoProvider));
});

final timeSegmentRepositoryProvider = Provider<TimeSegmentRepository>((ref) {
  return TimeSegmentRepositoryImpl(
    ref.read(timeSegmentDaoProvider),
    ref.read(todoDaoProvider),
    ref.read(databaseServiceProvider),
  );
});

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

final startTimeSegmentProvider = Provider<StartTimeSegment>((ref) {
  return StartTimeSegment(
    ref.read(todoRepositoryProvider),
    ref.read(timeSegmentRepositoryProvider),
    // Read at call time, not build time, so changing the setting takes effect
    // on the very next start without rebuilding the use case.
    singleTimer: () => ref.read(timeTrackingSettingsProvider).singleTimer,
  );
});

final repairOrphanedSegmentsProvider = Provider<RepairOrphanedSegments>((ref) {
  return RepairOrphanedSegments(
    ref.read(timeSegmentRepositoryProvider),
    autoStopMode: () => ref.read(timeTrackingSettingsProvider).autoStopMode,
    autoStopHour: () => ref.read(timeTrackingSettingsProvider).autoStopHour,
    autoStopMinute: () => ref.read(timeTrackingSettingsProvider).autoStopMinute,
  );
});

final generateRecurringTasksProvider = Provider<GenerateRecurringTasks>((ref) {
  return GenerateRecurringTasks(
    ref.read(recurrenceRuleRepositoryProvider),
    ref.read(todoRepositoryProvider),
  );
});

final deleteRecurringTodosProvider = Provider<DeleteRecurringTodos>((ref) {
  return DeleteRecurringTodos(
    ref.read(todoRepositoryProvider),
    ref.read(recurrenceRuleRepositoryProvider),
  );
});

final p2pWifiSyncServiceProvider = Provider<P2pWifiSyncService>((ref) {
  return P2pWifiSyncService(
    ref.read(todoDaoProvider),
    ref.read(timeSegmentDaoProvider),
    ref.read(recurrenceRuleDaoProvider),
    ref.read(spacedRepetitionDaoProvider),
  );
});

final spacedRepetitionDaoProvider = Provider<SpacedRepetitionDao>((ref) {
  return SpacedRepetitionDao(ref.read(databaseServiceProvider));
});

final spacedRepetitionRepositoryProvider = Provider<SpacedRepetitionRepository>(
  (ref) {
    return SpacedRepetitionRepositoryImpl(
      ref.read(spacedRepetitionDaoProvider),
    );
  },
);

final generateSpacedRepetitionTasksProvider =
    Provider<GenerateSpacedRepetitionTasks>((ref) {
      return GenerateSpacedRepetitionTasks(
        ref.read(spacedRepetitionRepositoryProvider),
        ref.read(todoRepositoryProvider),
      );
    });

final completeSrsTodoProvider = Provider<CompleteSrsTodo>((ref) {
  return CompleteSrsTodo(
    ref.read(todoRepositoryProvider),
    ref.read(timeSegmentRepositoryProvider),
    ref.read(spacedRepetitionRepositoryProvider),
  );
});

final dailyTodoProvider =
    StateNotifierProvider.family<DailyTodoNotifier, DailyTodoState, String>((
      ref,
      date,
    ) {
      return DailyTodoNotifier(
        date: date,
        todoRepository: ref.read(todoRepositoryProvider),
        markTodoCompleted: ref.read(markTodoCompletedProvider),
        markTodoDropped: ref.read(markTodoDroppedProvider),
        portTodoUseCase: ref.read(portTodoProvider),
        copyTodosUseCase: ref.read(copyTodosProvider),
        deleteRecurringTodos: ref.read(deleteRecurringTodosProvider),
        onDataChanged: () => ref.invalidate(statisticsProvider),
        onTimerStopped: (id) {
          ref.invalidate(timeTrackingProvider(id));
          // A finished task must never keep showing a Resume button.
          ref.read(pausedTodosProvider.notifier).clearPaused(id);
          ref.read(timerActivityTickProvider.notifier).state++;
        },
      );
    });

final timeTrackingProvider =
    StateNotifierProvider.family<
      TimeTrackingNotifier,
      TimeTrackingState,
      String
    >((ref, todoId) {
      return TimeTrackingNotifier(
        ref.read(timeSegmentRepositoryProvider),
        ref.read(startTimeSegmentProvider),
        todoId,
        minimumSegmentLength: () =>
            ref.read(timeTrackingSettingsProvider).minimumSegmentLength,
        pausedTodos: ref.read(pausedTodosProvider.notifier),
      );
    });

/// Time-tracking preferences: auto-stop, pause, rounding, Pomodoro and more.
final timeTrackingSettingsProvider =
    StateNotifierProvider<TimeTrackingSettingsNotifier, TimeTrackingSettings>((
      ref,
    ) {
      return TimeTrackingSettingsNotifier(ref.watch(sharedPreferencesProvider));
    });

/// Date and time preferences: week start, clock, date format, day start hour
/// and working days.
final dateTimeSettingsProvider =
    StateNotifierProvider<DateTimeSettingsNotifier, DateTimeSettings>((ref) {
      return DateTimeSettingsNotifier(ref.watch(sharedPreferencesProvider));
    });

/// Task defaults: new-task status, priority, target time, day list sort and
/// filters, confirmations, carry-over and autocomplete.
final taskDefaultsProvider =
    StateNotifierProvider<TaskDefaultsNotifier, TaskDefaults>((ref) {
      return TaskDefaultsNotifier(ref.watch(sharedPreferencesProvider));
    });

final timerPausedStoreProvider = Provider<TimerPausedStore>((ref) {
  return TimerPausedStore(ref.watch(sharedPreferencesProvider));
});

/// The ids of todos whose timer is paused rather than stopped.
final pausedTodosProvider =
    StateNotifierProvider<PausedTodosNotifier, Set<String>>((ref) {
      return PausedTodosNotifier(ref.watch(timerPausedStoreProvider));
    });

/// Bumped every time a timer starts, stops or pauses.
///
/// The lifecycle watcher listens to this to decide whether the screen still
/// needs to be kept on, without polling the database.
final timerActivityTickProvider = StateProvider<int>((ref) => 0);

final screenWakeChannelProvider = Provider<ScreenWakeChannel>((ref) {
  return ScreenWakeChannel();
});

/// The on-device speech recogniser channel used by the voice task sheet.
///
/// Android only. Everywhere else every call is a safe no-op and the sheet
/// offers its text box instead.
final speechChannelProvider = Provider<SpeechChannel>((ref) {
  return SpeechChannel();
});

/// Drives the voice task sheet while it is open.
///
/// Auto-disposed, so closing the sheet cancels the recogniser subscription and
/// releases the microphone. Nothing here writes to the database: the sheet
/// hands its reading to the normal create screen, which already enforces
/// Day-Lock, title uniqueness and NFC normalisation.
final voiceCaptureProvider =
    StateNotifierProvider.autoDispose<VoiceCaptureNotifier, VoiceCaptureState>((
      ref,
    ) {
      return VoiceCaptureNotifier(channel: ref.watch(speechChannelProvider));
    });

/// The Pomodoro cycle. One per app, because only one focus block runs at a
/// time whatever the "one timer" setting says.
final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) {
    TimeTrackingSettings settings() => ref.read(timeTrackingSettingsProvider);
    return PomodoroNotifier(
      workMinutes: () => settings().pomodoroWorkMinutes,
      shortBreakMinutes: () => settings().pomodoroShortBreakMinutes,
      longBreakMinutes: () => settings().pomodoroLongBreakMinutes,
      blocksBeforeLongBreak: () => settings().pomodoroBlocksBeforeLongBreak,
      autoStartNext: () => settings().pomodoroAutoStartNext,
      onWorkBlockEnded: (todoId) async {
        await ref.read(timeTrackingProvider(todoId).notifier).stopTimer();
      },
      onWorkBlockStarted: (todoId) async {
        final tracking = ref.read(timeTrackingProvider(todoId));
        if (tracking.runningSegment != null) return;
        await ref.read(timeTrackingProvider(todoId).notifier).startTimer();
      },
    );
  },
);

/// Seconds left in the current Pomodoro block, ticking once a second.
final pomodoroCountdownProvider = StreamProvider<int>((ref) {
  final pomodoro = ref.watch(pomodoroProvider);
  if (!pomodoro.isRunning) return Stream.value(0);

  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => pomodoro.secondsLeft(DateTime.now()),
  ).distinct();
});

/// The focus pulse: the gentle nudge given every so often while a timer runs.
///
/// One per app. `TimerLifecycleWatcher` tells it which timer to follow; it
/// never reads the database itself. It stays quiet while Pomodoro is on,
/// because Pomodoro already sounds its own alert at the end of every block.
final focusPulseProvider =
    StateNotifierProvider<FocusPulseNotifier, FocusPulseState>((ref) {
      TimeTrackingSettings settings() => ref.read(timeTrackingSettingsProvider);
      return FocusPulseNotifier(
        mode: () => settings().focusPulseMode,
        interval: () => Duration(minutes: settings().focusPulseIntervalMinutes),
        suppressed: () => settings().pomodoroEnabled,
      );
    });

/// Seconds until the next focus pulse, ticking once a second.
final focusPulseCountdownProvider = StreamProvider<int>((ref) {
  final pulse = ref.watch(focusPulseProvider);
  if (!pulse.isArmed) return Stream.value(0);

  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => pulse.secondsToNextPulse(DateTime.now()),
  ).distinct();
});

/// One todo by its id. Used by the Time Segments and Focus screens, which are
/// both opened by id rather than by day.
final todoByIdProvider = FutureProvider.family<TodoEntity?, String>((
  ref,
  todoId,
) {
  return ref.read(todoRepositoryProvider).getTodoById(todoId);
});

final liveTimerProvider = StreamProvider.family<int, String>((ref, todoId) {
  final trackingState = ref.watch(timeTrackingProvider(todoId));
  final running = trackingState.runningSegment;
  if (running == null) {
    return Stream.value(0);
  }

  final startTime = DateTime.parse(running.startTime);
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(startTime).inSeconds;
  });
});

/// Title suggestions for [prefix].
///
/// The limit is watched rather than read, so changing the suggestion count in
/// Settings refreshes the list without a restart. A limit of zero means
/// autocomplete is switched off, and no query is run at all.
final autocompleteProvider = FutureProvider.family<List<String>, String>((
  ref,
  prefix,
) {
  final limit = ref.watch(taskDefaultsProvider).autocompleteLimit;
  if (limit <= 0) return Future.value(const <String>[]);

  final repo = ref.read(todoRepositoryProvider);
  return repo.getAutocompleteSuggestions(prefix, limit: limit);
});

final searchResultsProvider =
    FutureProvider.family<List<TodoSearchResult>, String>((ref, query) {
      final repo = ref.read(todoRepositoryProvider);
      return repo.searchWithMatchedNotes(query);
    });

final pendingPrerequisitesProvider =
    FutureProvider.family<List<TodoEntity>, String>((ref, todoId) {
      final repo = ref.watch(todoRepositoryProvider);
      return repo.getPendingPrerequisites(todoId);
    });

final recurrenceRulesProvider =
    StateNotifierProvider<
      RecurrenceRulesNotifier,
      AsyncValue<List<RecurrenceRuleEntity>>
    >((ref) {
      return RecurrenceRulesNotifier(
        ref.read(recurrenceRuleRepositoryProvider),
      );
    });

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
      return StatisticsNotifier(
        ref.read(statisticsQueryServiceProvider),
        workingDays: () => ref.read(dateTimeSettingsProvider).workingDays,
      );
    });

/// Appearance preferences (theme mode, font, text size, accent colours).
final appearanceProvider =
    StateNotifierProvider<AppearanceNotifier, AppearanceState>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AppearanceNotifier(prefs);
    });

/// Convenience view of the saved theme mode from [appearanceProvider].
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appearanceProvider).themeMode;
});

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  final service = ref.watch(configServiceProvider);
  return service.load();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope / main',
  );
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

final dailyReflectionDaoProvider = Provider<DailyReflectionDao>((ref) {
  return DailyReflectionDao(ref.read(databaseServiceProvider));
});

final dailyReflectionRepositoryProvider = Provider<DailyReflectionRepository>((
  ref,
) {
  return DailyReflectionRepositoryImpl(ref.read(dailyReflectionDaoProvider));
});

final dailyIntentionProvider =
    FutureProvider.family<DailyIntentionEntity?, String>((ref, date) {
      final repo = ref.watch(dailyReflectionRepositoryProvider);
      return repo.getIntentionForDate(date);
    });

final dailyReflectionProvider =
    FutureProvider.family<DailyReflectionEntity?, String>((ref, date) {
      final repo = ref.watch(dailyReflectionRepositoryProvider);
      return repo.getReflectionForDate(date);
    });

final dataHandoffServiceProvider = Provider<DataHandoffService>((ref) {
  return DataHandoffService();
});

final securitySettingsProvider =
    StateNotifierProvider<SecuritySettingsNotifier, SecuritySettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SecuritySettingsNotifier(prefs);
    });

final appLockProvider = StateNotifierProvider<AppLockNotifier, AppLockState>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final settingsNotifier = ref.watch(securitySettingsProvider.notifier);
  return AppLockNotifier(settings: settingsNotifier, prefs: prefs);
});
