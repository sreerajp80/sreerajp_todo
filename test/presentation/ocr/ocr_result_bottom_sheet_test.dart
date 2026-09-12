import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/domain/entities/ocr_task_result.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

Widget _buildSheetTestApp({
  required OcrTaskResult result,
  required String date,
  bool returnResultDirectly = false,
  required void Function(String title, String description) onOpenEditor,
  required VoidCallback onRetake,
  TodoRepository? repo,
}) {
  final mockRepo = repo ?? MockTodoRepository();
  if (repo == null) {
    when(
      () => mockRepo.titleExistsOnDate(
        any(),
        any(),
        excludeId: any(named: 'excludeId'),
      ),
    ).thenAnswer((_) async => false);
  }

  return ProviderScope(
    overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: OcrResultBottomSheet(
          result: result,
          date: date,
          returnResultDirectly: returnResultDirectly,
          onOpenEditor: onOpenEditor,
          onRetake: onRetake,
        ),
      ),
    ),
  );
}

void main() {
  const testDate = '2026-09-11';
  const sampleResult = OcrTaskResult(
    title: 'Buy Groceries',
    description: 'Milk, Eggs, Bread',
    rawText: 'Buy Groceries\n---\nMilk, Eggs, Bread',
    hasSeparator: true,
    separatorType: OcrSeparatorType.dashed,
  );

  testWidgets('renders parsed title, description, and raw text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSheetTestApp(
        result: sampleResult,
        date: testDate,
        onOpenEditor: (_, _) {},
        onRetake: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buy Groceries'), findsOneWidget);
    expect(find.text('Milk, Eggs, Bread'), findsOneWidget);
    expect(find.text('Scanned Task Review'), findsOneWidget);
  });

  testWidgets('swaps title and description when swap button is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSheetTestApp(
        result: sampleResult,
        date: testDate,
        onOpenEditor: (_, _) {},
        onRetake: () {},
      ),
    );
    await tester.pumpAndSettle();

    final swapButton = find.text('Swap Title and Description');
    expect(swapButton, findsOneWidget);
    await tester.tap(swapButton);
    await tester.pumpAndSettle();

    // After swapping, the title should be 'Milk, Eggs, Bread' and description 'Buy Groceries'
    final titleField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Milk, Eggs, Bread'),
    );
    expect(titleField.controller?.text, 'Milk, Eggs, Bread');
  });

  testWidgets('triggers onOpenEditor when Continue to Task Details is tapped', (
    tester,
  ) async {
    String? openedTitle;
    String? openedDesc;

    await tester.pumpWidget(
      _buildSheetTestApp(
        result: sampleResult,
        date: testDate,
        onOpenEditor: (title, description) {
          openedTitle = title;
          openedDesc = description;
        },
        onRetake: () {},
      ),
    );
    await tester.pumpAndSettle();

    final continueButton = find.text('Continue to Task Details');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(openedTitle, 'Buy Groceries');
    expect(openedDesc, 'Milk, Eggs, Bread');
  });

  testWidgets('triggers onRetake when Retake is tapped', (tester) async {
    bool retakeCalled = false;

    await tester.pumpWidget(
      _buildSheetTestApp(
        result: sampleResult,
        date: testDate,
        onOpenEditor: (_, _) {},
        onRetake: () {
          retakeCalled = true;
        },
      ),
    );
    await tester.pumpAndSettle();

    final retakeButton = find.text('Retake');
    expect(retakeButton, findsOneWidget);
    await tester.tap(retakeButton);
    await tester.pumpAndSettle();

    expect(retakeCalled, isTrue);
  });

  testWidgets(
    'shows validation error when title is empty and Continue is tapped',
    (tester) async {
      await tester.pumpWidget(
        _buildSheetTestApp(
          result: const OcrTaskResult.empty(),
          date: testDate,
          onOpenEditor: (_, _) {},
          onRetake: () {},
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.text('Continue to Task Details');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Task name cannot be empty'), findsOneWidget);
    },
  );
}
