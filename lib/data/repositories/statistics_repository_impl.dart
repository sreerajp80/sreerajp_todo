import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/data/dao/statistics_query_service.dart';
import 'package:sreerajp_todo/domain/entities/statistics_models.dart';
import 'package:sreerajp_todo/domain/repositories/statistics_repository.dart';

/// [StatisticsRepository] backed by the SQL in [StatisticsQueryService].
class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl(this._queryService);

  final StatisticsQueryService _queryService;

  @override
  Future<List<DayStats>> getCountsPerDay({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
  }) => _queryService.getCountsPerDay(
    limit: limit,
    offset: offset,
    startDate: startDate,
    endDate: endDate,
  );

  @override
  Future<int> getDayCount({
    String? startDate,
    String? endDate,
    Set<int>? workingDays,
  }) => _queryService.getDayCount(
    startDate: startDate,
    endDate: endDate,
    workingDays: workingDays,
  );

  @override
  Future<List<TodoTimeStats>> getPerItemStats({
    int limit = kStatisticsPageSize,
    int offset = 0,
    String? startDate,
    String? endDate,
    String? titleQuery,
  }) => _queryService.getPerItemStats(
    limit: limit,
    offset: offset,
    startDate: startDate,
    endDate: endDate,
    titleQuery: titleQuery,
  );

  @override
  Future<int> getPerItemCount({
    String? startDate,
    String? endDate,
    String? titleQuery,
  }) => _queryService.getPerItemCount(
    startDate: startDate,
    endDate: endDate,
    titleQuery: titleQuery,
  );

  @override
  Future<List<TitleTimePoint>> getTimeSeriesForTitle(String title) =>
      _queryService.getTimeSeriesForTitle(title);

  @override
  Future<SummaryStats> getSummaryStats({
    String? startDate,
    String? endDate,
    Set<int>? workingDays,
  }) => _queryService.getSummaryStats(
    startDate: startDate,
    endDate: endDate,
    workingDays: workingDays,
  );
}
