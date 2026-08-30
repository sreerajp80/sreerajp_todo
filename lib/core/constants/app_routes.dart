abstract final class AppRoutes {
  static const String root = '/';
  static const String dailyList = '/day/:date';
  static const String createTodo = '/todo/new';
  static const String editTodo = '/todo/:id';
  static const String timeSegments = '/todo/:id/segments';
  static const String todoHistory = '/todo/:id/history';
  static const String focus = '/focus/:id';
  static const String copyTodos = '/copy';
  static const String search = '/search';
  static const String backup = '/backup';
  static const String settings = '/settings';
  static const String appearance = '/settings/appearance';
  static const String themeMode = '/settings/appearance/theme-mode';
  static const String typography = '/settings/appearance/typography';
  static const String accentColor = '/settings/appearance/accent-color';
  static const String timeTracking = '/settings/time-tracking';
  static const String autoStop = '/settings/time-tracking/auto-stop';
  static const String timerBehaviour = '/settings/time-tracking/timer';
  static const String pomodoro = '/settings/time-tracking/pomodoro';
  static const String focusMode = '/settings/time-tracking/focus';
  static const String timeDisplay = '/settings/time-tracking/display';
  static const String taskDefaults = '/settings/task-defaults';
  static const String defaultsNewTask = '/settings/task-defaults/new-task';
  static const String defaultsDayList = '/settings/task-defaults/day-list';
  static const String defaultsTaskActions = '/settings/task-defaults/actions';
  static const String defaultsAutocomplete =
      '/settings/task-defaults/autocomplete';
  static const String language = '/settings/language';
  static const String dateTime = '/settings/date-time';
  static const String weekStart = '/settings/date-time/week-start';
  static const String clockFormat = '/settings/date-time/clock-format';
  static const String dateFormat = '/settings/date-time/date-format';
  static const String dayStart = '/settings/date-time/day-start';
  static const String workingDays = '/settings/date-time/working-days';
  static const String security = '/settings/security';
  static const String appLock = '/settings/security/app-lock';
  static const String autoLock = '/settings/security/auto-lock';
  static const String databaseKey = '/settings/security/database-key';
  static const String backupSettings = '/settings/backup';
  static const String autoBackup = '/settings/backup/auto-backup';
  static const String backupLocation = '/settings/backup/location';
  static const String backupRetention = '/settings/backup/retention';
  static const String backupPassphrase = '/settings/backup/passphrase';
  static const String about = '/about';
  static const String permissions = '/permissions';
  static const String statistics = '/statistics';
  static const String masteryDeck = '/mastery-deck';

  /// The guided day open. Always runs for today, so it takes no date.
  static const String ritual = '/ritual';

  /// The Ritual Deck browser. Kept apart from [masteryDeck] on purpose: one
  /// holds reflection cards, the other holds real tasks.
  static const String ritualDeck = '/ritual/deck';

  /// Settings -> Ritual mode.
  static const String ritualSettings = '/settings/ritual';
  static const String pendingAlerts = '/settings/pending-alerts';
  static const String airQrScan = '/air-qr-scan';
  static const String wifiSync = '/wifi-sync';
  static const String dataHandoff = '/data-handoff';
  static const String features = '/features';
  static const String help = '/help';
  static const String helpTaskManagement = '/help/task-management';
  static const String helpTimeTracking = '/help/time-tracking';
  static const String helpFocus = '/help/focus-pomodoro';
  static const String helpMasteryDeck = '/help/mastery-deck';
  static const String helpRecurringTasks = '/help/recurring-tasks';
  static const String helpWifiSync = '/help/wifi-sync';
  static const String helpQrHandoff = '/help/qr-handoff';
  static const String helpPrivacySecurity = '/help/privacy-security';
  static const String helpBackup = '/help/backup';
  static const String helpFaq = '/help/faq';

  /// Builds the create-task route, with anything already known filled in.
  ///
  /// The voice sheet uses every argument; the day list only passes [date].
  /// Query strings are built here rather than by hand at each call site, so
  /// escaping a title that holds a `&` or a `?` can never be forgotten.
  static String createTodoPath({
    String? date,
    String? title,
    String? description,
    int? targetSeconds,
    String? priority,
  }) {
    final params = <String, String>{
      if (date != null && date.isNotEmpty) 'date': date,
      if (title != null && title.isNotEmpty) 'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (targetSeconds != null) 'target': '$targetSeconds',
      if (priority != null && priority.isNotEmpty) 'priority': priority,
    };
    if (params.isEmpty) return createTodo;
    final query = params.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
    return '$createTodo?$query';
  }

  static String dailyListPath(String date) => '/day/$date';
  static String editTodoPath(String id) => '/todo/$id';
  static String timeSegmentsPath(String id) => '/todo/$id/segments';
  static String todoHistoryPath(String id) => '/todo/$id/history';
  static String focusPath(String id) => '/focus/$id';
  static String copyTodosPath(String fromDate) => '/copy?from=$fromDate';
}
