import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

enum AppScaffoldDestination { daily, masteryDeck, statistics }

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
                              NavigationRailDestination(
                                icon: const Icon(Icons.today_outlined),
                                selectedIcon: const Icon(Icons.today),
                                label: Text(context.l10n.dailyList),
                              ),
                              const NavigationRailDestination(
                                icon: Icon(Icons.psychology_outlined),
                                selectedIcon: Icon(Icons.psychology),
                                label: Text('Mastery'),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.bar_chart_outlined),
                                selectedIcon: const Icon(Icons.bar_chart),
                                label: Text(context.l10n.statistics),
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).navigationBarTheme.backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: NavigationBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          selectedIndex: currentDestination.index,
                          onDestinationSelected: (index) => _onDestinationSelected(
                            context,
                            AppScaffoldDestination.values[index],
                          ),
                          destinations: [
                            NavigationDestination(
                              icon: const Icon(Icons.today_outlined),
                              selectedIcon: const Icon(Icons.today),
                              label: context.l10n.dailyList,
                            ),
                            const NavigationDestination(
                              icon: Icon(Icons.psychology_outlined),
                              selectedIcon: Icon(Icons.psychology),
                              label: 'Mastery',
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.bar_chart_outlined),
                              selectedIcon: const Icon(Icons.bar_chart),
                              label: context.l10n.statistics,
                            ),
                          ],
                        ),
                      ),
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
      case AppScaffoldDestination.masteryDeck:
        context.go(AppRoutes.masteryDeck);
      case AppScaffoldDestination.statistics:
        context.go(AppRoutes.statistics);
    }
  }
}
