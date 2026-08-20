import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/data/dao/spaced_repetition_dao.dart';
import 'package:sreerajp_todo/data/database/database_service.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';

import '../helpers/test_database.dart';

void main() {
  late DatabaseService databaseService;
  late SpacedRepetitionDao srsDao;

  setUpAll(initFfi);

  setUp(() async {
    databaseService = await createTestDatabaseService();
    srsDao = SpacedRepetitionDao(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
  });

  SpacedRepetitionItemEntity makeItem({
    String id = 'srs-1',
    String title = 'Lalitha Sahasranamam Ch 1',
    int level = 1,
    int intervalDays = 1,
    String nextReviewDate = '2026-08-10',
    bool active = true,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return SpacedRepetitionItemEntity(
      id: id,
      title: title,
      level: level,
      intervalDays: intervalDays,
      nextReviewDate: nextReviewDate,
      active: active,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('SpacedRepetitionDao CRUD operations', () {
    test('inserts and retrieves an SRS item', () async {
      await srsDao.insert(makeItem());

      final result = await srsDao.findById('srs-1');
      expect(result, isNotNull);
      expect(result!.title, 'Lalitha Sahasranamam Ch 1');
      expect(result.level, 1);
      expect(result.intervalDays, 1);
    });

    test('finds due items on or before date', () async {
      await srsDao.insert(makeItem(id: 'srs-1', nextReviewDate: '2026-08-10'));
      await srsDao.insert(
        makeItem(id: 'srs-2', title: 'Item 2', nextReviewDate: '2026-08-15'),
      );

      final dueItems = await srsDao.findDueOnOrBefore('2026-08-10');
      expect(dueItems.length, 1);
      expect(dueItems.first.id, 'srs-1');
    });

    test('updates SRS item interval and level', () async {
      await srsDao.insert(makeItem());
      final item = await srsDao.findById('srs-1');

      final updated = item!.copyWith(
        level: 2,
        intervalDays: 14,
        nextReviewDate: '2026-08-24',
      );
      await srsDao.update(updated);

      final fetched = await srsDao.findById('srs-1');
      expect(fetched!.level, 2);
      expect(fetched.intervalDays, 14);
      expect(fetched.nextReviewDate, '2026-08-24');
    });

    test('deletes SRS item', () async {
      await srsDao.insert(makeItem());
      await srsDao.delete('srs-1');

      final result = await srsDao.findById('srs-1');
      expect(result, isNull);
    });
  });
}
