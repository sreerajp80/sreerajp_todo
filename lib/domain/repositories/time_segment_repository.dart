import 'package:sreerajp_todo/data/models/time_segment_entity.dart';

abstract class TimeSegmentRepository {
  Future<void> startSegment(String todoId);

  /// Closes the open segment on [todoId] and returns it as saved, so the
  /// caller can apply the minimum-segment-length rule. Returns null when
  /// nothing was running.
  Future<TimeSegmentEntity?> stopSegment(String todoId);

  /// Closes the open segment on [todoId] at [at] instead of now.
  ///
  /// Used by auto-stop, so a timer left running past the cut-off is closed at
  /// the cut-off with its real length rather than at zero.
  Future<TimeSegmentEntity?> closeSegmentAt(String todoId, DateTime at);

  /// Every open segment in the database, whatever todo it belongs to.
  ///
  /// Used by the app-wide watcher that auto-pauses and auto-stops timers.
  Future<List<TimeSegmentEntity>> getAllRunningSegments();

  /// Closes every open segment in the database, skipping [exceptTodoId].
  ///
  /// Returns the todo ids that were actually stopped, so the caller can tell
  /// the user which timer it took over from.
  Future<List<String>> stopAllRunningSegments({String? exceptTodoId});

  /// Permanently removes one segment.
  ///
  /// Only used to drop a live segment that came out shorter than the user's
  /// minimum length, and to undo that drop is a re-insert.
  Future<void> deleteSegment(String segmentId);

  /// Puts a segment back exactly as it was.
  ///
  /// This is the undo half of [deleteSegment]. It skips the manual-entry
  /// checks on purpose, because the segment was already valid when it was
  /// dropped and re-checking could refuse to restore the user's own data.
  Future<void> restoreSegment(TimeSegmentEntity segment);

  Future<List<TimeSegmentEntity>> getSegments(String todoId);
  Future<TimeSegmentEntity?> getRunningSegment(String todoId);
  Future<void> insertManualSegment(TimeSegmentEntity segment);
  Future<void> updateSegmentNotes(String segmentId, String? notes);

  /// Replaces the start and end time of a closed segment.
  ///
  /// Enforces day-lock, terminal-status, running-segment, and overlap checks.
  Future<void> updateSegmentTimes(
    String segmentId,
    DateTime newStart,
    DateTime newEnd,
  );

  /// Closes open segments left on days before [todayDate].
  ///
  /// When [closeAt] returns a time for a segment, it is closed then with its
  /// real length. When it returns null the segment keeps the original
  /// behaviour of a zero-length interrupted segment.
  Future<void> repairOrphanedSegments(
    String todayDate, {
    DateTime? Function(DateTime segmentStart)? closeAt,
  });
}
