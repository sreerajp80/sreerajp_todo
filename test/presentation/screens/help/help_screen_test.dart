import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/help_home_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/task_management_help_screen.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HelpHomeScreen renders topic cards and navigates to subtopics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.help,
      routes: [
        GoRoute(
          path: AppRoutes.help,
          builder: (context, state) => const HelpHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.helpTaskManagement,
          builder: (context, state) => const TaskManagementHelpScreen(),
        ),
        GoRoute(
          path: AppRoutes.helpFaq,
          builder: (context, state) => const FaqTroubleshootingHelpScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Help & User Guides'), findsOneWidget);
    expect(find.text('Help Center & Knowledge Base'), findsOneWidget);
    expect(find.byType(HelpTopicCard), findsNWidgets(10));

    // Tap on Daily Lists & Day Lock topic card
    await tester.tap(find.text('Daily Lists & Day Lock'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskManagementHelpScreen), findsOneWidget);
    expect(find.text('The Day Lock Principle'), findsOneWidget);
  });
}
