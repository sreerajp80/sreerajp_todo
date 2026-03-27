import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/presentation/screens/about/about_screen.dart';
import 'package:sreerajp_todo/presentation/screens/backup/backup_screen.dart';
import 'package:sreerajp_todo/presentation/screens/copy_todos/copy_todos_screen.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/create_edit_todo_screen.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/daily_list_screen.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/recurrence_editor_screen.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/recurring_tasks_screen.dart';
import 'package:sreerajp_todo/presentation/screens/search_results/search_results_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/permissions_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/settings_screen.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/statistics_screen.dart';
import 'package:sreerajp_todo/presentation/screens/time_segments/time_segments_screen.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

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

final _router = GoRouter(
  initialLocation: AppRoutes.root,
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
        final date = state.uri.queryParameters['date'];
        return _buildPage(state, CreateEditTodoScreen(date: date));
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
      ],
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
      path: AppRoutes.about,
      pageBuilder: (context, state) => _buildPage(state, const AboutScreen()),
    ),
    GoRoute(
      path: AppRoutes.permissions,
      pageBuilder: (context, state) =>
          _buildPage(state, const PermissionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.recurring,
      pageBuilder: (context, state) =>
          _buildPage(state, const RecurringTasksScreen()),
    ),
    GoRoute(
      path: AppRoutes.recurringNew,
      pageBuilder: (context, state) =>
          _buildPage(state, const RecurrenceEditorScreen()),
    ),
    GoRoute(
      path: AppRoutes.recurringEdit,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPage(state, RecurrenceEditorScreen(ruleId: id));
      },
    ),
    GoRoute(
      path: AppRoutes.statistics,
      pageBuilder: (context, state) =>
          _buildPage(state, const StatisticsScreen()),
    ),
  ],
);

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
