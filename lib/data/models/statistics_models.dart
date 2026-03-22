import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_models.freezed.dart';

@freezed
class DayStats with _$DayStats {
  const factory DayStats({
    required String date,
    required int total,
    required int completed,
    required int dropped,
    required int ported,
    required int pending,
    @Default(0) int totalSeconds,
  }) = _DayStats;
}

@freezed
class TodoTimeStats with _$TodoTimeStats {
  const factory TodoTimeStats({
    required String title,
    @Default(0) int appearances,
    @Default(0) int completed,
    @Default(0) int dropped,
    @Default(0) int ported,
    @Default(0) int pending,
    @Default(0) int totalSeconds,
  }) = _TodoTimeStats;
}

@freezed
class TitleTimePoint with _$TitleTimePoint {
  const factory TitleTimePoint({
    required String title,
    required String date,
    @Default(0) int totalSeconds,
    String? status,
  }) = _TitleTimePoint;
}

@freezed
class SummaryStats with _$SummaryStats {
  const factory SummaryStats({
    @Default(0) int totalTodos,
    @Default(0) double avgCompletedPerDay,
    @Default(0) int avgTimePerDaySeconds,
    @Default(0) int totalProductiveTimeSeconds,
    @Default(0) int totalDroppedTimeSeconds,
  }) = _SummaryStats;
}
