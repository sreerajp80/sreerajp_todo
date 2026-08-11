import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/daily_reflection_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';
import 'package:sreerajp_todo/data/models/daily_reflection_entity.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late DailyReflectionDao dao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    dao = DailyReflectionDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('DailyReflectionDao', () {
    test('saveReflection and findReflectionByDate', () async {
      final now = DateTime.now().toIso8601String();
      final reflection = DailyReflectionEntity(
        date: '2026-08-10',
        reflectionNote: 'Focused on single-tasking all day.',
        completedSeconds: 3600,
        droppedSeconds: 300,
        createdAt: now,
        updatedAt: now,
      );

      await dao.saveReflection(reflection);

      final found = await dao.findReflectionByDate('2026-08-10');
      expect(found, isNotNull);
      expect(found!.date, '2026-08-10');
      expect(found.reflectionNote, 'Focused on single-tasking all day.');
      expect(found.completedSeconds, 3600);
      expect(found.droppedSeconds, 300);
    });

    test('saveIntention and findIntentionByDate', () async {
      final now = DateTime.now().toIso8601String();
      final intention = DailyIntentionEntity(
        date: '2026-08-10',
        intentionText: 'Prioritize steady progress over perfection.',
        createdAt: now,
      );

      await dao.saveIntention(intention);

      final found = await dao.findIntentionByDate('2026-08-10');
      expect(found, isNotNull);
      expect(found!.date, '2026-08-10');
      expect(found.intentionText, 'Prioritize steady progress over perfection.');
    });

    test('saveReflection overwrites existing record on same date', () async {
      final now = DateTime.now().toIso8601String();
      final first = DailyReflectionEntity(
        date: '2026-08-10',
        reflectionNote: 'Initial note',
        completedSeconds: 100,
        droppedSeconds: 0,
        createdAt: now,
        updatedAt: now,
      );
      await dao.saveReflection(first);

      final updated = first.copyWith(
        reflectionNote: 'Updated reflection note',
        completedSeconds: 500,
      );
      await dao.saveReflection(updated);

      final found = await dao.findReflectionByDate('2026-08-10');
      expect(found, isNotNull);
      expect(found!.reflectionNote, 'Updated reflection note');
      expect(found.completedSeconds, 500);
    });
  });
}
