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
    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 360,
                      child: DailyBarChart(stats: state.dailyStats),
                    ),
                    const SizedBox(height: 16),
                    _SummaryCards(summaryStats: state.summaryStats),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 520,
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
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 360,
                child: DailyBarChart(stats: state.dailyStats),
              ),
              const SizedBox(height: 16),
              _SummaryCards(summaryStats: state.summaryStats),
              const SizedBox(height: 16),
              SizedBox(
                height: 420,
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
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
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

  final StatisticsState state;
  final StatisticsNotifier notifier;
  final TextEditingController searchController;
  final VoidCallback onSelectFromSearch;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.perItemStats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final hasData = state.perItemStats.isNotEmpty;
    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 360,
                  child: PerItemLineChart(
                    selectedTitle: state.selectedTitle,
                    history: state.selectedTitleHistory,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 520,
                  child: PerItemStatsTable(
                    stats: state.perItemStats,
                    currentPage: state.perItemCurrentPage,
                    totalPages: state.perItemTotalPages,
                    onPrevious: () => notifier.previousPerItemPage(),
                    onNext: () => notifier.nextPerItemPage(),
                    onSelectTitle: (title) => notifier.selectTitle(title),
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 360,
                child: PerItemLineChart(
                  selectedTitle: state.selectedTitle,
                  history: state.selectedTitleHistory,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 420,
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
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
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

  Text _buildRangeLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<DateRange>(
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
            ),
            if (state.dateRange == DateRange.custom) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onPickCustomDate(true),
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(
                      state.customStartDate == null
                          ? AppStrings.startDate
                          : DateFormat.yMMMd().format(state.customStartDate!),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => onPickCustomDate(false),
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      state.customEndDate == null
                          ? AppStrings.endDate
                          : DateFormat.yMMMd().format(state.customEndDate!),
                    ),
                  ),
                ],
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          label: AppStrings.stats.totalTodos,
          value: '${summaryStats.totalTodos}',
        ),
        _SummaryCard(
          label: AppStrings.stats.averageCompletedPerDay,
          value: summaryStats.avgCompletedPerDay.toStringAsFixed(1),
        ),
        _SummaryCard(
          label: AppStrings.stats.averageTimePerDay,
          value: formatDuration(summaryStats.avgTimePerDaySeconds),
        ),
        _SummaryCard(
          label: AppStrings.stats.productiveTime,
          value: formatDuration(summaryStats.totalProductiveTimeSeconds),
        ),
        _SummaryCard(
          label: AppStrings.stats.droppedTime,
          value: formatDuration(summaryStats.totalDroppedTimeSeconds),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
