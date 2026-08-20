import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/time_tracking_state.dart';
import 'package:sreerajp_todo/application/timer_paused_store.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/usecases/start_time_segment.dart';

/// What happened when the user started a timer.
class StartTimerResult {
  const StartTimerResult({this.stoppedTodoIds = const [], this.error});

  /// Todos whose timer was stopped because "only one timer at a time" is on.
  final List<String> stoppedTodoIds;

  /// Set when the start was refused. The timer did not start.
  final String? error;

  /// True when another timer had to be stopped to make room for this one.
  bool get tookOver => stoppedTodoIds.isNotEmpty;
}

/// What happened when the user stopped or paused a timer.
class StopTimerResult {
  const StopTimerResult({this.discardedSegment, this.error});

  /// Set when the segment was shorter than the minimum length and was dropped
  /// instead of saved. Hold on to it to offer an undo.
  final TimeSegmentEntity? discardedSegment;

  /// Set when the stop failed.
  final String? error;

  /// True when a too-short segment was thrown away.
  bool get wasDiscarded => discardedSegment != null;
}

class TimeTrackingNotifier extends StateNotifier<TimeTrackingState> {
  TimeTrackingNotifier(
    this._repository,
    this._startTimeSegment,
    this._todoId, {
    MinimumSegmentLength Function()? minimumSegmentLength,
    PausedTodosNotifier? pausedTodos,
  }) : _minimumSegmentLength = minimumSegmentLength ?? _noMinimum,
       // A named parameter cannot be a private initialising formal, so the
       // field is assigned here instead.
       // ignore: prefer_initializing_formals
       _pausedTodos = pausedTodos,
       super(const TimeTrackingState()) {
    loadSegments();
  }

  final TimeSegmentRepository _repository;
  final StartTimeSegment _startTimeSegment;
  final String _todoId;

  /// Read fresh on every stop so a settings change takes effect at once.
  final MinimumSegmentLength Function() _minimumSegmentLength;

  /// Null in tests that do not care about the paused mark.
  final PausedTodosNotifier? _pausedTodos;

  static MinimumSegmentLength _noMinimum() => MinimumSegmentLength.off;

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

  /// Starts the timer. Also used by Resume, which clears the paused mark.
  Future<StartTimerResult> startTimer() async {
    try {
      final stopped = await _startTimeSegment.call(_todoId);
      await _pausedTodos?.clearPaused(_todoId);
      await loadSegments();
      return StartTimerResult(stoppedTodoIds: stopped);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return StartTimerResult(error: e.toString());
    }
  }

  /// Stops the timer for good and clears any paused mark.
  Future<StopTimerResult> stopTimer() async {
    final result = await _closeTimer();
    await _pausedTodos?.clearPaused(_todoId);
    return result;
  }

  /// Pauses the timer.
  ///
  /// A pause closes the segment exactly like a stop, so the time worked so far
  /// is kept and no second open segment is ever created. The only difference
  /// is the paused mark, which makes the tile offer Resume instead of Start.
  Future<StopTimerResult> pauseTimer() async {
    final result = await _closeTimer();
    if (result.error == null) {
      await _pausedTodos?.markPaused(_todoId);
    }
    return result;
  }

  /// Resumes a paused timer by opening a fresh segment.
  Future<StartTimerResult> resumeTimer() => startTimer();

  /// Closes the running segment at [at], or now, and applies the minimum
  /// segment length rule.
  Future<StopTimerResult> _closeTimer({DateTime? at}) async {
    try {
      final closed = at == null
          ? await _repository.stopSegment(_todoId)
          : await _repository.closeSegmentAt(_todoId, at);

      if (closed == null) {
        await loadSegments();
        return const StopTimerResult();
      }

      // The minimum length only ever applies to a live timer the user started
      // and then ended. Manual entries and restored data never come here.
      final tooShort = isSegmentTooShort(
        closed.durationSeconds ?? 0,
        _minimumSegmentLength(),
      );
      if (tooShort) {
        await _repository.deleteSegment(closed.id);
        await loadSegments();
        return StopTimerResult(discardedSegment: closed);
      }

      await loadSegments();
      return const StopTimerResult();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return StopTimerResult(error: e.toString());
    }
  }

  /// Closes the running segment at the auto-stop cut-off.
  ///
  /// The minimum length rule is deliberately skipped here. The user did not
  /// end this segment, so silently deleting their work would be wrong.
  Future<void> autoStopAt(DateTime cutoff) async {
    try {
      await _repository.closeSegmentAt(_todoId, cutoff);
      await _pausedTodos?.clearPaused(_todoId);
      await loadSegments();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Puts back a segment that was dropped for being too short.
  Future<void> undoDiscardedSegment(TimeSegmentEntity segment) async {
    try {
      await _repository.restoreSegment(segment);
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

  Future<void> updateSegmentNotes(String segmentId, String? notes) async {
    try {
      await _repository.updateSegmentNotes(segmentId, notes);
      await loadSegments();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
