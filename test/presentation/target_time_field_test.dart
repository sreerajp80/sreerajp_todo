import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/create_edit_todo/widgets/target_time_field.dart';

void main() {
  Widget buildTestWidget({
    required int? targetSeconds,
    required ValueChanged<int?> onChanged,
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
        ),
      ),
    );
  }

  testWidgets('renders visible Hours and Minutes labels in English',
      (tester) async {
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

  testWidgets('renders visible Malayalam labels and duration hint',
      (tester) async {
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
}
