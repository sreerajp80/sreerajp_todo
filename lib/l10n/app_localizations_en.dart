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
  String get defaultsAutoCarryOver => 'Auto carry-over incomplete tasks';

  @override
  String get defaultsAutoCarryOverDetail =>
      'Automatically carry over unfinished tasks from earlier days into today without asking.';

  @override
  String autoCarryOverDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Automatically carried over $count tasks to today',
      one: 'Automatically carried over 1 task to today',
    );
    return '$_temp0';
  }

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

  @override
  String get settingsRitual => 'Ritual mode';

  @override
  String get settingsRitualSubtitle => 'A quiet, guided start to the day';

  @override
  String get ritualTitle => 'Ritual mode';

  @override
  String get ritualEnabled => 'Ritual mode';

  @override
  String get ritualEnabledDetail =>
      'Breathe, read one card, settle the day, then begin.';

  @override
  String get ritualOpenOnLaunch => 'Open on the first launch of a day';

  @override
  String get ritualOpenOnLaunchDetail =>
      'With this off, start it yourself from the day list.';

  @override
  String get ritualBreathSection => 'Breathing';

  @override
  String get ritualBreathTechnique => 'Rhythm';

  @override
  String get ritualBreathBox => 'Box breathing (4-4-4-4)';

  @override
  String get ritualBreathRelaxing => 'Relaxing breath (4-7-8)';

  @override
  String get ritualBreathCalm => 'Calm rhythm (4-4)';

  @override
  String get ritualBreathCyclesLabel => 'Breaths';

  @override
  String ritualBreathCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString breaths',
      one: '$countString breath',
    );
    return '$_temp0';
  }

  @override
  String get ritualHaptic => 'Gentle buzz at each change';

  @override
  String get ritualHapticDetail =>
      'A short tap when it is time to breathe in, hold or let go, so the eyes can stay closed.';

  @override
  String get ritualStepsSection => 'Steps';

  @override
  String get ritualCardStepSwitch => 'Show a reflection card';

  @override
  String get ritualCardStepDetail =>
      'One card from the Ritual Deck, chosen by when you last saw it.';

  @override
  String get ritualSettleStepSwitch => 'Settle the day';

  @override
  String get ritualSettleStepDetail =>
      'Carry over what is left from before, then pick the three tasks to lead today.';

  @override
  String get ritualEveningSection => 'Evening close';

  @override
  String get ritualEveningClose => 'Offer an evening reflection';

  @override
  String get ritualEveningCloseDetail =>
      'Once a day, later on, the day list offers to close the day.';

  @override
  String get ritualEveningFrom => 'Offer it from';

  @override
  String get ritualDeckSection => 'The deck';

  @override
  String get ritualBrowseDeck => 'Browse the Ritual Deck';

  @override
  String get ritualBrowseDeckDetail =>
      'All the cards, and when each one comes back.';

  @override
  String get ritualResetReviews => 'Reset card reviews';

  @override
  String get ritualResetReviewsDetail =>
      'Every card becomes new again. Your tasks are not touched.';

  @override
  String get ritualResetConfirmTitle => 'Reset card reviews?';

  @override
  String get ritualResetConfirmBody =>
      'The deck starts from the first card again. Nothing else changes.';

  @override
  String get ritualResetDone => 'Card reviews reset.';

  @override
  String get ritualRunNow => 'Run the ritual now';

  @override
  String get ritualStepBreathe => 'Breathe';

  @override
  String get ritualStepReflect => 'Reflect';

  @override
  String get ritualStepSettle => 'Settle';

  @override
  String get ritualStepBegin => 'Begin';

  @override
  String get ritualSkip => 'Skip ritual';

  @override
  String get ritualContinue => 'Continue';

  @override
  String get ritualBreathIn => 'Breathe in';

  @override
  String get ritualBreathHold => 'Hold';

  @override
  String get ritualBreathOut => 'Breathe out';

  @override
  String get ritualBreathRest => 'Rest';

  @override
  String get ritualBreathInHint => 'Slowly, through the nose.';

  @override
  String get ritualBreathHoldHint => 'Hold it gently at the top.';

  @override
  String get ritualBreathOutHint => 'Let it all go, without hurry.';

  @override
  String get ritualBreathRestHint => 'Stay in the quiet for a moment.';

  @override
  String ritualBreathProgress(int current, int total) {
    return 'Breath $current of $total';
  }

  @override
  String get ritualBreathFinished => 'That is enough.';

  @override
  String ritualCardProgress(int number, int total) {
    return 'Card $number of $total';
  }

  @override
  String get ritualCardAnother => 'Show another card';

  @override
  String get ritualMakeIntention => 'Make this today\'s intention';

  @override
  String get ritualIntentionSaved => 'Saved as today\'s intention.';

  @override
  String get ritualRateQuestion => 'When should this card come back?';

  @override
  String get ritualRateHard => 'Hard';

  @override
  String get ritualRateRevision => 'Revision';

  @override
  String get ritualRateEasy => 'Easy';

  @override
  String get ritualRateTomorrow => 'Tomorrow';

  @override
  String ritualRateInDays(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $daysString days',
      one: 'In $daysString day',
    );
    return '$_temp0';
  }

  @override
  String get ritualSettleCarryTitle => 'Left over from before';

  @override
  String get ritualSettleCarryEmpty =>
      'Nothing was left unfinished. A clean start.';

  @override
  String get ritualSettleFocusTitle => 'Today\'s three';

  @override
  String get ritualSettleFocusHint =>
      'Pick up to three tasks to lead the day. They move to high priority.';

  @override
  String get ritualSettleFocusEmpty =>
      'No tasks for today yet. You can add them after the ritual.';

  @override
  String get ritualSettleFocusLimit => 'Three is the limit. Untick one first.';

  @override
  String get ritualBeginTitle => 'Ready';

  @override
  String ritualBeginCarried(num count) {
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
  String ritualBeginFocused(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tasks in focus',
      one: '1 task in focus',
    );
    return '$_temp0';
  }

  @override
  String get ritualBeginNothing => 'Nothing changed. That is fine too.';

  @override
  String get ritualBeginAction => 'Begin the day';

  @override
  String get ritualDeckTitle => 'Ritual Deck';

  @override
  String get ritualDeckAll => 'All';

  @override
  String get ritualDeckDue => 'Due';

  @override
  String get ritualDeckUnseen => 'New';

  @override
  String ritualDeckSeenCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen $countString times',
      one: 'Seen once',
    );
    return '$_temp0';
  }

  @override
  String get ritualDeckEmpty => 'No cards in this theme.';

  @override
  String get ritualPastDayNote => 'The ritual runs for today only.';

  @override
  String get ritualThemeDharma => 'Dharma';

  @override
  String get ritualThemeKarma => 'Karma';

  @override
  String get ritualThemeBhakti => 'Bhakti';

  @override
  String get ritualThemeJnana => 'Jnana';

  @override
  String get ritualThemeYoga => 'Yoga';

  @override
  String get ritualThemeAhimsa => 'Ahimsa';

  @override
  String get ritualThemeSathya => 'Sathya';

  @override
  String get ritualThemeVairagya => 'Vairagya';

  @override
  String get ritualThemeSeva => 'Seva';

  @override
  String get ritualThemeShanti => 'Shanti';

  @override
  String get ritualCardSd01Title => 'Your Swadharma';

  @override
  String get ritualCardSd01Prompt =>
      'What is the unique duty or calling that only you can fulfil in this season of your life? How are you honouring it today?';

  @override
  String get ritualCardSd01Quote =>
      'It is better to perform one\'s own duty imperfectly than to perform another\'s duty perfectly.';

  @override
  String get ritualCardSd01QuoteAuthor => 'Bhagavad Gita 3.35';

  @override
  String get ritualCardSd02Title => 'Righteousness in the Small';

  @override
  String get ritualCardSd02Prompt =>
      'In what small, everyday action today can you choose what is right over what is easy or popular?';

  @override
  String get ritualCardSd02Quote =>
      'Dharma exists for the welfare of all beings. Hence, that by which the welfare of all living beings is sustained, that is Dharma.';

  @override
  String get ritualCardSd02QuoteAuthor => 'Mahabharata, Shanti Parva 109.10';

  @override
  String get ritualCardSd03Title => 'The Wheel of Dharma';

  @override
  String get ritualCardSd03Prompt =>
      'Reflect on one relationship or responsibility you hold. Are you nurturing it with integrity, or have you been neglecting its call?';

  @override
  String get ritualCardSd03Quote =>
      'When Dharma is protected, Dharma protects.';

  @override
  String get ritualCardSd03QuoteAuthor => 'Manusmriti 8.15';

  @override
  String get ritualCardSd04Title => 'The Eternal Order';

  @override
  String get ritualCardSd04Prompt =>
      'Where in nature — the rising sun, the changing seasons, the flowing river — do you see the rhythm of Rta (cosmic order), and how does it mirror your own life?';

  @override
  String get ritualCardSd04Quote =>
      'The rivers flow into the ocean but the ocean never overflows. Likewise, desires flow into the wise one, who remains ever at peace.';

  @override
  String get ritualCardSd04QuoteAuthor => 'Bhagavad Gita 2.70';

  @override
  String get ritualCardSd05Title => 'Dharma in Adversity';

  @override
  String get ritualCardSd05Prompt =>
      'When life tests you, what principle or value do you refuse to compromise? Why does it matter to you?';

  @override
  String get ritualCardSd05Quote =>
      'Even in the most difficult of times, one should not abandon Dharma.';

  @override
  String get ritualCardSd05QuoteAuthor => 'Ramayana, Ayodhya Kanda';

  @override
  String get ritualCardSd06Title => 'Action Without Attachment';

  @override
  String get ritualCardSd06Prompt =>
      'What is one task or effort you are doing today where you can let go of the result and focus purely on the quality of your action?';

  @override
  String get ritualCardSd06Quote =>
      'You have the right to perform your duty, but you are not entitled to the fruits of your actions.';

  @override
  String get ritualCardSd06QuoteAuthor => 'Bhagavad Gita 2.47';

  @override
  String get ritualCardSd07Title => 'The Seed You Plant Today';

  @override
  String get ritualCardSd07Prompt =>
      'Every action is a seed. What kind of seed — patience, kindness, discipline, or something else — are you planting today?';

  @override
  String get ritualCardSd07Quote =>
      'As a man sows, so shall he reap. There is no escape from the fruits of one\'s actions.';

  @override
  String get ritualCardSd07QuoteAuthor => 'Mahabharata, Vana Parva';

  @override
  String get ritualCardSd08Title => 'Nishkama Karma';

  @override
  String get ritualCardSd08Prompt =>
      'Think of something you did purely for its own sake, without wanting praise or reward. How did that feel? Can you bring that spirit to more of your day?';

  @override
  String get ritualCardSd08Quote =>
      'The wise, engaged in selfless action, surrender all attachment to results and attain supreme peace.';

  @override
  String get ritualCardSd08QuoteAuthor => 'Bhagavad Gita 5.12';

  @override
  String get ritualCardSd09Title => 'Breaking the Chain';

  @override
  String get ritualCardSd09Prompt =>
      'Is there a pattern of reaction — anger, avoidance, blame — that you keep repeating? What would it look like to consciously choose a different response today?';

  @override
  String get ritualCardSd09Quote =>
      'One who restrains the senses and organs of action, but whose mind dwells on sense objects, is deluded and called a hypocrite.';

  @override
  String get ritualCardSd09QuoteAuthor => 'Bhagavad Gita 3.6';

  @override
  String get ritualCardSd10Title => 'Karma Yoga in Daily Life';

  @override
  String get ritualCardSd10Prompt =>
      'How can you transform an ordinary task today — cooking, cleaning, working — into an offering, performing it with full attention and devotion?';

  @override
  String get ritualCardSd10Quote =>
      'Whatever you do, whatever you eat, whatever you offer in sacrifice, whatever you give, whatever austerity you practise — do it as an offering to Me.';

  @override
  String get ritualCardSd10QuoteAuthor => 'Bhagavad Gita 9.27';

  @override
  String get ritualCardSd11Title => 'The Heart of Devotion';

  @override
  String get ritualCardSd11Prompt =>
      'What fills your heart with reverence and love — a prayer, a memory, a place, the thought of the Divine? Dwell on it now.';

  @override
  String get ritualCardSd11Quote =>
      'Whoever offers Me with devotion a leaf, a flower, a fruit, or water — that offering of love I accept from the pure-hearted.';

  @override
  String get ritualCardSd11QuoteAuthor => 'Bhagavad Gita 9.26';

  @override
  String get ritualCardSd12Title => 'Surrender and Trust';

  @override
  String get ritualCardSd12Prompt =>
      'What worry or burden can you mentally place at the feet of the Divine today, trusting that grace will carry you through?';

  @override
  String get ritualCardSd12Quote =>
      'Abandon all varieties of Dharma and simply surrender unto Me. I shall deliver you from all sinful reactions; do not fear.';

  @override
  String get ritualCardSd12QuoteAuthor => 'Bhagavad Gita 18.66';

  @override
  String get ritualCardSd13Title => 'Seeing God in All';

  @override
  String get ritualCardSd13Prompt =>
      'Can you look at every person you meet today as a form of the Divine? How would that change the way you speak and listen?';

  @override
  String get ritualCardSd13Quote =>
      'The wise see the same Divine Self equally in a learned Brahmin, a cow, an elephant, a dog, and an outcaste.';

  @override
  String get ritualCardSd13QuoteAuthor => 'Bhagavad Gita 5.18';

  @override
  String get ritualCardSd14Title => 'The Name that Purifies';

  @override
  String get ritualCardSd14Prompt =>
      'When was the last time you sat quietly and repeated a sacred name or mantra? What feelings arose when you did?';

  @override
  String get ritualCardSd14Quote =>
      'The name of the Lord is the boat that will take you across the ocean of worldly existence.';

  @override
  String get ritualCardSd14QuoteAuthor => 'Tulsidas, Ramcharitmanas';

  @override
  String get ritualCardSd15Title => 'Grace in Gratitude';

  @override
  String get ritualCardSd15Prompt =>
      'What unexpected blessing or moment of grace have you received recently that you have not yet paused to acknowledge?';

  @override
  String get ritualCardSd15Quote =>
      'I am the origin of all. Everything emanates from Me. The wise who know this worship Me with loving devotion.';

  @override
  String get ritualCardSd15QuoteAuthor => 'Bhagavad Gita 10.8';

  @override
  String get ritualCardSd16Title => 'Who Am I?';

  @override
  String get ritualCardSd16Prompt =>
      'Strip away your name, your job, your roles, your body. What remains? Sit with this question: Who am I beyond all labels?';

  @override
  String get ritualCardSd16Quote => 'Tat Tvam Asi — Thou art That.';

  @override
  String get ritualCardSd16QuoteAuthor => 'Chandogya Upanishad 6.8.7';

  @override
  String get ritualCardSd17Title => 'The Eternal Witness';

  @override
  String get ritualCardSd17Prompt =>
      'Observe your thoughts passing by without grasping any of them. Who is the one watching? Can that awareness itself ever be harmed?';

  @override
  String get ritualCardSd17Quote =>
      'The Self is never born, nor does it die. It is eternal, ever-existing, and primeval. It is not slain when the body is slain.';

  @override
  String get ritualCardSd17QuoteAuthor => 'Bhagavad Gita 2.20';

  @override
  String get ritualCardSd18Title => 'Knowledge That Frees';

  @override
  String get ritualCardSd18Prompt =>
      'What is one truth about yourself or about life that, once you truly accepted it, freed you from suffering?';

  @override
  String get ritualCardSd18Quote =>
      'There is nothing as purifying in this world as knowledge. One who has attained purity of mind through prolonged Yoga discovers this knowledge within, in due course of time.';

  @override
  String get ritualCardSd18QuoteAuthor => 'Bhagavad Gita 4.38';

  @override
  String get ritualCardSd19Title => 'Beyond the Senses';

  @override
  String get ritualCardSd19Prompt =>
      'Your senses show you the surface of things. What deeper truth lies beneath the situation you are facing right now?';

  @override
  String get ritualCardSd19Quote =>
      'Beyond the senses are the objects; beyond the objects is the mind; beyond the mind is the intellect; beyond the intellect is the Great Self.';

  @override
  String get ritualCardSd19QuoteAuthor => 'Katha Upanishad 1.3.10';

  @override
  String get ritualCardSd20Title => 'The Light Within';

  @override
  String get ritualCardSd20Prompt =>
      'Close your eyes. Imagine a steady flame burning in your heart that no wind can extinguish. What does this light illuminate for you?';

  @override
  String get ritualCardSd20Quote =>
      'Asato ma sadgamaya, tamaso ma jyotirgamaya, mrityorma amritam gamaya. Lead me from the unreal to the Real, from darkness to Light, from death to Immortality.';

  @override
  String get ritualCardSd20QuoteAuthor => 'Brihadaranyaka Upanishad 1.3.28';

  @override
  String get ritualCardSd21Title => 'The Fullness of Being';

  @override
  String get ritualCardSd21Prompt =>
      'If you lack nothing at the deepest level, why do you feel incomplete? Reflect on what it means to be already whole.';

  @override
  String get ritualCardSd21Quote =>
      'Om Purnamadah Purnamidam — That is Whole, this is Whole. From the Whole, the Whole arises. When the Whole is taken from the Whole, the Whole still remains.';

  @override
  String get ritualCardSd21QuoteAuthor => 'Isha Upanishad, Invocation';

  @override
  String get ritualCardSd22Title => 'Brahman in Everything';

  @override
  String get ritualCardSd22Prompt =>
      'The same consciousness that shines through you shines through every living being. How does this awareness change the way you see the world today?';

  @override
  String get ritualCardSd22Quote => 'Aham Brahmasmi — I am Brahman.';

  @override
  String get ritualCardSd22QuoteAuthor => 'Brihadaranyaka Upanishad 1.4.10';

  @override
  String get ritualCardSd23Title => 'Stilling the Mind';

  @override
  String get ritualCardSd23Prompt =>
      'Right now, observe the fluctuations of your mind — planning, worrying, remembering. Can you gently bring all of them to stillness, even for a few breaths?';

  @override
  String get ritualCardSd23Quote =>
      'Yogas chitta vritti nirodhah — Yoga is the cessation of the fluctuations of the mind.';

  @override
  String get ritualCardSd23QuoteAuthor => 'Yoga Sutras of Patanjali 1.2';

  @override
  String get ritualCardSd24Title => 'Steady Practice';

  @override
  String get ritualCardSd24Prompt =>
      'What is one positive habit or practice you can commit to with patience and devotion, knowing that consistency matters more than intensity?';

  @override
  String get ritualCardSd24Quote =>
      'Abhyasa — practice becomes firmly grounded when it is pursued for a long time, without interruption, and with sincere devotion.';

  @override
  String get ritualCardSd24QuoteAuthor => 'Yoga Sutras of Patanjali 1.14';

  @override
  String get ritualCardSd25Title => 'Evenness of Mind';

  @override
  String get ritualCardSd25Prompt =>
      'Recall a recent moment of success and a moment of failure. Can you hold both with the same steady awareness, without elation or despair?';

  @override
  String get ritualCardSd25Quote =>
      'Yoga is equanimity of mind — samatvam yoga uchyate.';

  @override
  String get ritualCardSd25QuoteAuthor => 'Bhagavad Gita 2.48';

  @override
  String get ritualCardSd26Title => 'The Five Yamas';

  @override
  String get ritualCardSd26Prompt =>
      'Non-violence, truthfulness, non-stealing, moderation, non-possessiveness — which of the five Yamas is the hardest for you right now, and why?';

  @override
  String get ritualCardSd26Quote =>
      'Ahimsa, Satya, Asteya, Brahmacharya, Aparigraha — these are the great universal vows.';

  @override
  String get ritualCardSd26QuoteAuthor => 'Yoga Sutras of Patanjali 2.30';

  @override
  String get ritualCardSd27Title => 'Ishvara Pranidhana';

  @override
  String get ritualCardSd27Prompt =>
      'What does it feel like to offer your effort completely — not to achieve, but to dedicate? Try offering your next action to something greater than yourself.';

  @override
  String get ritualCardSd27Quote =>
      'By total surrender to Ishvara, Samadhi is attained.';

  @override
  String get ritualCardSd27QuoteAuthor => 'Yoga Sutras of Patanjali 2.45';

  @override
  String get ritualCardSd28Title => 'Non-Violence in Thought';

  @override
  String get ritualCardSd28Prompt =>
      'Have you directed harsh, violent thoughts towards yourself or someone else today? What would it mean to replace them with understanding?';

  @override
  String get ritualCardSd28Quote =>
      'Ahimsa Paramo Dharma — Non-violence is the highest Dharma.';

  @override
  String get ritualCardSd28QuoteAuthor =>
      'Mahabharata, Anushasana Parva 116.38';

  @override
  String get ritualCardSd29Title => 'Compassion for All Beings';

  @override
  String get ritualCardSd29Prompt =>
      'Think of a creature — an animal, an insect, a bird — you encountered recently. What would the world be like if you extended the same care to all living beings?';

  @override
  String get ritualCardSd29Quote =>
      'One who sees all beings in the Self and the Self in all beings, never turns away from it.';

  @override
  String get ritualCardSd29QuoteAuthor => 'Isha Upanishad, Verse 6';

  @override
  String get ritualCardSd30Title => 'Gentle Speech';

  @override
  String get ritualCardSd30Prompt =>
      'Before you speak today, pause and ask: Is it true? Is it kind? Is it necessary? How does this filter change your conversations?';

  @override
  String get ritualCardSd30Quote =>
      'Words that do not cause distress, that are truthful, pleasant, and beneficial — this is called the austerity of speech.';

  @override
  String get ritualCardSd30QuoteAuthor => 'Bhagavad Gita 17.15';

  @override
  String get ritualCardSd31Title => 'Forgiving the Hurt';

  @override
  String get ritualCardSd31Prompt =>
      'Who has caused you pain that you are still carrying? What would it take to forgive — not for them, but to free your own heart?';

  @override
  String get ritualCardSd31Quote => 'Forgiveness is the ornament of the brave.';

  @override
  String get ritualCardSd31QuoteAuthor => 'Mahabharata, Udyoga Parva 33.48';

  @override
  String get ritualCardSd32Title => 'Living in Truth';

  @override
  String get ritualCardSd32Prompt =>
      'Is there something in your life where you are being less than truthful — with yourself or with others? What would honest alignment look like?';

  @override
  String get ritualCardSd32Quote => 'Satyameva Jayate — Truth alone triumphs.';

  @override
  String get ritualCardSd32QuoteAuthor => 'Mundaka Upanishad 3.1.6';

  @override
  String get ritualCardSd33Title => 'The Courage of Honesty';

  @override
  String get ritualCardSd33Prompt =>
      'What is one truth you have been avoiding because it is uncomfortable? What would it take to face it with courage today?';

  @override
  String get ritualCardSd33Quote =>
      'Speak the truth. Practise Dharma. Do not neglect the study of the scriptures.';

  @override
  String get ritualCardSd33QuoteAuthor => 'Taittiriya Upanishad 1.11.1';

  @override
  String get ritualCardSd34Title => 'Truth Beyond Words';

  @override
  String get ritualCardSd34Prompt =>
      'Truth is not only in what you say, but in what you do. Are your actions today aligned with the truth you hold in your heart?';

  @override
  String get ritualCardSd34Quote =>
      'By truthfulness, man reaches the station of God.';

  @override
  String get ritualCardSd34QuoteAuthor => 'Chanakya Niti 14.3';

  @override
  String get ritualCardSd35Title => 'The Promise You Keep';

  @override
  String get ritualCardSd35Prompt =>
      'What is a promise you have made — to yourself, to another, or to the Divine — that you must honour? Recommit to it now.';

  @override
  String get ritualCardSd35Quote =>
      'Let your word be your bond. A person who breaks a promise breaks trust, and trust once broken is hard to rebuild.';

  @override
  String get ritualCardSd35QuoteAuthor => 'Vidura Niti, Mahabharata';

  @override
  String get ritualCardSd36Title => 'Letting Go';

  @override
  String get ritualCardSd36Prompt =>
      'What possession, expectation, or desire are you clinging to that no longer serves your growth? Imagine gently releasing it.';

  @override
  String get ritualCardSd36Quote =>
      'Vairagya is the mastery of consciousness in which one is free from craving for sense objects, whether experienced directly or described.';

  @override
  String get ritualCardSd36QuoteAuthor => 'Yoga Sutras of Patanjali 1.15';

  @override
  String get ritualCardSd37Title => 'The Unchanging Self';

  @override
  String get ritualCardSd37Prompt =>
      'Everything around you changes — moods, fortunes, relationships. What part of you has remained unchanged through all of life\'s storms?';

  @override
  String get ritualCardSd37Quote =>
      'That which is not real never was and never will be. That which is real always was and can never cease to be.';

  @override
  String get ritualCardSd37QuoteAuthor => 'Bhagavad Gita 2.16';

  @override
  String get ritualCardSd38Title => 'Contentment';

  @override
  String get ritualCardSd38Prompt =>
      'What do you already have that is truly enough? Reflect on the difference between want and need in your life right now.';

  @override
  String get ritualCardSd38Quote =>
      'From contentment comes unsurpassed happiness.';

  @override
  String get ritualCardSd38QuoteAuthor => 'Yoga Sutras of Patanjali 2.42';

  @override
  String get ritualCardSd39Title => 'Beyond Pleasure and Pain';

  @override
  String get ritualCardSd39Prompt =>
      'Can you sit with discomfort without fleeing, and with pleasure without grasping? What happens when you simply observe both?';

  @override
  String get ritualCardSd39Quote =>
      'One who is not disturbed by happiness and distress and is steady in both is certainly eligible for liberation.';

  @override
  String get ritualCardSd39QuoteAuthor => 'Bhagavad Gita 2.15';

  @override
  String get ritualCardSd40Title => 'The Joy of Giving';

  @override
  String get ritualCardSd40Prompt =>
      'What can you give today — time, attention, a kind word, a helping hand — without expecting anything in return?';

  @override
  String get ritualCardSd40Quote =>
      'The highest form of charity is helping those who are helpless.';

  @override
  String get ritualCardSd40QuoteAuthor => 'Thirukkural 221';

  @override
  String get ritualCardSd41Title => 'Serving the Divine in Others';

  @override
  String get ritualCardSd41Prompt =>
      'If the person standing in front of you were God in disguise, how would you treat them? Try living this for the next hour.';

  @override
  String get ritualCardSd41Quote => 'Service to humanity is service to God.';

  @override
  String get ritualCardSd41QuoteAuthor => 'Swami Vivekananda';

  @override
  String get ritualCardSd42Title => 'Selfless Work';

  @override
  String get ritualCardSd42Prompt =>
      'Recall a time when you helped someone and felt a quiet, deep joy that had nothing to do with recognition. What did that teach you?';

  @override
  String get ritualCardSd42Quote =>
      'Arise, awake, and stop not till the goal is reached.';

  @override
  String get ritualCardSd42QuoteAuthor =>
      'Katha Upanishad 1.3.14 / Swami Vivekananda';

  @override
  String get ritualCardSd43Title => 'Vasudhaiva Kutumbakam';

  @override
  String get ritualCardSd43Prompt =>
      'The whole world is one family. What is one step you can take today to live as though every person\'s well-being matters to you?';

  @override
  String get ritualCardSd43Quote =>
      'Vasudhaiva Kutumbakam — the entire world is one family.';

  @override
  String get ritualCardSd43QuoteAuthor => 'Maha Upanishad 6.71';

  @override
  String get ritualCardSd44Title => 'The Wealth of Kindness';

  @override
  String get ritualCardSd44Prompt =>
      'What small act of kindness did someone do for you that you still remember? How can you pass that same kindness forward today?';

  @override
  String get ritualCardSd44Quote =>
      'Even the poverty of the poor will depart if they give, with compassion, even what little they have.';

  @override
  String get ritualCardSd44QuoteAuthor => 'Thirukkural 247';

  @override
  String get ritualCardSd45Title => 'The Peace Within';

  @override
  String get ritualCardSd45Prompt =>
      'Close your eyes and take three slow breaths. Feel the silence between each breath. That silence is who you truly are. Can you carry it through the day?';

  @override
  String get ritualCardSd45Quote =>
      'For one who has conquered the mind, the mind is the best of friends; but for one who has failed to do so, the mind will remain the greatest enemy.';

  @override
  String get ritualCardSd45QuoteAuthor => 'Bhagavad Gita 6.6';

  @override
  String get ritualCardSd46Title => 'Equanimity in Praise and Blame';

  @override
  String get ritualCardSd46Prompt =>
      'Recall a recent praise and a recent criticism you received. Can you hold both with the same calm composure, without clinging to one or rejecting the other?';

  @override
  String get ritualCardSd46Quote =>
      'One who is the same to friend and foe, in honour and dishonour, in heat and cold, in pleasure and pain, and is free from attachment — such a person is dear to Me.';

  @override
  String get ritualCardSd46QuoteAuthor => 'Bhagavad Gita 12.18–19';

  @override
  String get ritualCardSd47Title => 'The Lotus in Mud';

  @override
  String get ritualCardSd47Prompt =>
      'A lotus blooms in muddy water yet remains unstained. What is the muddy situation in your life right now, and how can you remain untouched by it while still growing?';

  @override
  String get ritualCardSd47Quote =>
      'One who performs actions without attachment, surrendering them to Brahman, is untouched by sin, like a lotus leaf by water.';

  @override
  String get ritualCardSd47QuoteAuthor => 'Bhagavad Gita 5.10';

  @override
  String get ritualCardSd48Title => 'Om Shanti';

  @override
  String get ritualCardSd48Prompt =>
      'Sit still and repeat Om Shanti three times — peace in body, peace in mind, peace in spirit. What disturbance melts away as you do this?';

  @override
  String get ritualCardSd48Quote =>
      'Om Shantih Shantih Shantih — Om, Peace, Peace, Peace.';

  @override
  String get ritualCardSd48QuoteAuthor => 'Upanishadic Shanti Mantra';

  @override
  String get ritualCardSd49Title => 'May All Be Happy';

  @override
  String get ritualCardSd49Prompt =>
      'Silently wish well-being for yourself, then for your loved ones, then for strangers, then for all beings. Notice how your heart expands as the circle widens.';

  @override
  String get ritualCardSd49Quote =>
      'Sarve bhavantu sukhinah, sarve santu niramayah. Sarve bhadrani pashyantu, ma kashchit duhkhabhag bhavet. — May all be happy, may all be free from disease, may all see auspiciousness, may none suffer.';

  @override
  String get ritualCardSd49QuoteAuthor => 'Upanishadic Prayer';

  @override
  String get ritualCardSd50Title => 'Strength and Peace Together';

  @override
  String get ritualCardSd50Prompt =>
      'True strength does not come from tension; it comes from deep inner peace. Where in your life can you replace force with calm resolve today?';

  @override
  String get ritualCardSd50Quote =>
      'Strength is life, weakness is death. Strength is the medicine, strength is the cure. Strength, strength is what the Upanishads preach.';

  @override
  String get ritualCardSd50QuoteAuthor => 'Swami Vivekananda';

  @override
  String get pendingAlertsTitle => 'Pending Task Alerts';

  @override
  String get pendingAlertsSubtitle =>
      'Reminders at day start and periodic intervals for pending tasks.';

  @override
  String get pendingAlertsEnabled => 'Enable Pending Alerts';

  @override
  String get pendingAlertsEnabledDetail =>
      'Show an interactive list of pending tasks when alerts trigger.';

  @override
  String get pendingAlertsDayStart => 'Day Start Alert';

  @override
  String get pendingAlertsDayStartDetail =>
      'Show pending tasks alert at the beginning of each day.';

  @override
  String get pendingAlertsDayStartTime => 'Alert Time';

  @override
  String get pendingAlertsInterval => 'Reminder Interval';

  @override
  String get pendingAlertsIntervalDetail =>
      'How often to remind you about pending tasks while using the app.';

  @override
  String get pendingAlertsIntervalOff => 'Off';

  @override
  String get pendingAlertsInterval30m => 'Every 30 minutes';

  @override
  String get pendingAlertsInterval1h => 'Every 1 hour';

  @override
  String get pendingAlertsInterval2h => 'Every 2 hours';

  @override
  String get pendingAlertsInterval3h => 'Every 3 hours';

  @override
  String get pendingAlertsInterval4h => 'Every 4 hours';

  @override
  String get pendingAlertsHaptic => 'Vibrate / Haptic';

  @override
  String get pendingAlertsHapticDetail =>
      'Vibrate device gently when a pending task alert appears.';

  @override
  String get pendingAlertsPreview => 'Preview Pending Tasks Alert';

  @override
  String get pendingAlertsSheetTitle => 'Pending Tasks Alert';

  @override
  String pendingAlertsSheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending tasks remaining today',
      one: '1 pending task remaining today',
    );
    return '$_temp0';
  }

  @override
  String get pendingAlertsSheetEmpty =>
      'Great job! No pending tasks remaining for today.';

  @override
  String get pendingAlertsStartTimer => 'Start';

  @override
  String get pendingAlertsGoToToday => 'Open Daily List';

  @override
  String get pendingAlertsSnooze => 'Snooze (1 hour)';

  @override
  String get pendingAlertsDismiss => 'Dismiss';

  @override
  String get trackingRunningNotification => 'Running task notification';

  @override
  String get trackingRunningNotificationDetail =>
      'Show an ongoing notification with a live timer while tracking time';

  @override
  String get permissionsNotificationTitle => 'Notifications';

  @override
  String get permissionsNotificationBody =>
      'Used to display an ongoing live timer in the notification drawer while tracking tasks, and for optional daily reminders. Operates 100% offline with zero cloud access.';

  @override
  String get pendingAlertsTodaySection => 'Today\'s Tasks';

  @override
  String get pendingAlertsPreviousSection => 'From Previous Days';

  @override
  String get pendingAlertsPortToToday => 'Port to Today';

  @override
  String get pendingAlertsPortedSuccess => 'Task ported to today';

  @override
  String get pendingAlertsNotificationTitle => 'Pending Tasks Reminder';

  @override
  String pendingAlertsNotificationBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count pending tasks waiting',
      one: 'You have 1 pending task waiting',
    );
    return '$_temp0';
  }

  @override
  String get taskHistory => 'Task History';

  @override
  String get taskHistorySubtitle =>
      'Full lifecycle and activity timeline for this task';

  @override
  String get taskHistoryEmpty =>
      'No activity history recorded for this task yet.';

  @override
  String get eventCreated => 'Task created';

  @override
  String get eventMoved => 'Task moved';

  @override
  String eventMovedFromTo(String fromDate, String toDate) {
    return 'Moved from $fromDate to $toDate';
  }

  @override
  String get eventTimerStarted => 'Timer started';

  @override
  String eventTimerStopped(String duration) {
    return 'Timer stopped ($duration)';
  }

  @override
  String eventTimerPaused(String duration) {
    return 'Timer paused ($duration)';
  }

  @override
  String eventManualSegment(String duration) {
    return 'Manual time added ($duration)';
  }

  @override
  String eventStatusChanged(String status) {
    return 'Status changed to $status';
  }

  @override
  String get eventSubtaskToggled => 'Sub-task updated';

  @override
  String get eventEdited => 'Task details edited';

  @override
  String get moveToToday => 'Move to Today';

  @override
  String get taskMovedToToday => 'Task moved to today';

  @override
  String taskMovedSuccess(String date) {
    return 'Task moved to $date';
  }
}
