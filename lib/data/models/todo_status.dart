enum TodoStatus {
  pending,
  completed,
  dropped,
  ported;

  String toDbString() => name;

  static TodoStatus fromDbString(String value) {
    return TodoStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown TodoStatus: $value'),
    );
  }
}
