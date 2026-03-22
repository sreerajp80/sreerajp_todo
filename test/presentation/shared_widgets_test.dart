import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';

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
        home: ResponsiveScaffold(
          currentDestination: AppScaffoldDestination.daily,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(title: const Text(AppStrings.dailyList)),
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
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox_outlined,
            title: AppStrings.noTasksTodayTitle,
            message: AppStrings.noTasksTodayMessage,
            actionLabel: AppStrings.addFirstTask,
            onAction: () {},
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.noTasksTodayTitle), findsOneWidget);
    expect(find.text(AppStrings.noTasksTodayMessage), findsOneWidget);
    expect(find.text(AppStrings.addFirstTask), findsOneWidget);
  });
}
