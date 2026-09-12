import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/todo_list_tile.dart';
import 'package:sreerajp_todo/presentation/screens/mastery_deck/mastery_deck_detail_screen.dart';
import 'package:sreerajp_todo/presentation/screens/mastery_deck/mastery_deck_screen.dart';

import '../helpers/test_fixtures.dart';
import '../helpers/test_l10n.dart';

class MockSpacedRepetitionRepository extends Mock
    implements SpacedRepetitionRepository {}

class MockTodoRepository extends Mock implements TodoRepository {}

class MockTimeSegmentRepository extends Mock implements TimeSegmentRepository {}

Widget buildTestApp({
  required Widget child,
  required SharedPreferences prefs,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  late MockSpacedRepetitionRepository mockSrsRepo;
  late MockTodoRepository mockTodoRepo;
  late MockTimeSegmentRepository mockTimeRepo;
  late SharedPreferences prefs;

  setUpAll(() {
    registerFallbackValue(
      const SpacedRepetitionItemEntity(
        id: 'fallback',
        title: 'fallback',
        nextReviewDate: '2026-09-12',
        createdAt: '2026-09-12',
        updatedAt: '2026-09-12',
      ),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockSrsRepo = MockSpacedRepetitionRepository();
    mockTodoRepo = MockTodoRepository();
    mockTimeRepo = MockTimeSegmentRepository();

    when(() => mockTimeRepo.getSegments(any())).thenAnswer((_) async => []);
    when(
      () => mockTimeRepo.getRunningSegment(any()),
    ).thenAnswer((_) async => null);
  });

  testWidgets('MasteryDeckScreen shows empty state when no decks exist', (
    tester,
  ) async {
    when(() => mockSrsRepo.getAllItems()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      buildTestApp(
        prefs: prefs,
        child: const MasteryDeckScreen(),
        overrides: [
          spacedRepetitionRepositoryProvider.overrideWithValue(mockSrsRepo),
          todoRepositoryProvider.overrideWithValue(mockTodoRepo),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(testL10n.noMasteryDecks), findsOneWidget);
    expect(find.text(testL10n.noMasteryDecksSubtitle), findsOneWidget);
    expect(find.text(testL10n.newMasteryDeck), findsWidgets);
  });

  testWidgets(
    'MasteryDeckScreen shows cards with title and progress when decks exist',
    (tester) async {
      const deck = SpacedRepetitionItemEntity(
        id: 'deck-1',
        title: 'Flutter Mastery',
        description: 'Deep dive into Flutter',
        nextReviewDate: '2026-09-12',
        createdAt: '2026-09-12',
        updatedAt: '2026-09-12',
      );

      final todo1 = buildTodo(
        id: 'todo-1',
        title: 'Riverpod setup',
        status: TodoStatus.completed,
      ).copyWith(spacedRepetitionItemId: 'deck-1');

      final todo2 = buildTodo(
        id: 'todo-2',
        title: 'Animations',
        status: TodoStatus.pending,
      ).copyWith(spacedRepetitionItemId: 'deck-1');

      when(() => mockSrsRepo.getAllItems()).thenAnswer((_) async => [deck]);
      when(
        () => mockTodoRepo.getTodosByMasteryDeckId('deck-1'),
      ).thenAnswer((_) async => [todo1, todo2]);

      await tester.pumpWidget(
        buildTestApp(
          prefs: prefs,
          child: const MasteryDeckScreen(),
          overrides: [
            spacedRepetitionRepositoryProvider.overrideWithValue(mockSrsRepo),
            todoRepositoryProvider.overrideWithValue(mockTodoRepo),
            timeSegmentRepositoryProvider.overrideWithValue(mockTimeRepo),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Flutter Mastery'), findsOneWidget);
      expect(find.text('Deep dive into Flutter'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text(testL10n.masteryTasksCount(1, 2)), findsOneWidget);
    },
  );

  testWidgets(
    'MasteryDeckDetailScreen renders deck header, stats and list of child todos',
    (tester) async {
      const deck = SpacedRepetitionItemEntity(
        id: 'deck-1',
        title: 'Flutter Mastery',
        description: 'Comprehensive study',
        nextReviewDate: '2026-09-12',
        createdAt: '2026-09-12',
        updatedAt: '2026-09-12',
      );

      final todo1 = buildTodo(
        id: 'todo-1',
        title: 'Learn Riverpod',
        status: TodoStatus.completed,
      ).copyWith(spacedRepetitionItemId: 'deck-1');

      final todo2 = buildTodo(
        id: 'todo-2',
        title: 'Master GoRouter',
        status: TodoStatus.working,
      ).copyWith(spacedRepetitionItemId: 'deck-1');

      when(
        () => mockSrsRepo.getItemById('deck-1'),
      ).thenAnswer((_) async => deck);
      when(
        () => mockTodoRepo.getTodosByMasteryDeckId('deck-1'),
      ).thenAnswer((_) async => [todo1, todo2]);

      await tester.pumpWidget(
        buildTestApp(
          prefs: prefs,
          child: const MasteryDeckDetailScreen(deckId: 'deck-1'),
          overrides: [
            spacedRepetitionRepositoryProvider.overrideWithValue(mockSrsRepo),
            todoRepositoryProvider.overrideWithValue(mockTodoRepo),
            timeSegmentRepositoryProvider.overrideWithValue(mockTimeRepo),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Flutter Mastery'), findsWidgets);
      expect(find.text('Comprehensive study'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Learn Riverpod'), findsOneWidget);
      expect(find.text('Master GoRouter'), findsOneWidget);
      expect(find.text(testL10n.addTodoToDeck), findsWidgets);
    },
  );

  testWidgets(
    'TodoListTile renders mastery tag chip when todo has spacedRepetitionItemId',
    (tester) async {
      const deck = SpacedRepetitionItemEntity(
        id: 'deck-1',
        title: 'Flutter Mastery',
        nextReviewDate: '2026-09-12',
        createdAt: '2026-09-12',
        updatedAt: '2026-09-12',
      );

      final todo = buildTodo(
        id: 'todo-1',
        title: 'Tagged task',
      ).copyWith(spacedRepetitionItemId: 'deck-1');

      when(() => mockSrsRepo.getAllItems()).thenAnswer((_) async => [deck]);

      await tester.pumpWidget(
        buildTestApp(
          prefs: prefs,
          child: Scaffold(
            body: TodoListTile(
              todo: todo,
              isPast: false,
              isSelected: false,
              isMultiSelectMode: false,
              onTap: () {},
              onLongPress: () {},
              onComplete: () {},
              onDrop: () {},
              onPort: () {},
              onCopy: () {},
              onEdit: () {},
              onDelete: () {},
              onMove: () {},
              onViewSegments: () {},
              animationIndex: 0,
            ),
          ),
          overrides: [
            spacedRepetitionRepositoryProvider.overrideWithValue(mockSrsRepo),
            todoRepositoryProvider.overrideWithValue(mockTodoRepo),
            timeSegmentRepositoryProvider.overrideWithValue(mockTimeRepo),
            allMasteryDecksMapProvider.overrideWithValue({
              'deck-1': 'Flutter Mastery',
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('#Flutter Mastery'), findsOneWidget);
    },
  );
}
