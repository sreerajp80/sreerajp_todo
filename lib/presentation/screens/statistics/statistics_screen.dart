import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/statistics_notifier.dart';
import 'package:sreerajp_todo/application/statistics_state.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/widgets/daily_bar_chart.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/widgets/daily_stats_table.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/widgets/per_item_line_chart.dart';
import 'package:sreerajp_todo/presentation/screens/statistics/widgets/per_item_stats_table.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/responsive_scaffold.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statisticsProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDate({
    required bool isStart,
    required StatisticsState state,
    required StatisticsNotifier notifier,
  }) async {
    final initialDate = isStart
        ? (state.customStartDate ?? DateTime.now())
        : (state.customEndDate ?? state.customStartDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isStart
          ? AppStrings.stats.selectStartDate
          : AppStrings.stats.selectEndDate,
    );
    if (picked == null) {
      return;
    }

    await notifier.setDateRange(
      DateRange.custom,
      start: isStart ? picked : state.customStartDate ?? picked,
      end: isStart ? state.customEndDate ?? picked : picked,
    );
  }

  Future<void> _selectMatchingTitle(
    StatisticsState state,
    StatisticsNotifier notifier,
  ) async {
    final query = nfcNormalize(_searchController.text.trim());
    if (query.isEmpty) {
      return;
    }

    TodoTimeStats? exactMatch;
    TodoTimeStats? partialMatch;
    for (final item in state.perItemStats) {
      if (item.title == query) {
        exactMatch = item;
        break;
      }
      if (partialMatch == null && item.title.contains(query)) {
        partialMatch = item;
      }
    }

    await notifier.selectTitle(
      exactMatch?.title ?? partialMatch?.title ?? query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final notifier = ref.read(statisticsProvider.notifier);
    final showFullError =
        state.error != null &&
        !state.isLoading &&
        state.dailyStats.isEmpty &&
        state.perItemStats.isEmpty;

    return DefaultTabController(
      length: 2,
      child: ResponsiveScaffold(
        currentDestination: AppScaffoldDestination.statistics,
        appBar: AppBar(
          title: const Text(AppStrings.statistics),
          actions: [
            IconButton(
              onPressed: () => notifier.refresh(force: true),
              tooltip: AppStrings.stats.refresh,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () => context.push(AppRoutes.settings),
              tooltip: AppStrings.settings.label,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: AppStrings.stats.dailyOverview),
              Tab(text: AppStrings.stats.perItemOverview),
            ],
          ),
        ),
        body: showFullError
            ? AppErrorState(
                message: AppStrings.errors.retryableGeneric,
                onRetry: () => notifier.refresh(force: true),
              )
            : Column(
                children: [
                  if (state.isLoading &&
                      (state.dailyStats.isNotEmpty ||
                          state.perItemStats.isNotEmpty))
                    const LinearProgressIndicator(),
                  if (state.error != null)
                    MaterialBanner(
                      content: Text(AppStrings.errors.retryableGeneric),
                      actions: [
                        TextButton(
                          onPressed: () => notifier.refresh(force: true),
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _DailyOverviewTab(
                          state: state,
                          notifier: notifier,
                          onPickCustomDate: (isStart) => _pickCustomDate(
                            isStart: isStart,
                            state: state,
                            notifier: notifier,
                          ),
                        ),
                        _PerItemOverviewTab(
                          state: state,
                          notifier: notifier,
                          searchController: _searchController,
                          onSelectFromSearch: () =>
                              _selectMatchingTitle(state, notifier),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DailyOverviewTab extends StatelessWidget {
  const _DailyOverviewTab({
    required this.state,
    required this.notifier,
    required this.onPickCustomDate,
  });

  static const double _sectionGap = 16;

  final StatisticsState state;
  final StatisticsNotifier notifier;
  final ValueChanged<bool> onPickCustomDate;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.dailyStats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final hasData = state.dailyStats.isNotEmpty;
    final chart = DailyBarChart(stats: state.dailyStats);

    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    chart,
                    const SizedBox(height: _sectionGap),
                    _SummaryCards(summaryStats: state.summaryStats),
                  ],
                ),
              ),
              const SizedBox(width: _sectionGap),
              Expanded(
                flex: 4,
                child: DailyStatsTable(
                  stats: state.dailyStats,
                  currentPage: state.dailyCurrentPage,
                  totalPages: state.dailyTotalPages,
                  onPrevious: () => notifier.previousDailyPage(),
                  onNext: () => notifier.nextDailyPage(),
                  onSelectDate: (date) =>
                      context.push(AppRoutes.dailyListPath(date)),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chart,
              const SizedBox(height: _sectionGap),
              _SummaryCards(summaryStats: state.summaryStats),
              const SizedBox(height: _sectionGap),
              DailyStatsTable(
                stats: state.dailyStats,
                currentPage: state.dailyCurrentPage,
                totalPages: state.dailyTotalPages,
                onPrevious: () => notifier.previousDailyPage(),
                onNext: () => notifier.nextDailyPage(),
                onSelectDate: (date) =>
                    context.push(AppRoutes.dailyListPath(date)),
              ),
            ],
          );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateRangeFilter(
            state: state,
            onRangeSelected: (range) async {
              if (range == DateRange.custom) {
                final start = state.customStartDate ?? DateTime.now();
                final end = state.customEndDate ?? DateTime.now();
                await notifier.setDateRange(
                  DateRange.custom,
                  start: start,
                  end: end,
                );
                return;
              }
              await notifier.setDateRange(range);
            },
            onPickCustomDate: onPickCustomDate,
          ),
          const SizedBox(height: _sectionGap),
          if (!hasData)
            const AppEmptyState(
              icon: Icons.bar_chart_outlined,
              title: AppStrings.statistics,
              message: AppStrings.noStatisticsData,
            )
          else
            content,
        ],
      ),
    );
  }
}

class _PerItemOverviewTab extends StatelessWidget {
  const _PerItemOverviewTab({
    required this.state,
    required this.notifier,
    required this.searchController,
    required this.onSelectFromSearch,
  });

  static const double _sectionGap = 16;

  final StatisticsState state;
  final StatisticsNotifier notifier;
  final TextEditingController searchController;
  final VoidCallback onSelectFromSearch;

  TodoTimeStats? _findSelectedStat() {
    final selectedTitle = state.selectedTitle;
    if (selectedTitle == null || selectedTitle.isEmpty) {
      return null;
    }

    for (final stat in state.perItemStats) {
      if (stat.title == selectedTitle) {
        return stat;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.perItemStats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final hasData = state.perItemStats.isNotEmpty;
    final selectedStat = _findSelectedStat();
    final showChartPanel =
        hasData || (state.selectedTitle?.isNotEmpty ?? false);
    final chart = PerItemLineChart(
      selectedTitle: state.selectedTitle,
      history: state.selectedTitleHistory,
      selectedStat: selectedStat,
    );

    final content = isWide
        ? (showChartPanel
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [chart],
                      ),
                    ),
                    const SizedBox(width: _sectionGap),
                    Expanded(
                      flex: 4,
                      child: PerItemStatsTable(
                        stats: state.perItemStats,
                        currentPage: state.perItemCurrentPage,
                        totalPages: state.perItemTotalPages,
                        onPrevious: () => notifier.previousPerItemPage(),
                        onNext: () => notifier.nextPerItemPage(),
                        onSelectTitle: (title) => notifier.selectTitle(title),
                      ),
                    ),
                  ],
                )
              : PerItemStatsTable(
                  stats: state.perItemStats,
                  currentPage: state.perItemCurrentPage,
                  totalPages: state.perItemTotalPages,
                  onPrevious: () => notifier.previousPerItemPage(),
                  onNext: () => notifier.nextPerItemPage(),
                  onSelectTitle: (title) => notifier.selectTitle(title),
                ))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PerItemSelectorCard(
                stats: state.perItemStats,
                selectedTitle: state.selectedTitle,
                currentPage: state.perItemCurrentPage,
                totalPages: state.perItemTotalPages,
                onPrevious: () => notifier.previousPerItemPage(),
                onNext: () => notifier.nextPerItemPage(),
                onSelectTitle: (title) => notifier.selectTitle(title),
              ),
              if (showChartPanel) ...[
                const SizedBox(height: _sectionGap),
                chart,
              ],
            ],
          );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdaptiveDirectionality(
            text: searchController.text,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: AppStrings.stats.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        tooltip: AppStrings.clearSearch,
                        onPressed: () {
                          searchController.clear();
                          notifier.setSearchQuery('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    IconButton(
                      tooltip: AppStrings.stats.showHistory,
                      onPressed: onSelectFromSearch,
                      icon: const Icon(Icons.insights_outlined),
                    ),
                  ],
                ),
              ),
              onChanged: (value) => notifier.setSearchQuery(value),
              onSubmitted: (_) => onSelectFromSearch(),
            ),
          ),
          const SizedBox(height: _sectionGap),
          if (!hasData && searchController.text.isEmpty)
            const AppEmptyState(
              icon: Icons.insights_outlined,
              title: AppStrings.statistics,
              message: AppStrings.noStatisticsData,
            )
          else
            content,
        ],
      ),
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({
    required this.state,
    required this.onRangeSelected,
    required this.onPickCustomDate,
  });

  final StatisticsState state;
  final ValueChanged<DateRange> onRangeSelected;
  final ValueChanged<bool> onPickCustomDate;

  static const double _compactRangeSelectorBreakpoint = 360;

  Text _buildRangeLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompactRangeSelector() {
    final ranges = [
      (DateRange.last7Days, AppStrings.stats.last7Days),
      (DateRange.last30Days, AppStrings.stats.last30Days),
      (DateRange.allTime, AppStrings.stats.allTime),
      (DateRange.custom, AppStrings.stats.customRange),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ranges.map((entry) {
        final (range, label) = entry;
        return ChoiceChip(
          label: Text(label),
          selected: state.dateRange == range,
          onSelected: (selected) {
            if (selected) {
              onRangeSelected(range);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildCustomDateSelector(
    BuildContext context, {
    required bool isStartDate,
    required bool isCompact,
    required DateTime? selectedDate,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final headline = selectedDate == null
        ? (isStartDate ? AppStrings.startDate : AppStrings.endDate)
        : (isCompact
              ? DateFormat.MMMd().format(selectedDate)
              : DateFormat.yMMMd().format(selectedDate));
    final subtitle = selectedDate != null && isCompact
        ? DateFormat.y().format(selectedDate)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onPickCustomDate(isStartDate),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 14,
            vertical: isCompact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isStartDate ? Icons.date_range_outlined : Icons.event_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: subtitle == null
                    ? Text(
                        headline,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colorScheme.primary),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < _compactRangeSelectorBreakpoint) {
                  return _buildCompactRangeSelector();
                }

                return SegmentedButton<DateRange>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: DateRange.last7Days,
                      label: _buildRangeLabel(AppStrings.stats.last7Days),
                    ),
                    ButtonSegment(
                      value: DateRange.last30Days,
                      label: _buildRangeLabel(AppStrings.stats.last30Days),
                    ),
                    ButtonSegment(
                      value: DateRange.allTime,
                      label: _buildRangeLabel(AppStrings.stats.allTime),
                    ),
                    ButtonSegment(
                      value: DateRange.custom,
                      label: _buildRangeLabel(AppStrings.stats.customRange),
                    ),
                  ],
                  selected: {state.dateRange},
                  onSelectionChanged: (selection) =>
                      onRangeSelected(selection.first),
                );
              },
            ),
            if (state.dateRange == DateRange.custom) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact =
                      constraints.maxWidth < _compactRangeSelectorBreakpoint;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildCustomDateSelector(
                          context,
                          isStartDate: true,
                          isCompact: isCompact,
                          selectedDate: state.customStartDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCustomDateSelector(
                          context,
                          isStartDate: false,
                          isCompact: isCompact,
                          selectedDate: state.customEndDate,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summaryStats});

  final SummaryStats summaryStats;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        AppStrings.stats.totalTodos,
        '${summaryStats.totalTodos}',
        Icons.checklist_rounded,
      ),
      (
        AppStrings.stats.averageCompletedPerDay,
        summaryStats.avgCompletedPerDay.toStringAsFixed(1),
        Icons.task_alt_rounded,
      ),
      (
        AppStrings.stats.averageTimePerDay,
        formatDuration(summaryStats.avgTimePerDaySeconds),
        Icons.schedule_rounded,
      ),
      (
        AppStrings.stats.productiveTime,
        formatDuration(summaryStats.totalProductiveTimeSeconds),
        Icons.trending_up_rounded,
      ),
      (
        AppStrings.stats.droppedTime,
        formatDuration(summaryStats.totalDroppedTimeSeconds),
        Icons.remove_circle_outline_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 960
            ? 5
            : maxWidth >= 720
            ? 3
            : 2;
        final itemWidth = (maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(
                width: itemWidth,
                child: _SummaryCard(
                  label: card.$1,
                  value: card.$2,
                  icon: card.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
