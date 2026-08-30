import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/features/features_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/help_home_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/appearance_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/language_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/settings_screen.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';

import '../helpers/test_l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSettings(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: AppRoutes.settings,
      routes: [
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.appearance,
          builder: (context, state) => const AppearanceScreen(),
        ),
        GoRoute(
          path: AppRoutes.features,
          builder: (context, state) => const FeaturesScreen(),
        ),
        GoRoute(
          path: AppRoutes.help,
          builder: (context, state) => const HelpHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) => const LanguageScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows one card for each settings section', (tester) async {
    // A tall window so all cards are built at once.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpSettings(tester);

    expect(find.byType(SettingsNavCard), findsNWidgets(12));
    expect(find.text(testL10n.settingsAppearance), findsOneWidget);
    expect(find.text(testL10n.settingsFeatures), findsOneWidget);
    expect(find.text(testL10n.settingsHelp), findsOneWidget);
    expect(find.text(testL10n.settingsLanguage), findsOneWidget);
    expect(find.text(testL10n.settingsTaskDefaults), findsOneWidget);
    expect(find.text(testL10n.pendingAlertsTitle), findsOneWidget);
    expect(find.text(testL10n.settingsRitual), findsOneWidget);
    expect(find.text(testL10n.settingsTimeTracking), findsOneWidget);
    expect(find.text(testL10n.settingsDateTime), findsOneWidget);
    expect(find.text(testL10n.backupLabel), findsOneWidget);
    expect(find.text(testL10n.settingsPermissions), findsOneWidget);
    expect(find.text(testL10n.settingsAboutApp), findsOneWidget);

    // The offline notice sits below the cards.
    await tester.scrollUntilVisible(
      find.text(testL10n.settingsOfflineTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(testL10n.settingsOfflineTitle), findsOneWidget);
  });

  testWidgets('Appearance card opens the appearance pages', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(testL10n.settingsAppearance));
    await tester.pumpAndSettle();

    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(find.byType(SettingsNavCard), findsNWidgets(3));
    expect(find.text(testL10n.settingsThemeMode), findsOneWidget);
    expect(find.text(testL10n.appearanceTypography), findsOneWidget);
    expect(find.text(testL10n.appearanceAccentColor), findsOneWidget);
  });

  testWidgets('Features card opens the features screen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(testL10n.settingsFeatures));
    await tester.pumpAndSettle();

    expect(find.byType(FeaturesScreen), findsOneWidget);
    expect(find.text('SreerajP ToDo Features'), findsOneWidget);
  });

  testWidgets('Help card opens the help home screen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(testL10n.settingsHelp));
    await tester.pumpAndSettle();

    expect(find.byType(HelpHomeScreen), findsOneWidget);
    expect(find.text('Help Center & Knowledge Base'), findsOneWidget);
  });

  testWidgets('Language card opens the language page', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(testL10n.settingsLanguage));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsOneWidget);
    expect(find.text(testL10n.settingsLanguageSystem), findsOneWidget);
    expect(find.text(testL10n.settingsLanguageEnglish), findsOneWidget);
    expect(find.text(testL10n.settingsLanguageMalayalam), findsOneWidget);
  });
}
