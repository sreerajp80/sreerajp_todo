import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sreerajp_todo/data/models/recall_confidence.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';
import 'package:sreerajp_todo/domain/repositories/time_segment_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/domain/usecases/complete_srs_todo.dart';

class MockTodoRepository extends Mock implements TodoRepository {}
class MockTimeSegmentRepository extends Mock implements TimeSegmentRepository {}
class MockSpacedRepetitionRepository extends Mock implements SpacedRepetitionRepository {}
class FakeSpacedRepetitionItemEntity extends Fake implements SpacedRepetitionItemEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSpacedRepetitionItemEntity());
  });

  late MockTodoRepository todoRepo;
  late MockTimeSegmentRepository segmentRepo;
  late MockSpacedRepetitionRepository srsRepo;
  late CompleteSrsTodo completeSrsTodo;

  setUp(() {
    todoRepo = MockTodoRepository();
    segmentRepo = MockTimeSegmentRepository();
    srsRepo = MockSpacedRepetitionRepository();
    completeSrsTodo = CompleteSrsTodo(todoRepo, segmentRepo, srsRepo);
  });

  test('Hard confidence resets interval to 1 day and level to 1', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final todo = TodoEntity(
      id: 't-1',
      date: '2026-08-10',
      title: 'Study Chapter 1 #mastery',
      status: TodoStatus.pending,
      spacedRepetitionItemId: 'srs-1',
      createdAt: now,
      updatedAt: now,
    );

    final srsItem = SpacedRepetitionItemEntity(
      id: 'srs-1',
      title: 'Study Chapter 1',
      level: 3,
      intervalDays: 21,
      nextReviewDate: '2026-08-10',
      createdAt: now,
      updatedAt: now,
    );

    when(() => todoRepo.getTodoById('t-1')).thenAnswer((_) async => todo);
    when(() => segmentRepo.getRunningSegment('t-1')).thenAnswer((_) async => null);
    when(() => todoRepo.updateStatus('t-1', TodoStatus.completed)).thenAnswer((_) async {});
    when(() => srsRepo.getItemById('srs-1')).thenAnswer((_) async => srsItem);
    when(() => srsRepo.updateItem(any())).thenAnswer((_) async {});

    await completeSrsTodo('t-1', RecallConfidence.hard);

    final captured = verify(() => srsRepo.updateItem(captureAny())).captured.single as SpacedRepetitionItemEntity;
    expect(captured.level, 1);
    expect(captured.intervalDays, 1);
  });

  test('Easy confidence increases level and expands interval to 7 * level', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    final todo = TodoEntity(
      id: 't-1',
      date: '2026-08-10',
      title: 'Study Chapter 1 #mastery',
      status: TodoStatus.pending,
      spacedRepetitionItemId: 'srs-1',
      createdAt: now,
      updatedAt: now,
    );

    final srsItem = SpacedRepetitionItemEntity(
      id: 'srs-1',
      title: 'Study Chapter 1',
      level: 1,
      intervalDays: 1,
      nextReviewDate: '2026-08-10',
      createdAt: now,
      updatedAt: now,
    );

    when(() => todoRepo.getTodoById('t-1')).thenAnswer((_) async => todo);
    when(() => segmentRepo.getRunningSegment('t-1')).thenAnswer((_) async => null);
    when(() => todoRepo.updateStatus('t-1', TodoStatus.completed)).thenAnswer((_) async {});
    when(() => srsRepo.getItemById('srs-1')).thenAnswer((_) async => srsItem);
    when(() => srsRepo.updateItem(any())).thenAnswer((_) async {});

    await completeSrsTodo('t-1', RecallConfidence.easy);

    final captured = verify(() => srsRepo.updateItem(captureAny())).captured.single as SpacedRepetitionItemEntity;
    expect(captured.level, 2);
    expect(captured.intervalDays, 14);
  });
}
