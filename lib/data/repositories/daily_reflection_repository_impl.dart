import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/daily_reflection_dao.dart';
import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';
import 'package:sreerajp_todo/data/models/daily_reflection_entity.dart';
import 'package:sreerajp_todo/domain/repositories/daily_reflection_repository.dart';

class DailyReflectionRepositoryImpl implements DailyReflectionRepository {
  DailyReflectionRepositoryImpl(this._dao);

  final DailyReflectionDao _dao;

  void _checkDayLock(String date, {bool bypassLock = false}) {
    if (!bypassLock && isPastDate(date)) {
      throw const DayLockedException();
    }
  }

  @override
  Future<DailyReflectionEntity?> getReflectionForDate(String date) {
    return _dao.findReflectionByDate(date);
  }

  @override
  Future<void> saveReflection(
    DailyReflectionEntity reflection, {
    bool bypassLock = false,
  }) async {
    _checkDayLock(reflection.date, bypassLock: bypassLock);
    final normalized = reflection.copyWith(
      reflectionNote: nfcNormalize(reflection.reflectionNote),
    );
    await _dao.saveReflection(normalized);
  }

  @override
  Future<DailyIntentionEntity?> getIntentionForDate(String date) {
    return _dao.findIntentionByDate(date);
  }

  @override
  Future<void> saveIntention(
    DailyIntentionEntity intention, {
    bool bypassLock = false,
  }) async {
    _checkDayLock(intention.date, bypassLock: bypassLock);
    final normalized = intention.copyWith(
      intentionText: nfcNormalize(intention.intentionText),
    );
    await _dao.saveIntention(normalized);
  }
}
