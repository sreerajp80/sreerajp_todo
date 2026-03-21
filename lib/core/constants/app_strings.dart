abstract final class AppStrings {
  static const String appName = 'SreerajP ToDo';

  static const String dailyList = 'Daily List';
  static const String createTodo = 'New Todo';
  static const String editTodo = 'Edit Todo';
  static const String timeSegments = 'Time Segments';
  static const String copyTodos = 'Copy Todos';
  static const String searchResults = 'Search Results';
  static const String backup = 'Backup';
  static const String recurringTasks = 'Recurring Tasks';
  static const String newRecurrence = 'New Recurrence Rule';
  static const String editRecurrence = 'Edit Recurrence Rule';
  static const String statistics = 'Statistics';

  static const String titleHint = 'Enter task title';
  static const String descriptionHint = 'Enter description (optional)';
  static const String searchHint = 'Search todos...';
  static const String noTodosForDay = 'No tasks for this day';
  static const String noSearchResults = 'No results found';
  static const String titleRequired = 'Title is required';

  static const String statusPending = 'Pending';
  static const String statusCompleted = 'Completed';
  static const String statusDropped = 'Dropped';
  static const String statusPorted = 'Ported';

  static const String confirmDrop = 'Drop this task?';
  static const String confirmDropBody =
      'This task will be marked as dropped. Time spent will be categorised as dropped time.';
  static const String confirmPort = 'Port this task?';
  static const String confirmPortBody =
      'This task will be moved to the selected date.';
  static const String confirmDelete = 'Delete this task?';
  static const String confirmDeleteBody =
      'This task and all its time segments will be permanently deleted.';
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
  static const String today = 'Today';
  static const String selectTargetDate = 'Select target date';
  static const String completeAll = 'Complete All';
  static const String markDropped = 'Mark Dropped';
  static const String selectAll = 'Select All';
  static const String deselectAll = 'Deselect All';
  static const String copyToAnotherDay = 'Copy to another day';

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
  static const String segmentRunning = 'running…';
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
  static const String willBeSkipped = 'Already exists — will be skipped';
  static const String itemsToCopy = 'items to copy';
  static const String itemsWillBeSkipped = 'will be skipped';
  static const String targetDate = 'Target Date';
  static const String sourceDate = 'Source Date';
  static const String selectDateFirst = 'Select a target date first';

  static const String viewTodo = 'View Todo';
  static const String readOnlyPastDate = 'Past date — read only';

  static String selectedCount(int count) => '$count selected';

  // Recurrence
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

  static const errors = _ErrorStrings();
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
      'This backup was created by a newer version of the app.';
  String get backupCorrupted => 'The backup file is corrupted.';
  String get portTargetMustBeFuture =>
      'Port target date must be tomorrow or later.';
  String get generic => 'An unexpected error occurred.';
}
