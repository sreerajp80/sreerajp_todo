import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';
import 'package:sreerajp_todo/data/models/daily_reflection_entity.dart';

abstract class DailyReflectionRepository {
  Future<DailyReflectionEntity?> getReflectionForDate(String date);
  Future<void> saveReflection(
    DailyReflectionEntity reflection, {
    bool bypassLock = false,
  });
  Future<DailyIntentionEntity?> getIntentionForDate(String date);
  Future<void> saveIntention(
    DailyIntentionEntity intention, {
    bool bypassLock = false,
  });
}
