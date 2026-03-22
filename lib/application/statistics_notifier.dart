import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/statistics_state.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  StatisticsNotifier(this._statisticsQueryService)
    : super(const StatisticsState()) {
    refresh();
  }

  final StatisticsQueryService _statisticsQueryService;

  _DailyCacheEntry? _dailyCache;
  _PerItemCacheEntry? _perItemCache;
  final Map<String, _HistoryCacheEntry> _historyCache = {};

  Future<void> refresh({bool force = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    await loadDailyStats(page: state.dailyCurrentPage, force: force);
    await loadPerItemStats(page: state.perItemCurrentPage, force: force);

    final selectedTitle = state.selectedTitle;
    if (selectedTitle != null && selectedTitle.isNotEmpty) {
      await selectTitle(selectedTitle, force: force);
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> loadDailyStats({int page = 0, bool force = false}) async {
    final filter = _currentDateFilter();
    final cacheKey = _dailyCacheKey(page, filter);
    final cached = _dailyCache;
    if (!force &&
        cached != null &&
        cached.key == cacheKey &&
        !cached.isExpired) {
      state = state.copyWith(
        dailyStats: cached.dailyStats,
        dailyCurrentPage: page,
        dailyTotalPages: cached.totalPages,
        summaryStats: cached.summaryStats,
        error: null,
      );
      return;
    }

    try {
      final offset = page * kStatisticsPageSize;
      final dailyStats = await _statisticsQueryService.getCountsPerDay(
        limit: kStatisticsPageSize,
        offset: offset,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
      final dayCount = await _statisticsQueryService.getDayCount(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
      final summaryStats = await _statisticsQueryService.getSummaryStats(
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
      final totalPages = dayCount == 0
          ? 0
          : (dayCount / kStatisticsPageSize).ceil();

      _dailyCache = _DailyCacheEntry(
        key: cacheKey,
        dailyStats: dailyStats,
        totalPages: totalPages,
        summaryStats: summaryStats,
      );

      state = state.copyWith(
        dailyStats: dailyStats,
        dailyCurrentPage: page,
        dailyTotalPages: totalPages,
        summaryStats: summaryStats,
        error: null,
      );
    } on Exception {
      state = state.copyWith(error: AppStrings.errors.generic);
    }
  }

  Future<void> loadPerItemStats({int page = 0, bool force = false}) async {
    final query = state.searchQuery.trim();
    final normalizedQuery = query.isEmpty ? null : nfcNormalize(query);
    final cacheKey = _perItemCacheKey(page, normalizedQuery);
    final cached = _perItemCache;
    if (!force &&
        cached != null &&
        cached.key == cacheKey &&
        !cached.isExpired) {
      state = state.copyWith(
        perItemStats: cached.stats,
        perItemCurrentPage: page,
        perItemTotalPages: cached.totalPages,
        error: null,
      );
      return;
    }

    try {
      final offset = page * kStatisticsPageSize;
      final perItemStats = await _statisticsQueryService.getPerItemStats(
        limit: kStatisticsPageSize,
        offset: offset,
        titleQuery: normalizedQuery,
      );
      final itemCount = await _statisticsQueryService.getPerItemCount(
        titleQuery: normalizedQuery,
      );
      final totalPages = itemCount == 0
          ? 0
          : (itemCount / kStatisticsPageSize).ceil();

      _perItemCache = _PerItemCacheEntry(
        key: cacheKey,
        stats: perItemStats,
        totalPages: totalPages,
      );

      final selectedTitle = state.selectedTitle;
      final shouldClearSelection =
          normalizedQuery != null &&
          normalizedQuery.isNotEmpty &&
          selectedTitle != null &&
          !selectedTitle.contains(normalizedQuery);

      state = state.copyWith(
        perItemStats: perItemStats,
        perItemCurrentPage: page,
        perItemTotalPages: totalPages,
        selectedTitle: shouldClearSelection ? null : selectedTitle,
        selectedTitleHistory: shouldClearSelection
            ? const []
            : state.selectedTitleHistory,
        error: null,
      );
    } on Exception {
      state = state.copyWith(error: AppStrings.errors.generic);
    }
  }

  Future<void> setDateRange(
    DateRange range, {
    DateTime? start,
    DateTime? end,
  }) async {
    var normalizedStart = start == null
        ? null
        : DateTime(start.year, start.month, start.day);
    var normalizedEnd = end == null
        ? null
        : DateTime(end.year, end.month, end.day);

    if (normalizedStart != null &&
        normalizedEnd != null &&
        normalizedEnd.isBefore(normalizedStart)) {
      final tmp = normalizedStart;
      normalizedStart = normalizedEnd;
      normalizedEnd = tmp;
    }

    state = state.copyWith(
      dateRange: range,
      customStartDate: normalizedStart,
      customEndDate: normalizedEnd,
      dailyCurrentPage: 0,
    );
    _dailyCache = null;
    await loadDailyStats(force: true);
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query, perItemCurrentPage: 0);
    _perItemCache = null;
    await loadPerItemStats(force: true);
  }

  Future<void> selectTitle(String title, {bool force = false}) async {
    final normalizedTitle = nfcNormalize(title.trim());
    if (normalizedTitle.isEmpty) {
      state = state.copyWith(selectedTitle: null, selectedTitleHistory: []);
      return;
    }

    final cached = _historyCache[normalizedTitle];
    if (!force && cached != null && !cached.isExpired) {
      state = state.copyWith(
        selectedTitle: normalizedTitle,
        selectedTitleHistory: cached.history,
        error: null,
      );
      return;
    }

    try {
      final history = await _statisticsQueryService.getTimeSeriesForTitle(
        normalizedTitle,
      );
      _historyCache[normalizedTitle] = _HistoryCacheEntry(history);
      state = state.copyWith(
        selectedTitle: normalizedTitle,
        selectedTitleHistory: history,
        error: null,
      );
    } on Exception {
      state = state.copyWith(error: AppStrings.errors.generic);
    }
  }

  Future<void> nextDailyPage() async {
    if (state.dailyCurrentPage + 1 >= state.dailyTotalPages) {
      return;
    }
    await loadDailyStats(page: state.dailyCurrentPage + 1);
  }

  Future<void> previousDailyPage() async {
    if (state.dailyCurrentPage == 0) {
      return;
    }
    await loadDailyStats(page: state.dailyCurrentPage - 1);
  }

  Future<void> nextPerItemPage() async {
    if (state.perItemCurrentPage + 1 >= state.perItemTotalPages) {
      return;
    }
    await loadPerItemStats(page: state.perItemCurrentPage + 1);
  }

  Future<void> previousPerItemPage() async {
    if (state.perItemCurrentPage == 0) {
      return;
    }
    await loadPerItemStats(page: state.perItemCurrentPage - 1);
  }

  _DateFilter _currentDateFilter() {
    switch (state.dateRange) {
      case DateRange.last7Days:
        final endDate = DateTime.now();
        final startDate = endDate.subtract(const Duration(days: 6));
        return _DateFilter(
          startDate: dateTimeToIso(startDate),
          endDate: dateTimeToIso(endDate),
        );
      case DateRange.last30Days:
        final endDate = DateTime.now();
        final startDate = endDate.subtract(const Duration(days: 29));
        return _DateFilter(
          startDate: dateTimeToIso(startDate),
          endDate: dateTimeToIso(endDate),
        );
      case DateRange.custom:
        return _DateFilter(
          startDate: state.customStartDate == null
              ? null
              : dateTimeToIso(state.customStartDate!),
          endDate: state.customEndDate == null
              ? null
              : dateTimeToIso(state.customEndDate!),
        );
      case DateRange.allTime:
        return const _DateFilter();
    }
  }

  String _dailyCacheKey(int page, _DateFilter filter) =>
      '${state.dateRange.name}|${filter.startDate ?? ''}|${filter.endDate ?? ''}|$page';

  String _perItemCacheKey(int page, String? query) => '${query ?? ''}|$page';
}

class _DateFilter {
  const _DateFilter({this.startDate, this.endDate});

  final String? startDate;
  final String? endDate;
}

class _DailyCacheEntry {
  _DailyCacheEntry({
    required this.key,
    required this.dailyStats,
    required this.totalPages,
    required this.summaryStats,
  }) : timestamp = DateTime.now();

  final String key;
  final List<DayStats> dailyStats;
  final int totalPages;
  final SummaryStats summaryStats;
  final DateTime timestamp;

  bool get isExpired =>
      DateTime.now().difference(timestamp).inSeconds >
      kStatisticsCacheDurationSeconds;
}

class _PerItemCacheEntry {
  _PerItemCacheEntry({
    required this.key,
    required this.stats,
    required this.totalPages,
  }) : timestamp = DateTime.now();

  final String key;
  final List<TodoTimeStats> stats;
  final int totalPages;
  final DateTime timestamp;

  bool get isExpired =>
      DateTime.now().difference(timestamp).inSeconds >
      kStatisticsCacheDurationSeconds;
}

class _HistoryCacheEntry {
  _HistoryCacheEntry(this.history) : timestamp = DateTime.now();

  final List<TitleTimePoint> history;
  final DateTime timestamp;

  bool get isExpired =>
      DateTime.now().difference(timestamp).inSeconds >
      kStatisticsCacheDurationSeconds;
}
