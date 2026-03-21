import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/time_tracking_state.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';

class TimeTrackingNotifier extends StateNotifier<TimeTrackingState> {
  TimeTrackingNotifier(
    this._repository,
    this._startTimeSegment,
    this._todoId,
  ) : super(const TimeTrackingState()) {
    loadSegments();
  }

  final TimeSegmentRepository _repository;
  final StartTimeSegment _startTimeSegment;
  final String _todoId;

  Future<void> loadSegments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final segments = await _repository.getSegments(_todoId);
      final running = await _repository.getRunningSegment(_todoId);

      var totalSeconds = 0;
      for (final seg in segments) {
        if (seg.durationSeconds != null) {
          totalSeconds += seg.durationSeconds!;
        }
      }

      state = state.copyWith(
        segments: segments,
        runningSegment: running,
        totalDurationSeconds: totalSeconds,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> startTimer() async {
    try {
      await _startTimeSegment.call(_todoId);
      await loadSegments();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopTimer() async {
    try {
      await _repository.stopSegment(_todoId);
      await loadSegments();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addManualSegment(TimeSegmentEntity segment) async {
    try {
      await _repository.insertManualSegment(segment);
      await loadSegments();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
