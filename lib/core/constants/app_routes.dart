abstract final class AppRoutes {
  static const String root = '/';
  static const String dailyList = '/day/:date';
  static const String createTodo = '/todo/new';
  static const String editTodo = '/todo/:id';
  static const String timeSegments = '/todo/:id/segments';
  static const String copyTodos = '/copy';
  static const String search = '/search';
  static const String backup = '/backup';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String permissions = '/permissions';
  static const String recurring = '/recurring';
  static const String recurringNew = '/recurring/new';
  static const String recurringEdit = '/recurring/:id';
  static const String statistics = '/statistics';

  static String dailyListPath(String date) => '/day/$date';
  static String editTodoPath(String id) => '/todo/$id';
  static String timeSegmentsPath(String id) => '/todo/$id/segments';
  static String recurringEditPath(String id) => '/recurring/$id';
  static String copyTodosPath(String fromDate) => '/copy?from=$fromDate';
}
