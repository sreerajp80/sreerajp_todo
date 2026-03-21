class DayStats {
  const DayStats({
    required this.date,
    required this.total,
    required this.completed,
    required this.dropped,
    required this.ported,
    required this.pending,
  });

  final String date;
  final int total;
  final int completed;
  final int dropped;
  final int ported;
  final int pending;
}

class TodoTimeStats {
  const TodoTimeStats({
    required this.title,
    required this.date,
    required this.totalSeconds,
  });

  final String title;
  final String date;
  final int totalSeconds;
}
