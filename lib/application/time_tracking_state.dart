import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';

part 'time_tracking_state.freezed.dart';

@freezed
class TimeTrackingState with _$TimeTrackingState {
  const factory TimeTrackingState({
    @Default([]) List<TimeSegmentEntity> segments,
    TimeSegmentEntity? runningSegment,
    @Default(0) int totalDurationSeconds,
    @Default(false) bool isLoading,
    String? error,
  }) = _TimeTrackingState;
}
