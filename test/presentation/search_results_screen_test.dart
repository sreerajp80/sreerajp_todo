import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/presentation/screens/search_results/search_results_screen.dart';

import '../helpers/test_fixtures.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository repository;

  setUp(() {
    repository = MockTodoRepository();
  });

  Future<void> pumpSearchScreen(
    WidgetTester tester, {
    required String query,
  }) async {
    final router = GoRouter(
      initialLocation: '${AppRoutes.search}?q=$query',
      routes: [
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) =>
              SearchResultsScreen(query: state.uri.queryParameters['q']),
        ),
        GoRoute(
          path: AppRoutes.dailyList,
          builder: (context, state) =>
              Scaffold(body: Text('day:${state.pathParameters['date']}')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('groups search results by date', (tester) async {
    when(
      () => repository.searchByTitle('focus', limit: any(named: 'limit')),
    ).thenAnswer(
      (_) async => [
        buildTodo(id: 'a', date: '2026-03-22', title: 'Morning focus'),
        buildTodo(id: 'b', date: '2026-03-22', title: 'Evening focus'),
        buildTodo(id: 'c', date: '2026-03-20', title: 'Older focus'),
      ],
    );

    await pumpSearchScreen(tester, query: 'focus');

    expect(find.text(formatDateFromIso('2026-03-22')), findsOneWidget);
    expect(find.text(formatDateFromIso('2026-03-20')), findsOneWidget);
    expect(find.text('Morning focus'), findsOneWidget);
    expect(find.text('Evening focus'), findsOneWidget);
    expect(find.text('Older focus'), findsOneWidget);
  });

  testWidgets('tapping a result navigates to the day route', (tester) async {
    when(
      () => repository.searchByTitle('focus', limit: any(named: 'limit')),
    ).thenAnswer(
      (_) async => [
        buildTodo(id: 'a', date: '2026-03-22', title: 'Morning focus'),
      ],
    );

    await pumpSearchScreen(tester, query: 'focus');

    await tester.tap(find.text('Morning focus'));
    await tester.pumpAndSettle();

    expect(find.text('day:2026-03-22'), findsOneWidget);
  });

  testWidgets('shows empty state when no results match', (tester) async {
    when(
      () => repository.searchByTitle('missing', limit: any(named: 'limit')),
    ).thenAnswer((_) async => const []);

    await pumpSearchScreen(tester, query: 'missing');

    expect(find.text(AppStrings.noSearchResults), findsOneWidget);
    expect(
      find.text(AppStrings.noSearchResultsForQuery('missing')),
      findsOneWidget,
    );
  });

  testWidgets('supports Unicode search queries', (tester) async {
    when(
      () => repository.searchByTitle('المهمة', limit: any(named: 'limit')),
    ).thenAnswer(
      (_) async => [
        buildTodo(id: 'arabic', title: 'المهمة العربية', description: 'وصف'),
      ],
    );

    await pumpSearchScreen(tester, query: 'المهمة');

    expect(find.text('المهمة العربية'), findsOneWidget);
    verify(
      () => repository.searchByTitle('المهمة', limit: any(named: 'limit')),
    ).called(1);
  });
}
