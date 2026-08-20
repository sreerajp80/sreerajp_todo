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
  String get segmentNoteLabel => 'Note';

  @override
  String get segmentNoteHint => 'What did you work on?';

  @override
  String get editSegmentNote => 'Edit note';

  @override
  String matchedInNote(String note) {
    return 'Note: $note';
  }

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
  String get backupHealthDashboardTitle => 'Backup Health Dashboard';

  @override
  String get backupHealthStatusHealthy => 'Healthy';

  @override
  String get backupHealthStatusWarning => 'Needs Attention';

  @override
  String get backupHealthStatusNoBackups => 'No Backups Created';

  @override
  String get backupHealthLogsTitle => 'Execution Diagnostic Logs';

  @override
  String get backupHealthTriggerManual => 'Manual';

  @override
  String get backupHealthTriggerScheduled => 'Scheduled';

  @override
  String get backupHealthStatusSuccess => 'Success';

  @override
  String get backupHealthStatusFailed => 'Failed';

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
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System Default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageMalayalam => 'Malayalam';

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
  String get settingsAppearanceSubtitle =>
      'Theme mode, typography, and accent color';

  @override
  String get settingsLanguageSubtitle =>
      'Choose the language used across the app';

  @override
  String get settingsBackupSubtitle =>
      'Export or import an encrypted backup file';

  @override
  String get settingsFeatures => 'Features';

  @override
  String get settingsFeaturesSubtitle =>
      'Explore all features of SreerajP ToDo';

  @override
  String get settingsHelp => 'Help & User Guides';

  @override
  String get settingsHelpSubtitle =>
      'Guides on time tracking, sync, backups, and FAQs';

  @override
  String get settingsAboutSubtitle => 'Version, credits, and app details';

  @override
  String get settingsTimeTracking => 'Time tracking';

  @override
  String get settingsTimeTrackingSubtitle =>
      'Auto-stop, pause, Pomodoro, and how time is shown';

  @override
  String get trackingAutoStop => 'Auto-stop the timer';

  @override
  String get trackingAutoStopSubtitle => 'Stop a timer that was left running';

  @override
  String get trackingAutoStopOff => 'Never';

  @override
  String get trackingAutoStopOffDetail =>
      'A running timer keeps going until you stop it.';

  @override
  String get trackingAutoStopMidnight => 'At midnight';

  @override
  String get trackingAutoStopMidnightDetail =>
      'Stops at the end of the day so tracked time is not lost.';

  @override
  String get trackingAutoStopCustom => 'At a set time';

  @override
  String get trackingAutoStopCustomDetail =>
      'Stops at the time you pick below.';

  @override
  String get trackingAutoStopTime => 'Stop at';

  @override
  String get trackingAutoStopNote =>
      'While the app is closed the timer cannot be stopped at that exact moment. It is corrected the next time you open the app.';

  @override
  String get trackingAutoStopped => 'Timer stopped automatically';

  @override
  String get trackingTimerBehaviour => 'Timer behaviour';

  @override
  String get trackingTimerBehaviourSubtitle =>
      'One timer at a time, pause, screen, short segments';

  @override
  String get trackingSingleTimer => 'Only one timer at a time';

  @override
  String get trackingSingleTimerDetail =>
      'Starting a timer stops any timer running on another task.';

  @override
  String trackingStoppedOtherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stopped $count other running timers',
      one: 'Stopped $count other running timer',
    );
    return '$_temp0';
  }

  @override
  String get trackingAutoPause => 'Pause when the app is closed';

  @override
  String get trackingAutoPauseDetail =>
      'Leaving the app pauses a running timer. Time already tracked is kept.';

  @override
  String get trackingKeepScreenAwake => 'Keep the screen on';

  @override
  String get trackingKeepScreenAwakeDetail =>
      'The screen stays on while a timer runs. Android only.';

  @override
  String get trackingMinimumLength => 'Shortest segment to keep';

  @override
  String get trackingMinimumLengthDetail =>
      'A timer you stop sooner than this is thrown away, so a mis-tap does not clutter your log. Manual entries are never touched.';

  @override
  String get trackingMinimumOff => 'Keep everything';

  @override
  String get trackingMinimum10s => 'Under 10 seconds';

  @override
  String get trackingMinimum30s => 'Under 30 seconds';

  @override
  String get trackingMinimum1m => 'Under 1 minute';

  @override
  String get trackingMinimum5m => 'Under 5 minutes';

  @override
  String get trackingSegmentDiscarded =>
      'Segment was too short and was not saved';

  @override
  String get trackingPomodoro => 'Pomodoro';

  @override
  String get trackingPomodoroSubtitle => 'Focus blocks and breaks';

  @override
  String get trackingPomodoroEnabled => 'Use focus blocks';

  @override
  String get trackingPomodoroEnabledDetail =>
      'A running timer becomes a work block that ends on its own.';

  @override
  String get trackingPomodoroWork => 'Work block';

  @override
  String get trackingPomodoroShortBreak => 'Short break';

  @override
  String get trackingPomodoroLongBreak => 'Long break';

  @override
  String get trackingPomodoroBlocks => 'Long break after';

  @override
  String get trackingPomodoroAutoStart => 'Start the next block on its own';

  @override
  String get trackingPomodoroAutoStartDetail =>
      'When off, each block waits for you to tap start.';

  @override
  String get trackingPomodoroNote =>
      'The alert only sounds while the app is open. This app sends no notifications, so a block that ends in the background makes no sound. The time is still counted correctly.';

  @override
  String trackingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '$count minute',
    );
    return '$_temp0';
  }

  @override
  String trackingBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count work blocks',
      one: '$count work block',
    );
    return '$_temp0';
  }

  @override
  String get trackingBlockWork => 'Focus';

  @override
  String get trackingBlockShortBreak => 'Short break';

  @override
  String get trackingBlockLongBreak => 'Long break';

  @override
  String get trackingBlockDone => 'Block finished';

  @override
  String get trackingStartNextBlock => 'Start next block';

  @override
  String get trackingTimeDisplay => 'Time display';

  @override
  String get trackingTimeDisplaySubtitle =>
      'Rounding, format, and manual entry default';

  @override
  String get trackingRounding => 'Rounding in reports';

  @override
  String get trackingRoundingDetail =>
      'Changes only what is shown. Your saved times are never altered.';

  @override
  String get trackingRoundingOff => 'Exact';

  @override
  String get trackingRounding1m => 'Nearest minute';

  @override
  String get trackingRounding5m => 'Nearest 5 minutes';

  @override
  String get trackingRounding15m => 'Nearest 15 minutes';

  @override
  String get trackingFormat => 'How times are written';

  @override
  String get trackingFormatHhmmss => 'Hours, minutes, seconds';

  @override
  String get trackingFormatHhmm => 'Hours and minutes';

  @override
  String get trackingFormatDecimal => 'Decimal hours';

  @override
  String get trackingFormatNote => 'A running timer always shows seconds.';

  @override
  String get trackingManualDefault => 'Manual entry length';

  @override
  String get trackingManualDefaultDetail =>
      'Picking a start time fills the end time this far ahead. You can still change it.';

  @override
  String get trackingManual15m => '15 minutes';

  @override
  String get trackingManual30m => '30 minutes';

  @override
  String get trackingManual1h => '1 hour';

  @override
  String get trackingManual2h => '2 hours';

  @override
  String get pauseTimer => 'Pause timer';

  @override
  String get resumeTimer => 'Resume timer';

  @override
  String get timerPaused => 'Paused';

  @override
  String get settingsPermissionsSubtitle =>
      'What this app can and cannot access';

  @override
  String get appearanceThemeModeSubtitle =>
      'Choose Light, Dark, or follow the system';

  @override
  String get appearanceTypography => 'Typography & Text Size';

  @override
  String get appearanceTypographySubtitle => 'App font family and text size';

  @override
  String get appearanceAccentColor => 'Accent Color';

  @override
  String get appearanceAccentColorSubtitle =>
      'Presets, color wheel, and live preview';

  @override
  String get themeModeHelp =>
      'System mode follows the dark mode setting of your device.';

  @override
  String get typographyFontLabel => 'Font';

  @override
  String get typographyTextSizeLabel => 'Text size';

  @override
  String get typographySampleLatin => 'The quick brown fox 0123';

  @override
  String get typographySampleMalayalam => 'മലയാളം സുന്ദരമാണ്';

  @override
  String get fontSystemDefault => 'System default';

  @override
  String get fontManjari => 'Manjari';

  @override
  String get fontAnekMalayalam => 'Anek Malayalam';

  @override
  String get fontNotoSansMalayalam => 'Noto Sans Malayalam';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeLarger => 'Larger';

  @override
  String get accentLivePreview => 'Live preview';

  @override
  String get accentPresets => 'Presets';

  @override
  String get accentCustomWheel => 'Custom color wheel';

  @override
  String get accentSampleText => 'Sample text';

  @override
  String get accentAppliesToLight =>
      'This color is used while the app is in light mode.';

  @override
  String get accentAppliesToDark =>
      'This color is used while the app is in dark mode.';

  @override
  String get accentResetLight => 'Reset light mode color';

  @override
  String get accentResetDark => 'Reset dark mode color';

  @override
  String get accentContrastNote =>
      'Text contrast is adjusted automatically for readability.';

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
  String get aboutBuildNumber => 'Build';

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

  @override
  String get subTasks => 'Sub-tasks';

  @override
  String get addSubTask => 'Add sub-task';

  @override
  String get blockedBy => 'Blocked by';

  @override
  String get prerequisiteTasks => 'Prerequisite Tasks';

  @override
  String get blockedWarning =>
      'Warning: Task is blocked by pending prerequisites';

  @override
  String get morningIntention => 'Morning Intention';

  @override
  String get eveningReflection => 'Evening Reflection';

  @override
  String get eveningReflectionTitle => 'Evening Reflection Ritual';

  @override
  String get reflectionSummaryTitle => 'Today\'s Productivity Summary';

  @override
  String get completedTime => 'Completed Time';

  @override
  String get droppedTime => 'Dropped Time';

  @override
  String get completionRatio => 'Completion Ratio';

  @override
  String get reflectionNoteHint => 'Write a brief reflection on your day...';

  @override
  String get reflectionSaved => 'Daily reflection saved.';

  @override
  String get cycleIntention => 'Cycle Intention';

  @override
  String get startReflection => 'Start Reflection';

  @override
  String get mindfulFocusRules => 'Daily Focus Rules';

  @override
  String get defaultIntention1 =>
      'Focus on single-tasking today; handle duty without extra emotional noise.';

  @override
  String get defaultIntention2 =>
      'Prioritize steady progress over perfection; remain calm and persistent.';

  @override
  String get defaultIntention3 =>
      'Accept changing circumstances with composure; single-thread your effort.';

  @override
  String get defaultIntention4 =>
      'Direct your attention to what is within your control; release the rest.';

  @override
  String get defaultIntention5 =>
      'Complete each segment with full presence before stepping to the next.';

  @override
  String get dataHandoffTitle => 'Data Handoff (JSON & MD)';

  @override
  String get actionChange => 'Change';

  @override
  String get dataHandoffHeader => 'JSON & Markdown Data Handoff';

  @override
  String get dataHandoffSubtitle =>
      'Ingest and export task lists, subtask checklists, and timecard summaries fully offline.';

  @override
  String get exportJsonLabel => 'Export JSON Data Payload';

  @override
  String get exportJsonDesc =>
      'Exports tasks, subtasks, recurrence rules, time segments, and Markdown notes to a structured JSON file.';

  @override
  String get exportMarkdownLabel => 'Export Markdown Checklist';

  @override
  String get exportMarkdownDesc =>
      'Generates a clean Markdown checklist file (- [ ] / - [x]) and timecard summary.';

  @override
  String get importFileLabel => 'Import JSON / Markdown File';

  @override
  String get importFileDesc =>
      'Pick a .json or .md file from device storage to convert and merge into tasks.';

  @override
  String get pasteMarkdownLabel => 'Paste Raw Markdown Text';

  @override
  String get pasteMarkdownDesc =>
      'Paste raw Markdown text containing - [ ] and - [x] checklist items to parse.';

  @override
  String get targetDateLabel => 'Target Date for Data Handoff';

  @override
  String get markdownImportTitle => 'Paste Markdown Checklist Text';

  @override
  String get parseMarkdownPreview => 'Parsed Tasks Preview';

  @override
  String get importSuccessMsg => 'Successfully imported tasks.';

  @override
  String get exportSuccessMsg => 'Export saved successfully to file.';

  @override
  String get wifiSyncTitle => 'Local P2P Wi-Fi Sync';

  @override
  String get airQrShareTitle => 'AirQR Share Stream';

  @override
  String get airQrScanTitle => 'AirQR Scan Camera';

  @override
  String get moreOptions => 'More options';

  @override
  String get settingsTaskDefaults => 'Task defaults';

  @override
  String get settingsTaskDefaultsSubtitle =>
      'New task values, day list order, confirmations and carry-over';

  @override
  String get defaultsNewTask => 'New task';

  @override
  String get defaultsNewTaskSubtitle =>
      'Status, priority and target time a new task starts with';

  @override
  String get defaultsDayList => 'Day list';

  @override
  String get defaultsDayListSubtitle =>
      'Order, and whether finished tasks are shown';

  @override
  String get defaultsTaskActions => 'Task actions';

  @override
  String get defaultsTaskActionsSubtitle =>
      'Confirmations and carrying tasks over to a new day';

  @override
  String get defaultsAutocomplete => 'Autocomplete';

  @override
  String get defaultsAutocompleteSubtitle => 'Title suggestions while you type';

  @override
  String get defaultsStatusTitle => 'Default status';

  @override
  String get defaultsStatusSubtitle => 'The status a new task starts in.';

  @override
  String get defaultsStatusPendingDetail =>
      'The normal choice. The task waits until you start it.';

  @override
  String get defaultsStatusWorkingDetail =>
      'The task opens as working. No timer is started.';

  @override
  String get defaultsPriorityTitle => 'Default priority';

  @override
  String get defaultsPrioritySubtitle => 'The priority a new task starts with.';

  @override
  String get defaultsTargetTitle => 'Default target time';

  @override
  String get defaultsTargetSubtitle =>
      'How long a new task is expected to take. You can change it on any task.';

  @override
  String get defaultsTargetNone => 'No target';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get targetTimeLabel => 'Target time';

  @override
  String get targetTimeHint => 'Leave both at zero for no target.';

  @override
  String get targetHoursLabel => 'Hours';

  @override
  String get targetMinutesLabel => 'Minutes';

  @override
  String targetProgressLabel(String target, String tracked) {
    return '$tracked of $target';
  }

  @override
  String targetOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String get defaultsSortTitle => 'Default order';

  @override
  String get defaultsSortSubtitle => 'The order the day list opens in.';

  @override
  String get defaultsRememberSort => 'Remember the last order I pick';

  @override
  String get defaultsRememberSortDetail =>
      'Changing the order from the day list also saves it as the default.';

  @override
  String get defaultsShowCompleted => 'Show completed tasks';

  @override
  String get defaultsShowCompletedDetail =>
      'Turn off to hide tasks you have finished.';

  @override
  String get defaultsShowDropped => 'Show dropped tasks';

  @override
  String get defaultsShowDroppedDetail =>
      'Turn off to hide tasks you have given up.';

  @override
  String get defaultsSinkFinished => 'Move finished tasks to the bottom';

  @override
  String get defaultsSinkFinishedDetail =>
      'Completed, dropped and ported tasks sit below the rest. Drag to reorder then works only among unfinished tasks.';

  @override
  String hiddenTasksCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString finished tasks hidden',
      one: '1 finished task hidden',
    );
    return '$_temp0';
  }

  @override
  String get showHiddenTasks => 'Show';

  @override
  String get defaultsConfirmComplete => 'Ask before completing';

  @override
  String get defaultsConfirmCompleteDetail =>
      'Show a short question before a task is marked complete.';

  @override
  String get defaultsConfirmDrop => 'Ask before dropping';

  @override
  String get defaultsConfirmDropDetail =>
      'Show a short question before a task is dropped.';

  @override
  String get confirmCompleteTitle => 'Mark as complete?';

  @override
  String get confirmCompleteBody =>
      'This task will be marked as complete. Any running timer is stopped.';

  @override
  String get defaultsCarryOver => 'Ask to carry over unfinished tasks';

  @override
  String get defaultsCarryOverDetail =>
      'The first time you open a new day, offer to copy unfinished tasks forward.';

  @override
  String get defaultsCarryOverLookBackTitle => 'How far back to look';

  @override
  String get defaultsCarryOverPreviousDay => 'Previous day only';

  @override
  String get defaultsCarryOverLastSevenDays => 'Last 7 days';

  @override
  String get carryOverTitle => 'Carry over unfinished tasks';

  @override
  String get carryOverBody =>
      'These tasks were not finished. Pick the ones to copy to today.';

  @override
  String get carryOverAction => 'Carry over';

  @override
  String get carryOverNotNow => 'Not now';

  @override
  String get carryOverNeverAsk => 'Do not ask again';

  @override
  String get carryOverSelectAll => 'Select all';

  @override
  String get carryOverClearAll => 'Clear all';

  @override
  String carryOverDone(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tasks carried over',
      one: '1 task carried over',
    );
    return '$_temp0';
  }

  @override
  String carryOverSkipped(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tasks skipped, they already exist today',
      one: '1 task skipped, it already exists today',
    );
    return '$_temp0';
  }

  @override
  String get defaultsAutocompleteEnabled => 'Suggest titles while typing';

  @override
  String get defaultsAutocompleteEnabledDetail =>
      'Turn off to stop reading past titles as you type.';

  @override
  String get defaultsSuggestionCountTitle => 'How many suggestions';

  @override
  String suggestionCountValue(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString suggestions';
  }

  @override
  String get sortPriorityHigh => 'Priority (high first)';

  @override
  String get settingsDateTime => 'Date & time';

  @override
  String get settingsDateTimeSubtitle =>
      'Week start, clock, date format, day start, working days';

  @override
  String get dateTimeWeekStart => 'First day of week';

  @override
  String get dateTimeWeekStartSubtitle => 'Which day the calendar starts on';

  @override
  String get dateTimeClock => 'Clock';

  @override
  String get dateTimeClockSubtitle => '12-hour or 24-hour times';

  @override
  String get dateTimeDateFormat => 'Date format';

  @override
  String get dateTimeDateFormatSubtitle => 'How dates are written';

  @override
  String get dateTimeDayStart => 'Day start';

  @override
  String get dateTimeDayStartSubtitle => 'When a new day begins for you';

  @override
  String get dateTimeWorkingDays => 'Working days';

  @override
  String get dateTimeWorkingDaysSubtitle => 'Days counted in statistics';

  @override
  String get weekStartTitle => 'First day of week';

  @override
  String get weekStartSubtitle => 'Used by the calendar in the day list.';

  @override
  String get weekStartSystem => 'Follow the device';

  @override
  String get clockFormatTitle => 'Clock';

  @override
  String get clockFormatSubtitle => 'Used everywhere a time of day is shown.';

  @override
  String get clockFormatSystem => 'Follow the device';

  @override
  String get clockFormat12 => '12-hour';

  @override
  String get clockFormat24 => '24-hour';

  @override
  String get dateFormatTitle => 'Date format';

  @override
  String get dateFormatSubtitle => 'Used everywhere a date is shown.';

  @override
  String get dateFormatSystem => 'Follow the device (long)';

  @override
  String get dateFormatSystemShort => 'Follow the device (short)';

  @override
  String get dateFormatDayMonthYear => 'Day/Month/Year';

  @override
  String get dateFormatMonthDayYear => 'Month/Day/Year';

  @override
  String get dateFormatDayMonthNameYear => 'Day Month Year';

  @override
  String get dateFormatIso => 'Year-Month-Day';

  @override
  String get dayStartTitle => 'A new day begins at';

  @override
  String get dayStartSubtitle =>
      'Pick a later hour if you often work past midnight.';

  @override
  String get dayStartMidnight => 'Midnight (normal)';

  @override
  String get dayStartExplainTitle => 'What this changes';

  @override
  String get dayStartExplainBody =>
      'With a later day start, the hours after midnight still count as the day before. Your task list, the day lock and your time totals all follow this. Nothing already saved is moved or changed.';

  @override
  String dayStartCurrentDay(String date) {
    return 'Right now the app treats today as $date.';
  }

  @override
  String get workingDaysTitle => 'Working days';

  @override
  String get workingDaysSubtitle =>
      'Statistics use only these days when working out averages.';

  @override
  String get workingDaysReset => 'Reset to Monday to Friday';

  @override
  String get workingDaysNoneWarning =>
      'No working days are picked, so averages fall back to all seven days.';

  @override
  String get settingsSecurity => 'Security & privacy';

  @override
  String get settingsSecuritySubtitle =>
      'App lock, auto-lock, screen privacy, database key';

  @override
  String get securityAppLock => 'App lock';

  @override
  String get securityAppLockSubtitle =>
      'Ask for a PIN, password or your phone lock';

  @override
  String get securityAutoLock => 'Auto-lock';

  @override
  String get securityAutoLockSubtitle =>
      'How long the app may stay open in the background';

  @override
  String get securityDatabaseKey => 'Database key';

  @override
  String get securityDatabaseKeySubtitle =>
      'Give your data a brand new encryption key';

  @override
  String get securityScreenPrivacy => 'Screen privacy';

  @override
  String get securitySecureScreen => 'Hide the app in recent apps';

  @override
  String get securitySecureScreenDetail =>
      'The app preview stays blank when you switch apps, and screenshots are blocked. Android only.';

  @override
  String get securitySecureScreenUnsupported =>
      'This is an Android setting. It does nothing on this device.';

  @override
  String get securityNotificationsNote =>
      'The app sends no notifications at all, so there are no task titles to hide there. The setting above covers the recent-apps preview instead.';

  @override
  String get appLockModeTitle => 'How to unlock';

  @override
  String get appLockModeSubtitle => 'Asked for when you open the app.';

  @override
  String get appLockOff => 'No lock';

  @override
  String get appLockPin => 'PIN';

  @override
  String get appLockPassword => 'Password';

  @override
  String get appLockDeviceCredential => 'Phone screen lock';

  @override
  String get appLockDeviceCredentialDetail =>
      'Uses your fingerprint, face or phone PIN.';

  @override
  String get appLockDeviceUnavailable =>
      'Set up a screen lock on your phone first.';

  @override
  String get appLockSetPin => 'Set a PIN';

  @override
  String get appLockSetPassword => 'Set a password';

  @override
  String get appLockNewSecret => 'New';

  @override
  String get appLockConfirmSecret => 'Type it again';

  @override
  String get appLockChange => 'Change';

  @override
  String get appLockSaved => 'App lock is on.';

  @override
  String get appLockRemoved => 'App lock is off.';

  @override
  String get appLockWarningTitle => 'There is no way back in';

  @override
  String get appLockWarningBody =>
      'Nothing about your PIN or password leaves this device, and nothing can recover it. If you forget it, the only way back into the app is to reinstall it, which erases your data. Keep a backup.';

  @override
  String get appLockErrorEmpty => 'Type something first.';

  @override
  String get appLockErrorNotDigits => 'A PIN can only hold digits.';

  @override
  String get appLockErrorPinTooShort => 'A PIN needs at least 4 digits.';

  @override
  String get appLockErrorPinTooLong => 'A PIN can hold at most 8 digits.';

  @override
  String get appLockErrorPasswordTooShort =>
      'A password needs at least 6 characters.';

  @override
  String get appLockErrorMismatch => 'The two entries do not match.';

  @override
  String get autoLockTitle => 'Lock again after';

  @override
  String get autoLockSubtitle => 'Counted from the moment you leave the app.';

  @override
  String get autoLockImmediately => 'At once';

  @override
  String get autoLock30Seconds => '30 seconds';

  @override
  String get autoLock1Minute => '1 minute';

  @override
  String get autoLock5Minutes => '5 minutes';

  @override
  String get autoLock15Minutes => '15 minutes';

  @override
  String get autoLockNever => 'Only when the app restarts';

  @override
  String get autoLockNeedsLock => 'Turn the app lock on first.';

  @override
  String get databaseKeyTitle => 'New database key';

  @override
  String get databaseKeyBody =>
      'Your data is stored encrypted with a key held by this device. Rotating it writes the whole database again under a brand new key.';

  @override
  String get databaseKeyBackupFirst =>
      'Take a backup before you start. If anything goes wrong part way, the backup is the only way back.';

  @override
  String get databaseKeyOldBackups =>
      'Backup files are not affected. They keep the passphrase you exported them with.';

  @override
  String get databaseKeyRotate => 'Rotate the key now';

  @override
  String get databaseKeyConfirmTitle => 'Rotate the database key?';

  @override
  String get databaseKeyConfirmBody =>
      'This rewrites your whole database under a new key. Do not close the app while it runs.';

  @override
  String get databaseKeyWorking => 'Rotating the key. Please wait.';

  @override
  String get databaseKeyDone => 'The database has a new key.';

  @override
  String get databaseKeyFailed =>
      'The key was not changed. Your data is untouched and still opens with the old key.';

  @override
  String get lockScreenTitle => 'Locked';

  @override
  String get lockScreenEnterPin => 'Enter your PIN';

  @override
  String get lockScreenEnterPassword => 'Enter your password';

  @override
  String get lockScreenUnlock => 'Unlock';

  @override
  String get lockScreenWrong => 'That did not match. Try again.';

  @override
  String lockScreenWait(int seconds) {
    return 'Too many tries. Wait $seconds seconds.';
  }

  @override
  String get lockScreenUseDeviceLock => 'Use my phone lock';

  @override
  String get lockScreenDevicePrompt => 'Unlock SreerajP ToDo';

  @override
  String get lockScreenDeviceDescription =>
      'Confirm it is you to open your tasks.';

  @override
  String get lockScreenDeviceFailed => 'That did not open the app.';

  @override
  String get focusTitle => 'Focus';

  @override
  String get focusOpen => 'Open focus view';

  @override
  String get focusLeave => 'Leave focus';

  @override
  String get focusRunningNow => 'Running now';

  @override
  String get focusTotalTracked => 'Total tracked';

  @override
  String get focusSteps => 'Steps';

  @override
  String get focusNoSteps => 'This task has no steps.';

  @override
  String get focusNotRunning => 'The timer is not running.';

  @override
  String focusNextNudge(String time) {
    return 'Next nudge in $time';
  }

  @override
  String get focusNudgesOff => 'Nudges are off';

  @override
  String get trackingFocusMode => 'Focus mode';

  @override
  String get trackingFocusModeSubtitle =>
      'Full screen focus view and the nudge while a timer runs';

  @override
  String get trackingFocusPulse => 'Nudge while a timer runs';

  @override
  String get trackingFocusPulseOff => 'Off';

  @override
  String get trackingFocusPulseVibration => 'Vibration only';

  @override
  String get trackingFocusPulseSound => 'Sound only';

  @override
  String get trackingFocusPulseBoth => 'Vibration and sound';

  @override
  String get trackingFocusPulseEvery => 'Nudge every';

  @override
  String get trackingFocusView => 'Focus view';

  @override
  String get trackingFocusImmersive => 'Immersive full screen';

  @override
  String get trackingFocusImmersiveDetail =>
      'Hide the status bar while the Focus view is open.';

  @override
  String get trackingFocusNote =>
      'The nudge only works while the app is open. This app sends no notifications, so nothing sounds in the background. Your time is still counted correctly.';

  @override
  String get trackingFocusPomodoroNote =>
      'Focus blocks are on, so the nudge stays quiet. Pomodoro already sounds its own alert at the end of every block.';

  @override
  String get voiceSheetTitle => 'Voice task';

  @override
  String get voiceSheetOfflineNote =>
      'Everything is worked out on this phone. Nothing is recorded and nothing is sent anywhere.';

  @override
  String get voiceSheetFieldLabel => 'Say or type one sentence';

  @override
  String get voiceSheetExample =>
      'For example: Call the bank tomorrow at 10 am for 30 minutes';

  @override
  String get voiceLanguageEnglish => 'English';

  @override
  String get voiceLanguageMalayalam => 'Malayalam';

  @override
  String get voiceTapToSpeak => 'Tap to speak';

  @override
  String get voiceListening => 'Listening';

  @override
  String get voiceClear => 'Clear';

  @override
  String get voiceUnderstoodHeading => 'Understood as';

  @override
  String get voiceNoTitle => 'No title yet';

  @override
  String get voiceCreateTask => 'Create task';

  @override
  String get voiceDateMovedToToday =>
      'That day has already passed, so today is used instead.';

  @override
  String get voiceErrorPermission =>
      'The microphone was not allowed. You can still type the sentence.';

  @override
  String get voiceErrorNoMatch =>
      'Nothing was heard. Try again, or type the sentence.';

  @override
  String get voiceErrorNoOfflineLanguage =>
      'This phone has no offline language pack for that language. Install one in your phone settings, or type the sentence.';

  @override
  String get voiceErrorBusy => 'The recogniser is busy. Try again in a moment.';

  @override
  String get voiceErrorUnknown =>
      'The microphone could not be used. You can still type the sentence.';

  @override
  String get voiceUnavailableDevice =>
      'This device has no voice input. Type the sentence instead.';

  @override
  String get voiceUnavailableNoRecogniser =>
      'No speech app was found on this device. Type the sentence instead.';

  @override
  String get voiceUnavailableNoOffline =>
      'This device cannot recognise speech without going online, so the microphone stays off. Type the sentence instead.';

  @override
  String get voiceUnavailableNoPermission =>
      'The microphone needs your permission. Tap the microphone to be asked.';

  @override
  String get voiceOpenTooltip => 'New task by voice';

  @override
  String get voiceInputSetting => 'Voice input';

  @override
  String get voiceInputSettingDetail =>
      'Show a microphone button on the day list. It uses the offline recogniser already on your phone, and asks for the microphone the first time you use it. The sentence is read on this device.';

  @override
  String get voiceInputTypingNote =>
      'The sentence is always read on this device, whether you speak it or type it. Voice input only adds the microphone.';

  @override
  String get permissionsCameraTitle => 'Camera';

  @override
  String get permissionsCameraBody =>
      'Asked for only when you scan a QR code to move data between your own devices. No photo is ever saved.';

  @override
  String get permissionsMicrophoneTitle => 'Microphone';

  @override
  String get permissionsMicrophoneBody =>
      'Asked for only after you turn Voice input on and tap the microphone. The phone recogniser is always asked for its offline engine, and listening is refused rather than going online. No audio is recorded or kept.';

  @override
  String get permissionsExplicitNote =>
      'These two are the only permissions this app asks for, and both are asked for only when you use the feature that needs them. The app declares no internet or network permission at all, so nothing it holds can leave this device on its own.';

  @override
  String voiceTimeNote(String time) {
    return 'At $time';
  }
}
