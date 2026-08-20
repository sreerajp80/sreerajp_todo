import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/spaced_repetition_dao.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/services/p2p_wifi_sync_service.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_payload.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_scope.dart';
import '../../helpers/test_database.dart';

void main() {
  late TodoDao todoDao;
  late TimeSegmentDao timeSegmentDao;
  late RecurrenceRuleDao recurrenceRuleDao;
  late SpacedRepetitionDao spacedRepetitionDao;
  late P2pWifiSyncService syncService;

  setUp(() async {
    final dbService = await createTestDatabaseService();
    todoDao = TodoDao(dbService);
    timeSegmentDao = TimeSegmentDao(dbService);
    recurrenceRuleDao = RecurrenceRuleDao(dbService);
    spacedRepetitionDao = SpacedRepetitionDao(dbService);

    syncService = P2pWifiSyncService(
      todoDao,
      timeSegmentDao,
      recurrenceRuleDao,
      spacedRepetitionDao,
    );
  });

  group('P2pWifiSyncService Unit Tests', () {
    test('getLocalIpAddresses returns non-empty list of IP strings', () async {
      final ips = await P2pWifiSyncService.getLocalIpAddresses();
      expect(ips, isNotEmpty);
      expect(ips.first, isNotEmpty);
    });

    test(
      'buildPayload constructs valid P2pSyncPayload from database',
      () async {
        final today = todayAsIso();
        await todoDao.insert(
          TodoEntity(
            id: 'todo-1',
            title: 'Payload Task 1',
            date: today,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

        final payload = await syncService.buildPayload(
          scope: const P2pSyncScope.full(),
          targetDate: today,
        );

        expect(payload.date, equals(today));
        expect(payload.todos.length, equals(1));
        expect(payload.todos.first.title, equals('Payload Task 1'));
      },
    );

    test(
      'mergeIncomingPayload performs Add-Only Non-Destructive Merge',
      () async {
        final today = todayAsIso();

        // Seed local DB with 1 task
        await todoDao.insert(
          TodoEntity(
            id: 'existing-1',
            title: 'Existing Task',
            date: today,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

        final incomingPayload = P2pSyncPayload(
          date: today,
          exportedAt: DateTime.now().toIso8601String(),
          scope: const P2pSyncScope.full(),
          todos: [
            TodoEntity(
              id: 'incoming-1',
              title: 'Existing Task', // Duplicate title on same date
              date: today,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
            TodoEntity(
              id: 'incoming-2',
              title: 'Brand New Remote Task',
              date: today,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
          ],
          masteryItems: [
            const SpacedRepetitionItemEntity(
              id: 'srs-1',
              title: 'Remote Habit Mastery',
              nextReviewDate: '2026-08-11',
              createdAt: '2026-08-11T12:00:00Z',
              updatedAt: '2026-08-11T12:00:00Z',
            ),
          ],
        );

        final result = await syncService.mergeIncomingPayload(incomingPayload);

        expect(result.todosAdded, equals(1));
        expect(result.todosSkipped, equals(1));
        expect(result.masteryAdded, equals(1));

        final allTodos = await todoDao.findByDate(today);
        expect(allTodos.length, equals(2));
        expect(allTodos.any((t) => t.title == 'Brand New Remote Task'), isTrue);

        final allMastery = await spacedRepetitionDao.findAll();
        expect(allMastery.length, equals(1));
        expect(allMastery.first.title, equals('Remote Habit Mastery'));
      },
    );

    test(
      'P2pSyncPayload deserialization truncates fields exceeding 4KB cap',
      () {
        final oversizedTitle = 'A' * 5000;
        final payloadJson = {
          'date': '2026-08-11',
          'exported_at': '2026-08-11T12:00:00Z',
          'scope': {'todays_tasks': true},
          'todos': [
            {
              'id': 'over-1',
              'title': oversizedTitle,
              'date': '2026-08-11',
              'status': 'pending',
              'created_at': '2026-08-11T12:00:00Z',
              'updated_at': '2026-08-11T12:00:00Z',
            },
          ],
        };

        final payload = P2pSyncPayload.fromJson(payloadJson);
        expect(
          payload.todos.first.title.length,
          equals(P2pSyncBounds.maxFieldLen),
        );
      },
    );
  });
}
