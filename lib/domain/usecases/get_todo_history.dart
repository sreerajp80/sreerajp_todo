import 'package:sreerajp_todo/data/models/todo_history_entity.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';

class GetTodoHistory {
  GetTodoHistory(this._todoRepository);

  final TodoRepository _todoRepository;

  Future<List<TodoHistoryEntity>> call(String todoId) async {
    return _todoRepository.getHistoryForTodo(todoId);
  }
}
