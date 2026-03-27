import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

enum AppScaffoldDestination { daily, statistics, settings }

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.currentDestination,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final AppScaffoldDestination currentDestination;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kCompactLayoutBreakpointDp;
        return Scaffold(
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: isWide
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: NavigationRail(
                            selectedIndex: currentDestination.index,
                            labelType: NavigationRailLabelType.all,
                            onDestinationSelected: (index) =>
                                _onDestinationSelected(
                                  context,
                                  AppScaffoldDestination.values[index],
                                ),
                            destinations: [
                              const NavigationRailDestination(
                                icon: Icon(Icons.today_outlined),
                                selectedIcon: Icon(Icons.today),
                                label: Text(AppStrings.dailyList),
                              ),
                              const NavigationRailDestination(
                                icon: Icon(Icons.bar_chart_outlined),
                                selectedIcon: Icon(Icons.bar_chart),
                                label: Text(AppStrings.statistics),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.settings_outlined),
                                selectedIcon: const Icon(Icons.settings),
                                label: Text(AppStrings.settings.label),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: FocusTraversalGroup(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                20,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: kContentMaxWidthDp,
                                ),
                                child: body,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : FocusTraversalGroup(child: body),
          ),
          bottomNavigationBar: isWide
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: NavigationBar(
                      selectedIndex: currentDestination.index,
                      onDestinationSelected: (index) => _onDestinationSelected(
                        context,
                        AppScaffoldDestination.values[index],
                      ),
                      destinations: [
                        const NavigationDestination(
                          icon: Icon(Icons.today_outlined),
                          selectedIcon: Icon(Icons.today),
                          label: AppStrings.dailyList,
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.bar_chart_outlined),
                          selectedIcon: Icon(Icons.bar_chart),
                          label: AppStrings.statistics,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.settings_outlined),
                          selectedIcon: const Icon(Icons.settings),
                          label: AppStrings.settings.label,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _onDestinationSelected(
    BuildContext context,
    AppScaffoldDestination destination,
  ) {
    if (destination == currentDestination) {
      return;
    }

    switch (destination) {
      case AppScaffoldDestination.daily:
        context.go(AppRoutes.dailyListPath(todayAsIso()));
      case AppScaffoldDestination.statistics:
        context.go(AppRoutes.statistics);
      case AppScaffoldDestination.settings:
        context.go(AppRoutes.settings);
    }
  }
}
