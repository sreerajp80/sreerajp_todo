import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

enum AppScaffoldDestination { daily, statistics, recurring, backup }

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
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: currentDestination.index,
                      labelType: NavigationRailLabelType.all,
                      onDestinationSelected: (index) => _onDestinationSelected(
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
                        const NavigationRailDestination(
                          icon: Icon(Icons.repeat_outlined),
                          selectedIcon: Icon(Icons.repeat),
                          label: Text(AppStrings.recurringTasks),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.backup_outlined),
                          selectedIcon: const Icon(Icons.backup),
                          label: Text(AppStrings.backup.label),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: FocusTraversalGroup(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: kContentMaxWidthDp,
                            ),
                            child: body,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : FocusTraversalGroup(child: body),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
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
                    const NavigationDestination(
                      icon: Icon(Icons.repeat_outlined),
                      selectedIcon: Icon(Icons.repeat),
                      label: AppStrings.recurringTasks,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.backup_outlined),
                      selectedIcon: const Icon(Icons.backup),
                      label: AppStrings.backup.label,
                    ),
                  ],
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
      case AppScaffoldDestination.recurring:
        context.go(AppRoutes.recurring);
      case AppScaffoldDestination.backup:
        context.go(AppRoutes.backup);
    }
  }
}
