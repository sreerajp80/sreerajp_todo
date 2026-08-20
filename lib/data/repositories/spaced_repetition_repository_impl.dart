import 'package:sreerajp_todo/data/dao/spaced_repetition_dao.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';

class SpacedRepetitionRepositoryImpl implements SpacedRepetitionRepository {
  SpacedRepetitionRepositoryImpl(this._dao);

  final SpacedRepetitionDao _dao;

  @override
  Future<void> insertItem(SpacedRepetitionItemEntity item) => _dao.insert(item);

  @override
  Future<void> updateItem(SpacedRepetitionItemEntity item) => _dao.update(item);

  @override
  Future<void> deleteItem(String id) => _dao.delete(id);

  @override
  Future<SpacedRepetitionItemEntity?> getItemById(String id) =>
      _dao.findById(id);

  @override
  Future<SpacedRepetitionItemEntity?> getItemByTitle(String title) =>
      _dao.findByTitle(title);

  @override
  Future<List<SpacedRepetitionItemEntity>> getItemsDueOnOrBefore(
    String dateStr,
  ) => _dao.findDueOnOrBefore(dateStr);

  @override
  Future<List<SpacedRepetitionItemEntity>> getAllActiveItems() =>
      _dao.findAllActive();

  @override
  Future<List<SpacedRepetitionItemEntity>> getAllItems() => _dao.findAll();
}
