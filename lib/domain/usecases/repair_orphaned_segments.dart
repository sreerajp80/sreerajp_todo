import 'package:flutter/foundation.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';

class RepairOrphanedSegments {
  RepairOrphanedSegments(this._timeSegmentRepository);

  final TimeSegmentRepository _timeSegmentRepository;

  /// Closes all orphaned segments (open segments on past-date todos)
  /// with zero duration and marks them as interrupted.
  Future<void> call() async {
    final today = todayAsIso();
    await _timeSegmentRepository.repairOrphanedSegments(today);
    debugPrint('RepairOrphanedSegments: repaired orphans before $today');
  }
}
