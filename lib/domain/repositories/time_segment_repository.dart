import 'package:sreerajp_todo/data/models/time_segment_entity.dart';

abstract class TimeSegmentRepository {
  Future<void> startSegment(String todoId);
  Future<void> stopSegment(String todoId);
  Future<List<TimeSegmentEntity>> getSegments(String todoId);
  Future<TimeSegmentEntity?> getRunningSegment(String todoId);
  Future<void> insertManualSegment(TimeSegmentEntity segment);
  Future<void> repairOrphanedSegments(String todayDate);
}
