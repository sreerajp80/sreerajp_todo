import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/about/about_screen.dart';
import 'package:sreerajp_todo/presentation/screens/backup/backup_screen.dart';
import 'package:sreerajp_todo/presentation/screens/copy_todos/copy_todos_screen.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/create_edit_todo_screen.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/daily_list_screen.dart';
import 'package:sreerajp_todo/presentation/screens/focus/focus_screen.dart';
import 'package:sreerajp_todo/presentation/screens/search_results/search_results_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/accent_color_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/appearance_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/date_time_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/date_time/clock_format_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/date_time/date_format_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/date_time/day_start_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/date_time/week_start_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/date_time/working_days_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/language_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/permissions_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/settings_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/theme_mode_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/time_tracking/auto_stop_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/time_tracking/focus_mode_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/time_tracking/pomodoro_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/time_tracking/time_display_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/time_tracking/timer_behaviour_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/task_defaults_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/task_defaults/defaults_autocomplete_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/task_defaults/defaults_day_list_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/task_defaults/defaults_new_task_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/task_defaults/defaults_task_actions_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/time_tracking_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/typography_screen.dart';
import 'package:sreerajp_todo/presentation/screens/features/features_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/backup_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/focus_pomodoro_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/help_home_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/mastery_deck_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/privacy_security_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/qr_handoff_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/recurring_tasks_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/task_management_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/time_tracking_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/wifi_sync_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/mastery_deck/mastery_deck_screen.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/ritual_deck_screen.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/ritual_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/ritual/ritual_settings_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/pending_alerts_screen.dart';
import 'package:sreerajp_todo/presentation/screens/air_qr_scan_screen.dart';
import 'package:sreerajp_todo/presentation/screens/p2p_wifi_sync/p2p_wifi_sync_screen.dart';
import 'package:sreerajp_todo/presentation/screens/data_handoff/data_handoff_screen.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/statistics_screen.dart';
import 'package:sreerajp_todo/presentation/screens/task_history/task_history_screen.dart';
import 'package:sreerajp_todo/presentation/screens/time_segments/time_segments_screen.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/timer_lifecycle_watcher.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/pending_alert_watcher.dart';

CustomTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Builds the router.
///
/// [initialLocation] is what lets `main.dart` open Ritual mode as the very
/// first screen of the day. Everything else always starts at the day list.
GoRouter _createRouter(String initialLocation) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation,
  redirect: (context, state) {
    if (state.matchedLocation == '/') {
      return AppRoutes.dailyListPath(todayAsIso());
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.dailyList,
      pageBuilder: (context, state) {
        final date = state.pathParameters['date'] ?? todayAsIso();
        return _buildPage(state, DailyListScreen(date: date));
      },
    ),
    GoRoute(
      path: AppRoutes.createTodo,
      pageBuilder: (context, state) {
        // Everything past `date` is only ever sent by the voice task sheet,
        // which hands its reading over as a filled-in draft. The create screen
        // still validates it exactly as if it had been typed by hand.
        final query = state.uri.queryParameters;
        return _buildPage(
          state,
          CreateEditTodoScreen(
            date: query['date'],
            initialTitle: query['title'],
            initialDescription: query['description'],
            initialTargetSeconds: int.tryParse(query['target'] ?? ''),
            initialPriority: query['priority'],
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editTodo,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPage(state, CreateEditTodoScreen(todoId: id));
      },
      routes: [
        GoRoute(
          path: 'segments',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _buildPage(state, TimeSegmentsScreen(todoId: id));
          },
        ),
        GoRoute(
          path: 'history',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _buildPage(state, TaskHistoryScreen(todoId: id));
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.focus,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPage(state, FocusScreen(todoId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.copyTodos,
      pageBuilder: (context, state) {
        final from = state.uri.queryParameters['from'];
        final preSelectedIds = state.extra as List<String>?;
        return _buildPage(
          state,
          CopyTodosScreen(fromDate: from, preSelectedIds: preSelectedIds),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return _buildPage(state, SearchResultsScreen(query: query));
      },
    ),
    GoRoute(
      path: AppRoutes.backup,
      pageBuilder: (context, state) => _buildPage(state, const BackupScreen()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) =>
          _buildPage(state, const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.appearance,
      pageBuilder: (context, state) =>
          _buildPage(state, const AppearanceScreen()),
    ),
    GoRoute(
      path: AppRoutes.themeMode,
      pageBuilder: (context, state) =>
          _buildPage(state, const ThemeModeScreen()),
    ),
    GoRoute(
      path: AppRoutes.typography,
      pageBuilder: (context, state) =>
          _buildPage(state, const TypographyScreen()),
    ),
    GoRoute(
      path: AppRoutes.accentColor,
      pageBuilder: (context, state) =>
          _buildPage(state, const AccentColorScreen()),
    ),
    GoRoute(
      path: AppRoutes.timeTracking,
      pageBuilder: (context, state) =>
          _buildPage(state, const TimeTrackingScreen()),
    ),
    GoRoute(
      path: AppRoutes.autoStop,
      pageBuilder: (context, state) =>
          _buildPage(state, const AutoStopScreen()),
    ),
    GoRoute(
      path: AppRoutes.timerBehaviour,
      pageBuilder: (context, state) =>
          _buildPage(state, const TimerBehaviourScreen()),
    ),
    GoRoute(
      path: AppRoutes.pomodoro,
      pageBuilder: (context, state) =>
          _buildPage(state, const PomodoroScreen()),
    ),
    GoRoute(
      path: AppRoutes.focusMode,
      pageBuilder: (context, state) =>
          _buildPage(state, const FocusModeScreen()),
    ),
    GoRoute(
      path: AppRoutes.timeDisplay,
      pageBuilder: (context, state) =>
          _buildPage(state, const TimeDisplayScreen()),
    ),
    GoRoute(
      path: AppRoutes.taskDefaults,
      pageBuilder: (context, state) =>
          _buildPage(state, const TaskDefaultsScreen()),
    ),
    GoRoute(
      path: AppRoutes.defaultsNewTask,
      pageBuilder: (context, state) =>
          _buildPage(state, const DefaultsNewTaskScreen()),
    ),
    GoRoute(
      path: AppRoutes.defaultsDayList,
      pageBuilder: (context, state) =>
          _buildPage(state, const DefaultsDayListScreen()),
    ),
    GoRoute(
      path: AppRoutes.defaultsTaskActions,
      pageBuilder: (context, state) =>
          _buildPage(state, const DefaultsTaskActionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.defaultsAutocomplete,
      pageBuilder: (context, state) =>
          _buildPage(state, const DefaultsAutocompleteScreen()),
    ),
    GoRoute(
      path: AppRoutes.dateTime,
      pageBuilder: (context, state) =>
          _buildPage(state, const DateTimeScreen()),
    ),
    GoRoute(
      path: AppRoutes.weekStart,
      pageBuilder: (context, state) =>
          _buildPage(state, const WeekStartScreen()),
    ),
    GoRoute(
      path: AppRoutes.clockFormat,
      pageBuilder: (context, state) =>
          _buildPage(state, const ClockFormatScreen()),
    ),
    GoRoute(
      path: AppRoutes.dateFormat,
      pageBuilder: (context, state) =>
          _buildPage(state, const DateFormatScreen()),
    ),
    GoRoute(
      path: AppRoutes.dayStart,
      pageBuilder: (context, state) =>
          _buildPage(state, const DayStartScreen()),
    ),
    GoRoute(
      path: AppRoutes.workingDays,
      pageBuilder: (context, state) =>
          _buildPage(state, const WorkingDaysScreen()),
    ),
    GoRoute(
      path: AppRoutes.language,
      pageBuilder: (context, state) =>
          _buildPage(state, const LanguageScreen()),
    ),
    GoRoute(
      path: AppRoutes.about,
      pageBuilder: (context, state) => _buildPage(state, const AboutScreen()),
    ),
    GoRoute(
      path: AppRoutes.permissions,
      pageBuilder: (context, state) =>
          _buildPage(state, const PermissionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.statistics,
      pageBuilder: (context, state) =>
          _buildPage(state, const StatisticsScreen()),
    ),
    GoRoute(
      path: AppRoutes.masteryDeck,
      pageBuilder: (context, state) =>
          _buildPage(state, const MasteryDeckScreen()),
    ),
    GoRoute(
      path: AppRoutes.ritual,
      pageBuilder: (context, state) => _buildPage(state, const RitualScreen()),
    ),
    GoRoute(
      path: AppRoutes.ritualDeck,
      pageBuilder: (context, state) =>
          _buildPage(state, const RitualDeckScreen()),
    ),
    GoRoute(
      path: AppRoutes.ritualSettings,
      pageBuilder: (context, state) =>
          _buildPage(state, const RitualSettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.pendingAlerts,
      pageBuilder: (context, state) =>
          _buildPage(state, const PendingAlertsScreen()),
    ),
    GoRoute(
      path: AppRoutes.airQrScan,
      pageBuilder: (context, state) =>
          _buildPage(state, const AirQrScanScreen()),
    ),
    GoRoute(
      path: AppRoutes.wifiSync,
      pageBuilder: (context, state) =>
          _buildPage(state, const P2pWifiSyncScreen()),
    ),
    GoRoute(
      path: AppRoutes.dataHandoff,
      pageBuilder: (context, state) =>
          _buildPage(state, const DataHandoffScreen()),
    ),
    GoRoute(
      path: AppRoutes.features,
      pageBuilder: (context, state) =>
          _buildPage(state, const FeaturesScreen()),
    ),
    GoRoute(
      path: AppRoutes.help,
      pageBuilder: (context, state) =>
          _buildPage(state, const HelpHomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpTaskManagement,
      pageBuilder: (context, state) =>
          _buildPage(state, const TaskManagementHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpTimeTracking,
      pageBuilder: (context, state) =>
          _buildPage(state, const TimeTrackingHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpFocus,
      pageBuilder: (context, state) =>
          _buildPage(state, const FocusPomodoroHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpMasteryDeck,
      pageBuilder: (context, state) =>
          _buildPage(state, const MasteryDeckHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpRecurringTasks,
      pageBuilder: (context, state) =>
          _buildPage(state, const RecurringTasksHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpWifiSync,
      pageBuilder: (context, state) =>
          _buildPage(state, const WifiSyncHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpQrHandoff,
      pageBuilder: (context, state) =>
          _buildPage(state, const QrHandoffHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpPrivacySecurity,
      pageBuilder: (context, state) =>
          _buildPage(state, const PrivacySecurityHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpBackup,
      pageBuilder: (context, state) =>
          _buildPage(state, const BackupHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpFaq,
      pageBuilder: (context, state) =>
          _buildPage(state, const FaqTroubleshootingHelpScreen()),
    ),
  ],
);

class TodoApp extends ConsumerStatefulWidget {
  const TodoApp({super.key, this.initialLocation = AppRoutes.root});

  /// The first screen of the session. `main.dart` passes the ritual route when
  /// Ritual mode is on and today's ritual has not run yet.
  final String initialLocation;

  @override
  ConsumerState<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends ConsumerState<TodoApp> {
  // Built once and kept, so a rebuild for a theme or language change never
  // throws the user back to the first screen.
  late final GoRouter _router = _createRouter(widget.initialLocation);

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvider);
    final locale = ref.watch(localeProvider);
    final fontFamily = appearance.font.family;

    return MaterialApp.router(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        accent: appearance.lightAccent,
        fontFamily: fontFamily,
      ),
      darkTheme: AppTheme.dark(
        accent: appearance.darkAccent,
        fontFamily: fontFamily,
      ),
      themeMode: appearance.themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Combine the device text scale with the user's chosen app text size,
        // then keep the result inside a readable range.
        final systemFactor = media.textScaler.scale(14) / 14;
        final combined = (systemFactor * appearance.textScale.scale).clamp(
          0.8,
          1.8,
        );
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(combined)),
          // Owns auto-stop, auto-pause on background, and keep-screen-awake.
          child: TimerLifecycleWatcher(
            child: PendingAlertWatcher(
              navigatorKey: rootNavigatorKey,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
