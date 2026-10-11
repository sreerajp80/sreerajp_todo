/// How important a task is.
///
/// Stored as text in the `todos.priority` column, the same way `TodoStatus` is
/// stored, so a database row stays readable without a lookup table.
///
/// The order of the values is deliberate: it runs from least to most urgent, so
/// `index` can be used directly for sorting.
enum TodoPriority {
  low,
  normal,
  high,
  urgent;

  String toDbString() => name;

  /// Reads a stored priority.
  ///
  /// Unlike `TodoStatus.fromDbString` this never throws. A row written by a
  /// newer build, or a hand-edited database, must not stop the day list from
  /// loading, so anything unknown falls back to [TodoPriority.normal].
  static TodoPriority fromDbString(String? value) {
    if (value == null) return TodoPriority.normal;
    return TodoPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TodoPriority.normal,
    );
  }
}
