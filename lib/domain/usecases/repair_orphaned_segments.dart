import 'package:flutter/foundation.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';

class RepairOrphanedSegments {
  RepairOrphanedSegments(
    this._timeSegmentRepository, {
    AutoStopMode Function()? autoStopMode,
    int Function()? autoStopHour,
    int Function()? autoStopMinute,
  }) : _autoStopMode = autoStopMode ?? _noAutoStop,
       _autoStopHour = autoStopHour ?? _zero,
       _autoStopMinute = autoStopMinute ?? _zero;

  final TimeSegmentRepository _timeSegmentRepository;
  final AutoStopMode Function() _autoStopMode;
  final int Function() _autoStopHour;
  final int Function() _autoStopMinute;

  static AutoStopMode _noAutoStop() => AutoStopMode.off;
  static int _zero() => 0;

  /// Closes open segments left behind on past days.
  ///
  /// With auto-stop off this keeps the original behaviour: the segment is
  /// closed with zero duration and marked interrupted, because there is no
  /// honest way to know how long the user really worked.
  ///
  /// With auto-stop on, the segment is instead closed at the cut-off that
  /// followed its start, so real worked time is no longer thrown away.
  Future<void> call() async {
    final today = todayAsIso();
    final mode = _autoStopMode();
    final now = DateTime.now();

    await _timeSegmentRepository.repairOrphanedSegments(
      today,
      closeAt: mode == AutoStopMode.off
          ? null
          : (segmentStart) => orphanCloseTime(
              segmentStart,
              now,
              mode,
              customHour: _autoStopHour(),
              customMinute: _autoStopMinute(),
            ),
    );
    debugPrint('RepairOrphanedSegments: repaired orphans before $today');
  }
}
