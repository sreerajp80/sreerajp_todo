import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/domain/entities/statistics_models.dart';

/// Read-only statistics over tasks and time segments.
///
/// Dates are ISO `yyyy-MM-dd` strings. A `null` start or end date means the
/// range is open on that side.
abstract class StatisticsRepository {
  Future<List<DayStats>> getCountsPerDay({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
  });

  Future<int> getDayCount({
    String? startDate,
    String? endDate,
    Set<int>? workingDays,
  });

  Future<List<TodoTimeStats>> getPerItemStats({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
    String? titleQuery,
  });

  Future<int> getPerItemCount({
    String? startDate,
    String? endDate,
    String? titleQuery,
  });

  Future<List<TitleTimePoint>> getTimeSeriesForTitle(String title);

  Future<SummaryStats> getSummaryStats({
    String? startDate,
    String? endDate,
    Set<int>? workingDays,
  });
}
