abstract final class AppStrings {
  static const String appName = 'SreerajP ToDo';

  static const String dailyList = 'My ToDos';
  static const String createTodo = 'New Todo';
  static const String editTodo = 'Edit Todo';
  static const String timeSegments = 'Time Segments';
  static const String copyTodos = 'Copy Todos';
  static const String searchResults = 'Search Results';
  static const backup = _BackupStrings();
  static const settings = _SettingsStrings();
  static const permissions = _PermissionsStrings();
  static const about = _AboutStrings();
  static const String recurringTasks = 'Recurring Tasks';
  static const String newRecurrence = 'New Recurrence Rule';
  static const String editRecurrence = 'Edit Recurrence Rule';
  static const String statistics = 'Statistics';
  static const stats = _StatisticsStrings();

  static const String titleHint = 'Enter task title';
  static const String descriptionHint = 'Enter description (optional)';
  static const String searchHint = 'Search todos...';
  static const String noTodosForDay = 'No tasks for this day';
  static const String noSearchResults = 'No results found';
  static const String titleRequired = 'Title is required';
  static const String addFirstTask = 'Add your first task';
  static const String noTasksTodayTitle = 'No tasks today';
  static const String noTasksTodayMessage =
      'Add your first task to start planning this day.';
  static const String noTasksForPastDayMessage =
      'No tasks were recorded for this day.';
  static const String searchTasksTitle = 'Search your tasks';
  static const String searchTasksMessage =
      'Enter a title or description to search across days.';
  static const String noStatisticsData =
      'Start tracking tasks to see your statistics';
  static const String noRecurringTasksDetailed =
      'No recurring tasks. Create one to automate task creation.';
  static const String noSegmentsRecordedDetailed =
      'Track time or add a manual segment to see history here.';
  static const String backupDirectory = 'Backup folder';
  static const String previousDay = 'Previous day';
  static const String nextDay = 'Next day';
  static const String openCalendar = 'Open calendar';
  static const String clearSearch = 'Clear search';
  static const String toggleSelection = 'Toggle selection';
  static const String openTaskActions = 'Open task actions';
  static const String lockedTask = 'Locked task';
  static const String manualSegmentShort = 'M';
  static const String emptyValue = '—';
  static const String day = 'Day';
  static const String details = 'Details';
  static const String taskStatus = 'Status';
  static const String mondayLong = 'Monday';
  static const String tuesdayLong = 'Tuesday';
  static const String wednesdayLong = 'Wednesday';
  static const String thursdayLong = 'Thursday';
  static const String fridayLong = 'Friday';
  static const String saturdayLong = 'Saturday';
  static const String sundayLong = 'Sunday';
  static const String january = 'January';
  static const String february = 'February';
  static const String march = 'March';
  static const String april = 'April';
  static const String may = 'May';
  static const String june = 'June';
  static const String july = 'July';
  static const String august = 'August';
  static const String september = 'September';
  static const String october = 'October';
  static const String november = 'November';
  static const String december = 'December';

  static const String statusPending = 'Pending';
  static const String statusCompleted = 'Completed';
  static const String statusDropped = 'Dropped';
  static const String statusPorted = 'Ported';
  static const String completeAction = 'Complete';
  static const String dropAction = 'Drop';

  static const String confirmDrop = 'Drop this task?';
  static const String confirmDropBody =
      'This task will be marked as dropped. Time spent will be categorised as dropped time.';
  static const String confirmPort = 'Port this task?';
  static const String confirmPortBody =
      'This task will be moved to the selected date.';
  static const String confirmDelete = 'Delete this task?';
  static const String confirmDeleteBody =
      'This task and all its time segments will be permanently deleted.';
  static const String confirmDeleteRecurring = 'Delete recurring task?';
  static const String confirmDeleteRecurringBody =
      'This task was created by a recurrence rule.';
  static const String deleteOnlyThis = 'Delete only this one';
  static const String deleteAllOccurrences = 'Delete all occurrences';
  static const String allOccurrencesDeleted = 'All occurrences deleted';
  static const String confirmBulkDrop = 'Drop selected tasks?';
  static const String confirmBulkDropBody =
      'All selected tasks will be marked as dropped.';
  static const String confirm = 'Confirm';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String undo = 'Undo';
  static const String edit = 'Edit';
  static const String port = 'Port';
  static const String copy = 'Copy';
  static const String retry = 'Retry';
  static const String today = 'Today';
  static const String selectTargetDate = 'Select target date';
  static const String completeAll = 'Complete All';
  static const String markDropped = 'Mark Dropped';
  static const String selectAll = 'Select All';
  static const String deselectAll = 'Deselect All';
  static const String copyToAnotherDay = 'Copy to another day';
  static const String previous = 'Previous';

  static const String copiedFrom = 'Copied from';
  static const String portedTo = 'Ported to';
  static const String noDescription = 'No description';

  static const String startTimer = 'Start timer';
  static const String stopTimer = 'Stop timer';
  static const String timerRunning = 'Timer running';
  static const String addManualSegment = 'Add Manual Segment';
  static const String manualSegmentAdded = 'Manual segment added';
  static const String segmentStart = 'Start time';
  static const String segmentEnd = 'End time';
  static const String segmentType = 'Type';
  static const String segmentDuration = 'Duration';
  static const String segmentAuto = 'Auto';
  static const String segmentManual = 'Manual';
  static const String segmentRunning = 'running...';
  static const String segmentInterruptedTooltip = 'Auto-closed on app restart';
  static const String totalTime = 'Total time';
  static const String viewSegments = 'Time Segments';
  static const String noSegments = 'No time segments recorded';
  static const String startBeforeEnd = 'Start time must be before end time';
  static const String segmentOverlap =
      'This segment overlaps with an existing one';
  static const String segmentMustBeSameDay =
      'Both times must fall within the same calendar day';

  static const String statusChangedTo = 'Status changed to';
  static const String undoStatusChange = 'Status change undone';
  static const String bulkStatusChanged = 'tasks updated';
  static const String todoCreated = 'Task created';
  static const String todoUpdated = 'Task updated';
  static const String todoDeleted = 'Task deleted';
  static const String todoPorted = 'Task ported';
  static const String todosCopied = 'tasks copied';
  static const String todosSkipped = 'skipped (duplicate title)';

  static const String stepSelectItems = 'Select Items';
  static const String stepPickDate = 'Pick Date';
  static const String stepPreview = 'Preview';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String copyConfirm = 'Copy';
  static const String noItemsSelected = 'Select at least one item';
  static const String willBeSkipped = 'Already exists - will be skipped';
  static const String itemsToCopy = 'items to copy';
  static const String itemsWillBeSkipped = 'will be skipped';
  static const String targetDate = 'Target Date';
  static const String sourceDate = 'Source Date';
  static const String selectDateFirst = 'Select a target date first';

  static const String viewTodo = 'View Todo';
  static const String readOnlyPastDate = 'Past date - read only';

  static String selectedCount(int count) => '$count selected';
  static String noSearchResultsForQuery(String query) =>
      "No tasks found matching '$query'";
  static String statusSemantics(String status) => 'Status: $status';
  static String totalTimeForTask(String title, String duration) =>
      'Total time for $title: $duration';
  static String startTimerForTask(String title) => 'Start timer for $title';
  static String stopTimerForTask(String title) => 'Stop timer for $title';
  static String runningTimerForTask(String title) => 'Timer running for $title';
  static String segmentSemantics({
    required int index,
    required String start,
    required String end,
    required String duration,
    required String type,
  }) {
    return 'Segment $index. $start to $end. Duration $duration. Type $type.';
  }

  static const String repeat = 'Repeat';
  static const String repeatNone = 'None';
  static const String repeatConfigure = 'Repeat\u2026';
  static const String repeatsInfo = 'This task repeats';
  static const String recurrenceCreated = 'Task and recurrence rule created';

  static const String noRecurrenceRules = 'No recurrence rules yet';
  static const String deleteRecurrenceRule = 'Delete recurrence rule?';
  static const String deleteRecurrenceRuleBody =
      'Existing tasks created by this rule will not be affected.';
  static const String recurrenceRuleDeleted = 'Recurrence rule deleted';
  static const String recurrenceRuleSaved = 'Recurrence rule saved';
  static const String recurrenceRuleUpdated = 'Recurrence rule updated';
  static const String active = 'Active';
  static const String paused = 'Paused';
  static const String noEndDate = 'No end date';
  static const String startDate = 'Start date';
  static const String endDate = 'End date';
  static const String frequency = 'Frequency';
  static const String interval = 'Interval';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String yearly = 'Yearly';
  static const String every = 'Every';
  static const String days = 'days';
  static const String weeks = 'weeks';
  static const String months = 'months';
  static const String years = 'years';
  static const String daysOfWeek = 'Days of week';
  static const String dayOfMonth = 'Day of month';
  static const String specificDate = 'Specific date';
  static const String ordinalWeekday = 'Ordinal weekday';
  static const String month = 'Month';
  static const String preview = 'Preview';
  static const String nextOccurrences = 'Next 5 occurrences';
  static const String noUpcomingOccurrences = 'No upcoming occurrences';
  static const String selectDaysOfWeek = 'Select at least one day';

  static const String monday = 'Mon';
  static const String tuesday = 'Tue';
  static const String wednesday = 'Wed';
  static const String thursday = 'Thu';
  static const String friday = 'Fri';
  static const String saturday = 'Sat';
  static const String sunday = 'Sun';

  static const String first = 'First';
  static const String second = 'Second';
  static const String third = 'Third';
  static const String fourth = 'Fourth';
  static const String last = 'Last';

  static const String sortTodos = 'Sort';
  static const String sortManual = 'Manual order';
  static const String sortNameAZ = 'Name A\u2192Z';
  static const String sortNameZA = 'Name Z\u2192A';
  static const String sortCreatedOldest = 'Created (oldest first)';
  static const String sortCreatedNewest = 'Created (newest first)';
  static const String sortTimeMost = 'Time spent (most first)';
  static const String sortTimeLeast = 'Time spent (least first)';
  static const String sortByStatus = 'By status';

  static const errors = _ErrorStrings();
}

class _BackupStrings {
  const _BackupStrings();

  String get label => 'Backup';
  String get exportTitle => 'Export Backup';
  String get importTitle => 'Restore from Backup';
  String get passphraseLabel => 'Backup Passphrase';
  String get passphraseConfirmLabel => 'Confirm Passphrase';
  String get passphraseMinLength => 'Passphrase must be at least 8 characters';
  String get passphraseMismatch => 'Passphrases do not match';
  String get passphraseWarning =>
      'If you forget this passphrase, the backup cannot be recovered. Write it down.';
  String get exportSuccess => 'Backup saved to';
  String get importConfirmTitle => 'Replace All Data?';
  String get importConfirmMessage =>
      'This will replace ALL current data. This action cannot be undone.';
  String get importSuccess => 'Data restored successfully';
  String get importWrongPassphrase =>
      'Incorrect passphrase or corrupted backup file';
  String get importVersionTooNew =>
      'This backup was created by a newer version of the app. Please update.';
  String get importCorrupted =>
      'The backup file is corrupted and cannot be restored';
  String get deleteBackupConfirm => 'Delete this backup?';
  String get noBackupsFound => 'No backups found';
  String get noBackupsFoundDetailed =>
      'No backups found. Export your first backup to keep your data safe.';
  String get recentBackups => 'Recent Backups';
  String get chooseDestination => 'Choose backup folder';
  String get selectBackupFile => 'Select Backup File';
  String get deleteSuccess => 'Backup deleted';
  String get exportInProgress => 'Exporting backup...';
  String get importInProgress => 'Restoring backup...';
}

class _SettingsStrings {
  const _SettingsStrings();

  String get label => 'Settings';
  String get appearance => 'Appearance';
  String get themeMode => 'Theme mode';
  String get followSystem => 'System';
  String get light => 'Light';
  String get dark => 'Dark';
  String get shortcuts => 'Shortcuts';
  String get aboutApp => 'About this app';
  String get permissions => 'Permissions';
  String get offlineTitle => 'Offline and private';
  String get offlineBody =>
      'This app works fully offline. Tasks, backups, and statistics stay on this device unless you export a local backup file.';
}

class _PermissionsStrings {
  const _PermissionsStrings();

  String get label => 'Permissions';
  String get summary =>
      'This app requires no explicit permissions. All access is implicit and confined to app-private directories or user-initiated actions.';
  String get implicit => 'Implicit';
  String get explicit => 'Explicit';
  String get explicitNone =>
      'This app declares zero permissions in the Android manifest for release builds. No runtime permission dialogs are shown.';
  String get storageTitle => 'App-private storage';
  String get storageBody =>
      'The SQLite database is stored in the app-private directory. No storage permission is needed because Android grants every app access to its own data folder.';
  String get filePickerTitle => 'File picker access';
  String get filePickerBody =>
      'Backup export and import use the system file picker dialog. Access is granted per file by the user through the picker and requires no persistent permission.';
  String get systemClockTitle => 'System clock';
  String get systemClockBody =>
      'Used for time tracking, timestamps, and date calculations. Reading the system clock requires no permission.';
  String get textProcessingTitle => 'Text processing';
  String get textProcessingBody =>
      'Declared as an intent query so the system can handle text selection actions. This is a standard Flutter framework registration and requires no permission.';
}

class _AboutStrings {
  const _AboutStrings();

  String get label => 'About';
  String get headline => 'Private daily planning';
  String get summary =>
      'SreerajP ToDo is an offline-first daily task list and time tracker designed to keep your data on this device.';
  String get localOnlyTitle => 'Local-only data';
  String get localOnlyBody =>
      'Tasks, recurrence rules, backups, and statistics stay on local storage. No cloud sync or telemetry is used.';
  String get backupTitle => 'Portable encrypted backups';
  String get backupBody =>
      'Backup export creates encrypted files that you can store anywhere you choose and restore later with your passphrase.';
  String get unicodeTitle => 'Unicode-first input';
  String get unicodeBody =>
      'Titles and descriptions accept full Unicode text, including RTL scripts, emoji, and composed characters.';
  String get navigationTitle => 'Built for daily flow';
  String get navigationBody =>
      'Daily planning, statistics, recurring rules, and backups are available from the main navigation with no account setup.';
  String get author => 'Author';
  String get authorName => 'Sreeraj P';
  String get aiAssisted => 'AI assisted by';
  String get aiModels => 'Claude 4.6 & GPT 5.4';
  String get buildDate => 'Build date';
  String get madeWithLoveIn => 'Made with \u2764 in India';
}

class _StatisticsStrings {
  const _StatisticsStrings();

  String get dailyOverview => 'Daily Overview';
  String get perItemOverview => 'Per-Item Overview';
  String get chooseTask => 'Choose task';
  String get last7Days => 'Last 7 days';
  String get last30Days => 'Last 30 days';
  String get allTime => 'All time';
  String get customRange => 'Custom range';
  String get refresh => 'Refresh statistics';
  String get totalTodos => 'Total todos';
  String get total => 'Total';
  String get date => 'Date';
  String get title => 'Title';
  String get appearances => 'Appearances';
  String get averageCompletedPerDay => 'Average completed/day';
  String get averageTimePerDay => 'Average time/day';
  String get productiveTime => 'Productive time';
  String get droppedTime => 'Dropped time';
  String get searchHint => 'Search task titles';
  String get noDailyStats => 'No statistics available for this date range';
  String get noPerItemStats => 'No tracked tasks match the current filter';
  String get selectTaskToViewHistory =>
      'Select a task to view its time history';
  String get noHistoryForTitle => 'No time history recorded for this task';
  String get minutes => 'Minutes';
  String get selectStartDate => 'Select start date';
  String get selectEndDate => 'Select end date';
  String get showHistory => 'Show history';

  String pageOf(int currentPage, int totalPages) =>
      'Page $currentPage of $totalPages';

  String historyFor(String title) => 'Time history: $title';
}

class _ErrorStrings {
  const _ErrorStrings();

  String get dayLocked => 'Cannot modify tasks from past dates.';
  String get completedLocked =>
      'Cannot add time segments to a completed or dropped task.';
  String get duplicateTitle =>
      'A task with this title already exists for this date.';
  String get segmentAlreadyRunning =>
      'A time segment is already running for this task.';
  String get todoNotFound => 'Task not found.';
  String get backupVersionTooNew =>
      'This backup was created by a newer version of the app. Please update.';
  String get backupCorrupted =>
      'The backup file is corrupted and cannot be restored.';
  String get portTargetMustBeFuture =>
      'Port target date must be tomorrow or later.';
  String get generic => 'An unexpected error occurred.';
  String get retryableGeneric => 'Something went wrong. Tap to retry.';
  String get intervalMustBeAtLeastOne => 'Enter 1 or more.';
}
