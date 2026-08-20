import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';

part 'todo_search_result.freezed.dart';

/// One row of a cross-day search.
///
/// [matchedNote] carries the original (unfolded) text of the time segment note
/// that matched, when the hit came from a note rather than from the title or
/// description. It is null otherwise, and the screen falls back to showing the
/// description.
@freezed
class TodoSearchResult with _$TodoSearchResult {
  const factory TodoSearchResult({
    required TodoEntity todo,
    String? matchedNote,
  }) = _TodoSearchResult;
}
