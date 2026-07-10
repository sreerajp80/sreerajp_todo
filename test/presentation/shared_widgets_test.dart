import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';

import '../helpers/test_l10n.dart';

void main() {
  Future<void> pumpResponsiveScaffold(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResponsiveScaffold(
          currentDestination: AppScaffoldDestination.daily,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(title: Text(testL10n.dailyList)),
          ),
          body: const SizedBox.expand(child: Placeholder()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mobile layout renders the bottom navigation shell', (
    tester,
  ) async {
    await pumpResponsiveScaffold(tester, size: const Size(390, 844));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('desktop layout renders the navigation rail shell', (
    tester,
  ) async {
    await pumpResponsiveScaffold(tester, size: const Size(1280, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('empty state widget renders its content and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox_outlined,
            title: testL10n.noTasksTodayTitle,
            message: testL10n.noTasksTodayMessage,
            actionLabel: testL10n.addFirstTask,
            onAction: () {},
          ),
        ),
      ),
    );

    expect(find.text(testL10n.noTasksTodayTitle), findsOneWidget);
    expect(find.text(testL10n.noTasksTodayMessage), findsOneWidget);
    expect(find.text(testL10n.addFirstTask), findsOneWidget);
  });
}
