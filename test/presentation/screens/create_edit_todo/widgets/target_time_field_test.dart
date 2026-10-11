import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/target_time_field.dart';

void main() {
  Widget buildTestWidget({
    required int? targetSeconds,
    required ValueChanged<int?> onChanged,
    ValueChanged<bool>? onValidChanged,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TargetTimeField(
          targetSeconds: targetSeconds,
          onChanged: onChanged,
          onValidChanged: onValidChanged,
        ),
      ),
    );
  }

  testWidgets('renders visible Hours and Minutes labels in English', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        targetSeconds: 3600 + 1800, // 1 hour 30 min
        onChanged: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hours'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(
      find.text(
        'Estimated duration to complete this task. Leave both at zero for no target.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders visible Malayalam labels and duration hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        targetSeconds: null,
        onChanged: (_) {},
        locale: const Locale('ml'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('മണിക്കൂർ'), findsOneWidget);
    expect(find.text('മിനിറ്റ്'), findsOneWidget);
    expect(
      find.text(
        'ടാസ്ക് പൂർത്തിയാക്കാൻ ഉദ്ദേശിക്കുന്ന ദൈർഘ്യം. ലക്ഷ്യം വേണ്ടെങ്കിൽ രണ്ടും പൂജ്യമായി വെക്കുക.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('typing numbers emits joined target seconds', (tester) async {
    int? changedValue;
    await tester.pumpWidget(
      buildTestWidget(
        targetSeconds: null,
        onChanged: (val) => changedValue = val,
      ),
    );
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.first, '2');
    await tester.pumpAndSettle();

    expect(changedValue, 7200); // 2 hours
  });

  testWidgets('enforces maximum two digits on hours and minutes', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(targetSeconds: null, onChanged: (_) {}),
    );
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    final hoursField = textFields.first;
    final minutesField = textFields.last;

    // Attempt to enter 3 or more digits into hours
    await tester.enterText(hoursField, '123');
    await tester.pumpAndSettle();
    // Only the first 2 digits are accepted
    final hoursController = tester.widget<TextField>(hoursField).controller!;
    expect(hoursController.text.length, lessThanOrEqualTo(2));

    // Attempt to enter 3 or more digits into minutes
    await tester.enterText(minutesField, '456');
    await tester.pumpAndSettle();
    final minutesController = tester
        .widget<TextField>(minutesField)
        .controller!;
    expect(minutesController.text.length, lessThanOrEqualTo(2));
  });

  testWidgets(
    'validates while typing and shows error on out-of-range minutes',
    (tester) async {
      int? changedValue;
      bool? isValid;

      await tester.pumpWidget(
        buildTestWidget(
          targetSeconds: null,
          onChanged: (val) => changedValue = val,
          onValidChanged: (val) => isValid = val,
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      final minutesField = textFields.last;

      // Type 60 into minutes -> exceeds 59
      await tester.enterText(minutesField, '60');
      await tester.pumpAndSettle();

      expect(find.text('0–59'), findsOneWidget);
      expect(isValid, isFalse);
      expect(changedValue, isNull);

      // Correct back to 45 -> valid
      await tester.enterText(minutesField, '45');
      await tester.pumpAndSettle();

      expect(find.text('0–59'), findsNothing);
      expect(isValid, isTrue);
      expect(changedValue, 45 * 60);
    },
  );

  testWidgets('validates while typing and shows error on out-of-range hours', (
    tester,
  ) async {
    int? changedValue;
    bool? isValid;

    await tester.pumpWidget(
      buildTestWidget(
        targetSeconds: null,
        onChanged: (val) => changedValue = val,
        onValidChanged: (val) => isValid = val,
      ),
    );
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    final hoursField = textFields.first;

    // Type 24 into hours -> exceeds 23
    await tester.enterText(hoursField, '24');
    await tester.pumpAndSettle();

    expect(find.text('0–23'), findsOneWidget);
    expect(isValid, isFalse);
    expect(changedValue, isNull);

    // Correct to 23 -> valid
    await tester.enterText(hoursField, '23');
    await tester.pumpAndSettle();

    expect(find.text('0–23'), findsNothing);
    expect(isValid, isTrue);
    expect(changedValue, 23 * 3600);
  });
}
