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
  static const String statistics = '/statistics';
  static const String masteryDeck = '/mastery-deck';
  static const String airQrScan = '/air-qr-scan';
  static const String wifiSync = '/wifi-sync';
  static const String dataHandoff = '/data-handoff';

  static String dailyListPath(String date) => '/day/$date';
  static String editTodoPath(String id) => '/todo/$id';
  static String timeSegmentsPath(String id) => '/todo/$id/segments';
  static String copyTodosPath(String fromDate) => '/copy?from=$fromDate';
}
