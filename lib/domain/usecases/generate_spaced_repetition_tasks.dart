import 'package:sreerajp_todo/domain/repositories/spaced_repetition_repository.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class GenerateSpacedRepetitionTasks {
  GenerateSpacedRepetitionTasks(this._srsRepository, this._todoRepository);

  // ignore: unused_field
  final SpacedRepetitionRepository _srsRepository;
  // ignore: unused_field
  final TodoRepository _todoRepository;

  /// Mastery decks are containers for tasks. They do not auto-generate tasks.
  /// Tasks are created by the user under the deck.
  Future<int> call() async {
    return 0;
  }
}
