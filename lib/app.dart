import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/presentation/screens/backup/backup_screen.dart';
import 'package:sreerajp_todo/presentation/screens/copy_todos/copy_todos_screen.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/create_edit_todo_screen.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/daily_list_screen.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/recurrence_editor_screen.dart';
import 'package:sreerajp_todo/presentation/screens/recurring_tasks/recurring_tasks_screen.dart';
import 'package:sreerajp_todo/presentation/screens/search_results/search_results_screen.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/statistics_screen.dart';
import 'package:sreerajp_todo/presentation/screens/time_segments/time_segments_screen.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

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
      builder: (context, state) {
        final date = state.pathParameters['date'] ?? todayAsIso();
        return DailyListScreen(date: date);
      },
    ),
    GoRoute(
      path: AppRoutes.createTodo,
      builder: (context, state) {
        final date = state.uri.queryParameters['date'];
        return CreateEditTodoScreen(date: date);
      },
    ),
    GoRoute(
      path: AppRoutes.editTodo,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CreateEditTodoScreen(todoId: id);
      },
      routes: [
        GoRoute(
          path: 'segments',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return TimeSegmentsScreen(todoId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.copyTodos,
      builder: (context, state) {
        final from = state.uri.queryParameters['from'];
        final preSelectedIds = state.extra as List<String>?;
        return CopyTodosScreen(
          fromDate: from,
          preSelectedIds: preSelectedIds,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) {
        final q = state.uri.queryParameters['q'];
        return SearchResultsScreen(query: q);
      },
    ),
    GoRoute(
      path: AppRoutes.backup,
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: AppRoutes.recurring,
      builder: (context, state) => const RecurringTasksScreen(),
    ),
    GoRoute(
      path: AppRoutes.recurringNew,
      builder: (context, state) => const RecurrenceEditorScreen(),
    ),
    GoRoute(
      path: AppRoutes.recurringEdit,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RecurrenceEditorScreen(ruleId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.statistics,
      builder: (context, state) => const StatisticsScreen(),
    ),
  ],
);

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
