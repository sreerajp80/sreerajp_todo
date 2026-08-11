import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';

abstract class SpacedRepetitionRepository {
  Future<void> insertItem(SpacedRepetitionItemEntity item);
  Future<void> updateItem(SpacedRepetitionItemEntity item);
  Future<void> deleteItem(String id);
  Future<SpacedRepetitionItemEntity?> getItemById(String id);
  Future<SpacedRepetitionItemEntity?> getItemByTitle(String title);
  Future<List<SpacedRepetitionItemEntity>> getItemsDueOnOrBefore(String dateStr);
  Future<List<SpacedRepetitionItemEntity>> getAllActiveItems();
  Future<List<SpacedRepetitionItemEntity>> getAllItems();
}
