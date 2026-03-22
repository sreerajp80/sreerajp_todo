import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/data/models/statistics_models.dart';

part 'statistics_state.freezed.dart';

enum DateRange { last7Days, last30Days, allTime, custom }

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    @Default([]) List<DayStats> dailyStats,
    @Default(0) int dailyCurrentPage,
    @Default(0) int dailyTotalPages,
    @Default(DateRange.last7Days) DateRange dateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    @Default(SummaryStats()) SummaryStats summaryStats,
    @Default([]) List<TodoTimeStats> perItemStats,
    @Default(0) int perItemCurrentPage,
    @Default(0) int perItemTotalPages,
    @Default('') String searchQuery,
    String? selectedTitle,
    @Default([]) List<TitleTimePoint> selectedTitleHistory,
    @Default(false) bool isLoading,
    String? error,
  }) = _StatisticsState;
}
