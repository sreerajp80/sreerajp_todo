import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/features/features_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FeaturesScreen renders categories and feature highlights', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FeaturesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Features'), findsOneWidget);
    expect(find.text('SreerajP ToDo Features'), findsOneWidget);
    expect(find.text('DAILY TASKS & WORKFLOW'), findsOneWidget);
    expect(find.text('TIME TRACKING & FOCUS'), findsOneWidget);
    expect(find.text('MASTERY DECK & SPACED REPETITION'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('PRIVACY, SECURITY & STORAGE'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('PRIVACY, SECURITY & STORAGE'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('CUSTOMIZATION & ANALYTICS'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('CUSTOMIZATION & ANALYTICS'), findsOneWidget);

    // Verify presence of specific key features
    expect(
      find.text('Unicode First & Multi-Script Normalization'),
      findsOneWidget,
    );
    expect(find.text('Day Lock Safeguard'), findsOneWidget);
  });
}
