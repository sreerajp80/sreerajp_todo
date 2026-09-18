import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/config/app_config.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/about/about_screen.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/made_with_love.dart';

import '../../../helpers/test_l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MadeWithLove widget renders heart icon and accessible semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: MadeWithLove()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MadeWithLove), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(
      find.bySemanticsLabel(testL10n.madeWithLoveA11y),
      findsOneWidget,
    );
  });

  testWidgets('AboutScreen renders app config details and MadeWithLove badge', (
    tester,
  ) async {
    const customConfig = AppConfig(
      appName: LocalizedText.plain('Custom App'),
      description: LocalizedText.plain('Custom Description'),
      version: '1.2.3',
      build: '99',
      details: {
        'author': LocalizedText.plain('Custom Author'),
        'license': LocalizedText.plain('Custom License'),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith((ref) async => customConfig),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: AboutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom App'), findsOneWidget);
    expect(find.text('Custom Description'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('99'), findsOneWidget);
    expect(find.text('Custom Author'), findsOneWidget);
    expect(find.text('Custom License'), findsOneWidget);
    expect(find.text(testL10n.aboutDetailAuthor), findsOneWidget);
    expect(find.text(testL10n.aboutDetailLicense), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(MadeWithLove), 100);
    expect(find.byType(MadeWithLove), findsOneWidget);
  });

  testWidgets('AboutScreen renders localized appName in Malayalam', (
    tester,
  ) async {
    const trilingualConfig = AppConfig(
      appName: LocalizedText.byLocale({
        'en': 'Todo EN',
        'ml': 'ശ്രീരാജ്പി ടുഡു',
        'sa': 'श्रीराज्-पी कार्यसूची',
      }),
      description: LocalizedText.byLocale({
        'en': 'Desc EN',
        'ml': 'വിവരണം ML',
        'sa': 'वर्णनम् SA',
      }),
      version: '1.0.0',
      build: '1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith((ref) async => trilingualConfig),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ml'),
          home: AboutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ശ്രീരാജ്പി ടുഡു'), findsOneWidget);
    expect(find.text('വിവരണം ML'), findsOneWidget);
  });
}
