// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SreerajP ToDo';

  @override
  String get dailyList => 'My ToDos';

  @override
  String get createTodo => 'New Todo';

  @override
  String get editTodo => 'Edit Todo';

  @override
  String get timeSegments => 'Time Segments';

  @override
  String get copyTodos => 'Copy Todos';

  @override
  String get searchResults => 'Search Results';

  @override
  String get recurringTasks => 'Recurring Tasks';

  @override
  String get newRecurrence => 'New Recurrence Rule';

  @override
  String get editRecurrence => 'Edit Recurrence Rule';

  @override
  String get statistics => 'Statistics';

  @override
  String get titleHint => 'Enter task title';

  @override
  String get descriptionHint => 'Enter description (optional)';

  @override
  String get searchHint => 'Search todos...';

  @override
  String get noTodosForDay => 'No tasks for this day';

  @override
  String get noSearchResults => 'No results found';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get addFirstTask => 'Add your first task';

  @override
  String get noTasksTodayTitle => 'No tasks today';

  @override
  String get noTasksTodayMessage =>
      'Add your first task to start planning this day.';

  @override
  String get noTasksForPastDayMessage => 'No tasks were recorded for this day.';

  @override
  String get searchTasksTitle => 'Search your tasks';

  @override
  String get searchTasksMessage =>
      'Enter a title or description to search across days.';

  @override
  String get noStatisticsData => 'Start tracking tasks to see your statistics';

  @override
  String get noRecurringTasksDetailed =>
      'No recurring tasks. Create one to automate task creation.';

  @override
  String get noSegmentsRecordedDetailed =>
      'Track time or add a manual segment to see history here.';

  @override
  String get backupDirectory => 'Backup folder';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get openCalendar => 'Open calendar';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get toggleSelection => 'Toggle selection';

  @override
  String get openTaskActions => 'Open task actions';

  @override
  String get lockedTask => 'Locked task';

  @override
  String get manualSegmentShort => 'M';

  @override
  String get emptyValue => '—';

  @override
  String get day => 'Day';

  @override
  String get details => 'Details';

  @override
  String get taskStatus => 'Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusWorking => 'Working';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get statusPorted => 'Ported';

  @override
  String get completeAction => 'Complete';

  @override
  String get dropAction => 'Drop';

  @override
  String get confirmDrop => 'Drop this task?';

  @override
  String get confirmDropBody =>
      'This task will be marked as dropped. Time spent will be categorised as dropped time.';

  @override
  String get confirmPort => 'Port this task?';

  @override
  String get confirmPortBody => 'This task will be moved to the selected date.';

  @override
  String get confirmDelete => 'Delete this task?';

  @override
  String get confirmDeleteBody =>
      'This task and all its time segments will be permanently deleted.';

  @override
  String get confirmDeleteRecurring => 'Delete recurring task?';

  @override
  String get confirmDeleteRecurringBody =>
      'This task was created by a recurrence rule.';

  @override
  String get deleteOnlyThis => 'Delete only this one';

  @override
  String get deleteThisAndFuture => 'Delete this and future';

  @override
  String get deleteAllOccurrences => 'Delete all occurrences';

  @override
  String get allOccurrencesDeleted => 'All occurrences deleted';

  @override
  String get futureOccurrencesDeleted => 'This and future occurrences deleted';

  @override
  String get confirmBulkDrop => 'Drop selected tasks?';

  @override
  String get confirmBulkDropBody =>
      'All selected tasks will be marked as dropped.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get edit => 'Edit';

  @override
  String get port => 'Port';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String get selectTargetDate => 'Select target date';

  @override
  String get completeAll => 'Complete All';

  @override
  String get markDropped => 'Mark Dropped';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get copyToAnotherDay => 'Copy to another day';

  @override
  String get previous => 'Previous';

  @override
  String get copiedFrom => 'Copied from';

  @override
  String get portedTo => 'Ported to';

  @override
  String get noDescription => 'No description';

  @override
  String get startTimer => 'Start timer';

  @override
  String get stopTimer => 'Stop timer';

  @override
  String get timerRunning => 'Timer running';

  @override
  String get addManualSegment => 'Add Manual Segment';

  @override
  String get manualSegmentAdded => 'Manual segment added';

  @override
  String get segmentStart => 'Start time';

  @override
  String get segmentEnd => 'End time';

  @override
  String get segmentType => 'Type';

  @override
  String get segmentDuration => 'Duration';

  @override
  String get segmentAuto => 'Auto';

  @override
  String get segmentManual => 'Manual';

  @override
  String get segmentRunning => 'running...';

  @override
  String get segmentInterruptedTooltip => 'Auto-closed on app restart';

  @override
  String get totalTime => 'Total time';

  @override
  String get viewSegments => 'Time Segments';

  @override
  String get noSegments => 'No time segments recorded';

  @override
  String get startBeforeEnd => 'Start time must be before end time';

  @override
  String get segmentOverlap => 'This segment overlaps with an existing one';

  @override
  String get segmentMustBeSameDay =>
      'Both times must fall within the same calendar day';

  @override
  String get statusChangedTo => 'Status changed to';

  @override
  String get undoStatusChange => 'Status change undone';

  @override
  String get bulkStatusChanged => 'tasks updated';

  @override
  String get todoCreated => 'Task created';

  @override
  String get todoUpdated => 'Task updated';

  @override
  String get todoDeleted => 'Task deleted';

  @override
  String get todoPorted => 'Task ported';

  @override
  String get todosCopied => 'tasks copied';

  @override
  String get todosSkipped => 'skipped (duplicate title)';

  @override
  String get stepSelectItems => 'Select Items';

  @override
  String get stepPickDate => 'Pick Date';

  @override
  String get stepPreview => 'Preview';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get copyConfirm => 'Copy';

  @override
  String get noItemsSelected => 'Select at least one item';

  @override
  String get willBeSkipped => 'Already exists - will be skipped';

  @override
  String get itemsToCopy => 'items to copy';

  @override
  String get itemsWillBeSkipped => 'will be skipped';

  @override
  String get targetDate => 'Target Date';

  @override
  String get sourceDate => 'Source Date';

  @override
  String get selectDateFirst => 'Select a target date first';

  @override
  String get viewTodo => 'View Todo';

  @override
  String get readOnlyPastDate => 'Past date - read only';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String noSearchResultsForQuery(String query) {
    return 'No tasks found matching \'$query\'';
  }

  @override
  String statusSemantics(String status) {
    return 'Status: $status';
  }

  @override
  String totalTimeForTask(String title, String duration) {
    return 'Total time for $title: $duration';
  }

  @override
  String startTimerForTask(String title) {
    return 'Start timer for $title';
  }

  @override
  String stopTimerForTask(String title) {
    return 'Stop timer for $title';
  }

  @override
  String runningTimerForTask(String title) {
    return 'Timer running for $title';
  }

  @override
  String segmentSemantics(
    int index,
    String start,
    String end,
    String duration,
    String type,
  ) {
    return 'Segment $index. $start to $end. Duration $duration. Type $type.';
  }

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatNone => 'None';

  @override
  String get repeatConfigure => 'Repeat…';

  @override
  String get recurrenceCreated => 'Task and recurrence rule created';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get ends => 'Ends';

  @override
  String get endsNever => 'Never';

  @override
  String get endsOnDate => 'On date';

  @override
  String get endsAfterDays => 'For';

  @override
  String get frequency => 'Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get every => 'Every';

  @override
  String get days => 'days';

  @override
  String get weeks => 'weeks';

  @override
  String get months => 'months';

  @override
  String get years => 'years';

  @override
  String get daysOfWeek => 'Days of week';

  @override
  String get nextOccurrences => 'Next 5 occurrences';

  @override
  String get noUpcomingOccurrences => 'No upcoming occurrences';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get sortTodos => 'Sort';

  @override
  String get sortManual => 'Manual order';

  @override
  String get sortNameAZ => 'Name A→Z';

  @override
  String get sortNameZA => 'Name Z→A';

  @override
  String get sortCreatedOldest => 'Created (oldest first)';

  @override
  String get sortCreatedNewest => 'Created (newest first)';

  @override
  String get sortTimeMost => 'Time spent (most first)';

  @override
  String get sortTimeLeast => 'Time spent (least first)';

  @override
  String get sortByStatus => 'By status';

  @override
  String get backupLabel => 'Backup';

  @override
  String get backupExportTitle => 'Export Backup';

  @override
  String get backupImportTitle => 'Restore from Backup';

  @override
  String get backupPassphraseLabel => 'Backup Passphrase';

  @override
  String get backupPassphraseConfirmLabel => 'Confirm Passphrase';

  @override
  String get backupPassphraseMinLength =>
      'Passphrase must be at least 8 characters';

  @override
  String get backupPassphraseMismatch => 'Passphrases do not match';

  @override
  String get backupPassphraseWarning =>
      'If you forget this passphrase, the backup cannot be recovered. Write it down.';

  @override
  String get backupExportSuccess => 'Backup saved to';

  @override
  String get backupImportConfirmTitle => 'Replace All Data?';

  @override
  String get backupImportConfirmMessage =>
      'This will replace ALL current data. This action cannot be undone.';

  @override
  String get backupImportSuccess => 'Data restored successfully';

  @override
  String get backupImportWrongPassphrase =>
      'Incorrect passphrase or corrupted backup file';

  @override
  String get backupImportVersionTooNew =>
      'This backup was created by a newer version of the app. Please update.';

  @override
  String get backupImportCorrupted =>
      'The backup file is corrupted and cannot be restored';

  @override
  String get backupDeleteBackupConfirm => 'Delete this backup?';

  @override
  String get backupNoBackupsFound => 'No backups found';

  @override
  String get backupNoBackupsFoundDetailed =>
      'No backups found. Export your first backup to keep your data safe.';

  @override
  String get backupRecentBackups => 'Recent Backups';

  @override
  String get backupChooseDestination => 'Choose backup folder';

  @override
  String get backupSelectBackupFile => 'Select Backup File';

  @override
  String get backupDeleteSuccess => 'Backup deleted';

  @override
  String get backupExportInProgress => 'Exporting backup...';

  @override
  String get backupImportInProgress => 'Restoring backup...';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsFollowSystem => 'System';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsShortcuts => 'Shortcuts';

  @override
  String get settingsAboutApp => 'About this app';

  @override
  String get settingsPermissions => 'Permissions';

  @override
  String get settingsOfflineTitle => 'Offline and private';

  @override
  String get settingsOfflineBody =>
      'This app works fully offline. Tasks, backups, and statistics stay on this device unless you export a local backup file.';

  @override
  String get permissionsLabel => 'Permissions';

  @override
  String get permissionsSummary =>
      'This app requires no explicit permissions. All access is implicit and confined to app-private directories or user-initiated actions.';

  @override
  String get permissionsImplicit => 'Implicit';

  @override
  String get permissionsExplicit => 'Explicit';

  @override
  String get permissionsExplicitNone =>
      'This app declares zero permissions in the Android manifest for release builds. No runtime permission dialogs are shown.';

  @override
  String get permissionsStorageTitle => 'App-private storage';

  @override
  String get permissionsStorageBody =>
      'The SQLite database is stored in the app-private directory. No storage permission is needed because Android grants every app access to its own data folder.';

  @override
  String get permissionsFilePickerTitle => 'File picker access';

  @override
  String get permissionsFilePickerBody =>
      'Backup export and import use the system file picker dialog. Access is granted per file by the user through the picker and requires no persistent permission.';

  @override
  String get permissionsSystemClockTitle => 'System clock';

  @override
  String get permissionsSystemClockBody =>
      'Used for time tracking, timestamps, and date calculations. Reading the system clock requires no permission.';

  @override
  String get permissionsTextProcessingTitle => 'Text processing';

  @override
  String get permissionsTextProcessingBody =>
      'Declared as an intent query so the system can handle text selection actions. This is a standard Flutter framework registration and requires no permission.';

  @override
  String get aboutLabel => 'About';

  @override
  String get aboutHeadline => 'Private daily planning';

  @override
  String get aboutSummary =>
      'SreerajP ToDo is an offline-first daily task list and time tracker designed to keep your data on this device.';

  @override
  String get aboutLocalOnlyTitle => 'Local-only data';

  @override
  String get aboutLocalOnlyBody =>
      'Tasks, recurrence rules, backups, and statistics stay on local storage. No cloud sync or telemetry is used.';

  @override
  String get aboutBackupTitle => 'Portable encrypted backups';

  @override
  String get aboutBackupBody =>
      'Backup export creates encrypted files that you can store anywhere you choose and restore later with your passphrase.';

  @override
  String get aboutUnicodeTitle => 'Unicode-first input';

  @override
  String get aboutUnicodeBody =>
      'Titles and descriptions accept full Unicode text, including RTL scripts, emoji, and composed characters.';

  @override
  String get aboutNavigationTitle => 'Built for daily flow';

  @override
  String get aboutNavigationBody =>
      'Daily planning, statistics, recurring rules, and backups are available from the main navigation with no account setup.';

  @override
  String get aboutAuthor => 'Author';

  @override
  String get aboutAuthorName => 'Sreeraj P';

  @override
  String get aboutAiAssisted => 'AI assisted by';

  @override
  String get aboutAiModels => 'Claude 4.6 & GPT 5.4';

  @override
  String get aboutBuildDate => 'Build date';

  @override
  String get aboutAppVersion => 'Version';

  @override
  String get aboutMadeWithLoveIn => 'Made with ❤ in India';

  @override
  String get statsDailyOverview => 'Daily Overview';

  @override
  String get statsPerItemOverview => 'Per-Item Overview';

  @override
  String get statsChooseTask => 'Choose task';

  @override
  String get statsLast7Days => 'Last 7 days';

  @override
  String get statsLast30Days => 'Last 30 days';

  @override
  String get statsAllTime => 'All time';

  @override
  String get statsCustomRange => 'Custom range';

  @override
  String get statsRefresh => 'Refresh statistics';

  @override
  String get statsTotalTodos => 'Total todos';

  @override
  String get statsTotal => 'Total';

  @override
  String get statsDate => 'Date';

  @override
  String get statsTitle => 'Title';

  @override
  String get statsAppearances => 'Appearances';

  @override
  String get statsAverageCompletedPerDay => 'Average completed/day';

  @override
  String get statsAverageTimePerDay => 'Average time/day';

  @override
  String get statsProductiveTime => 'Productive time';

  @override
  String get statsDroppedTime => 'Dropped time';

  @override
  String get statsSearchHint => 'Search task titles';

  @override
  String get statsNoDailyStats => 'No statistics available for this date range';

  @override
  String get statsNoPerItemStats => 'No tracked tasks match the current filter';

  @override
  String get statsSelectTaskToViewHistory =>
      'Select a task to view its time history';

  @override
  String get statsNoHistoryForTitle => 'No time history recorded for this task';

  @override
  String get statsMinutes => 'Minutes';

  @override
  String get statsSelectStartDate => 'Select start date';

  @override
  String get statsSelectEndDate => 'Select end date';

  @override
  String get statsShowHistory => 'Show history';

  @override
  String statsPageOf(int currentPage, int totalPages) {
    return 'Page $currentPage of $totalPages';
  }

  @override
  String statsHistoryFor(String title) {
    return 'Time history: $title';
  }

  @override
  String get errorDayLocked => 'Cannot modify tasks from past dates.';

  @override
  String get errorCompletedLocked =>
      'Cannot add time segments to a completed or dropped task.';

  @override
  String get errorDuplicateTitle =>
      'A task with this title already exists for this date.';

  @override
  String get errorSegmentAlreadyRunning =>
      'A time segment is already running for this task.';

  @override
  String get errorTodoNotFound => 'Task not found.';

  @override
  String get errorBackupVersionTooNew =>
      'This backup was created by a newer version of the app. Please update.';

  @override
  String get errorBackupCorrupted =>
      'The backup file is corrupted and cannot be restored.';

  @override
  String get errorPortTargetMustBeFuture =>
      'Port target date must be tomorrow or later.';

  @override
  String get errorGeneric => 'An unexpected error occurred.';

  @override
  String get errorRetryableGeneric => 'Something went wrong. Tap to retry.';
}
