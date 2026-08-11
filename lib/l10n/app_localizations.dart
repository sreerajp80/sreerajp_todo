import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
  ];

  /// Application name. Proper noun, not translated.
  ///
  /// In en, this message translates to:
  /// **'SreerajP ToDo'**
  String get appName;

  /// Title for daily todo list screen.
  ///
  /// In en, this message translates to:
  /// **'My ToDos'**
  String get dailyList;

  /// Button label for creating a new todo.
  ///
  /// In en, this message translates to:
  /// **'New Todo'**
  String get createTodo;

  /// Screen title for editing a todo.
  ///
  /// In en, this message translates to:
  /// **'Edit Todo'**
  String get editTodo;

  /// Label for time segments section or screen.
  ///
  /// In en, this message translates to:
  /// **'Time Segments'**
  String get timeSegments;

  /// Action label for copying todos to another date.
  ///
  /// In en, this message translates to:
  /// **'Copy Todos'**
  String get copyTodos;

  /// Header title for search results.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Title for recurring tasks screen or section.
  ///
  /// In en, this message translates to:
  /// **'Recurring Tasks'**
  String get recurringTasks;

  /// Screen title for creating a new recurrence rule.
  ///
  /// In en, this message translates to:
  /// **'New Recurrence Rule'**
  String get newRecurrence;

  /// Screen title for editing a recurrence rule.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurrence Rule'**
  String get editRecurrence;

  /// Title for statistics dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// TextField placeholder hint for task title.
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get titleHint;

  /// TextField placeholder hint for task description.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get descriptionHint;

  /// SearchBar placeholder text.
  ///
  /// In en, this message translates to:
  /// **'Search todos...'**
  String get searchHint;

  /// Empty state title for a day with no tasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTodosForDay;

  /// Empty state message when search yields no matches.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// Form validation error when title is left empty.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Action text suggesting adding a task.
  ///
  /// In en, this message translates to:
  /// **'Add your first task'**
  String get addFirstTask;

  /// Empty state header title for today.
  ///
  /// In en, this message translates to:
  /// **'No tasks today'**
  String get noTasksTodayTitle;

  /// Empty state body text encouraging task creation for today.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to start planning this day.'**
  String get noTasksTodayMessage;

  /// Empty state body text for past days without tasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks were recorded for this day.'**
  String get noTasksForPastDayMessage;

  /// Header title on search screen.
  ///
  /// In en, this message translates to:
  /// **'Search your tasks'**
  String get searchTasksTitle;

  /// Instructional subtitle on search screen.
  ///
  /// In en, this message translates to:
  /// **'Enter a title or description to search across days.'**
  String get searchTasksMessage;

  /// Empty state message on statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Start tracking tasks to see your statistics'**
  String get noStatisticsData;

  /// Empty state detailed message for recurring tasks screen.
  ///
  /// In en, this message translates to:
  /// **'No recurring tasks. Create one to automate task creation.'**
  String get noRecurringTasksDetailed;

  /// Empty state message on time segments screen.
  ///
  /// In en, this message translates to:
  /// **'Track time or add a manual segment to see history here.'**
  String get noSegmentsRecordedDetailed;

  /// Label for backup destination directory picker.
  ///
  /// In en, this message translates to:
  /// **'Backup folder'**
  String get backupDirectory;

  /// Tooltip/button label for navigating to previous day.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// Tooltip/button label for navigating to next day.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// Tooltip/button label for opening calendar date picker.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get openCalendar;

  /// Tooltip/button label to clear search query.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Tooltip/button label to toggle bulk selection mode.
  ///
  /// In en, this message translates to:
  /// **'Toggle selection'**
  String get toggleSelection;

  /// Tooltip/accessibility label for task action menu.
  ///
  /// In en, this message translates to:
  /// **'Open task actions'**
  String get openTaskActions;

  /// Label or tooltip for read-only past day task.
  ///
  /// In en, this message translates to:
  /// **'Locked task'**
  String get lockedTask;

  /// Single-letter badge for a manual segment.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get manualSegmentShort;

  /// Em dash placeholder for an empty value.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emptyValue;

  /// Label for calendar day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Label for task details section.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Label for task status field.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskStatus;

  /// Task status label for pending state.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Task status label for in-progress working state.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get statusWorking;

  /// Task status label for completed state.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Task status label for dropped state.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// Task status label for ported state.
  ///
  /// In en, this message translates to:
  /// **'Ported'**
  String get statusPorted;

  /// Button/action label to mark a task completed.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// Button/action label to mark a task dropped.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get dropAction;

  /// Confirmation dialog title for dropping a task.
  ///
  /// In en, this message translates to:
  /// **'Drop this task?'**
  String get confirmDrop;

  /// Confirmation dialog body text when dropping a task.
  ///
  /// In en, this message translates to:
  /// **'This task will be marked as dropped. Time spent will be categorised as dropped time.'**
  String get confirmDropBody;

  /// Confirmation dialog title for porting a task.
  ///
  /// In en, this message translates to:
  /// **'Port this task?'**
  String get confirmPort;

  /// Confirmation dialog body text when porting a task.
  ///
  /// In en, this message translates to:
  /// **'This task will be moved to the selected date.'**
  String get confirmPortBody;

  /// Confirmation dialog title for deleting a task.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get confirmDelete;

  /// Confirmation dialog body text when deleting a task.
  ///
  /// In en, this message translates to:
  /// **'This task and all its time segments will be permanently deleted.'**
  String get confirmDeleteBody;

  /// Confirmation dialog title for deleting a task from a recurrence rule.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring task?'**
  String get confirmDeleteRecurring;

  /// Confirmation dialog body text when deleting a recurring task occurrence.
  ///
  /// In en, this message translates to:
  /// **'This task was created by a recurrence rule.'**
  String get confirmDeleteRecurringBody;

  /// Option label to delete single occurrence of recurring task.
  ///
  /// In en, this message translates to:
  /// **'Delete only this one'**
  String get deleteOnlyThis;

  /// Option label to delete current and future occurrences of recurring task.
  ///
  /// In en, this message translates to:
  /// **'Delete this and future'**
  String get deleteThisAndFuture;

  /// Option label to delete all occurrences of recurring task.
  ///
  /// In en, this message translates to:
  /// **'Delete all occurrences'**
  String get deleteAllOccurrences;

  /// SnackBar message when all occurrences of recurring task are deleted.
  ///
  /// In en, this message translates to:
  /// **'All occurrences deleted'**
  String get allOccurrencesDeleted;

  /// SnackBar message when future occurrences of recurring task are deleted.
  ///
  /// In en, this message translates to:
  /// **'This and future occurrences deleted'**
  String get futureOccurrencesDeleted;

  /// Confirmation dialog title for bulk dropping tasks.
  ///
  /// In en, this message translates to:
  /// **'Drop selected tasks?'**
  String get confirmBulkDrop;

  /// Confirmation dialog body text when bulk dropping tasks.
  ///
  /// In en, this message translates to:
  /// **'All selected tasks will be marked as dropped.'**
  String get confirmBulkDropBody;

  /// Generic dialog positive confirmation button label.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Generic dialog cancellation button label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic form save button label.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic deletion action label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Action label for undoing an operation.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Action label for editing.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Action label for porting task to future date.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// Action label for copying items.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Action label for retrying an operation.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Label for current date or today button.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label or header when picking target date.
  ///
  /// In en, this message translates to:
  /// **'Select target date'**
  String get selectTargetDate;

  /// Bulk action label to complete all selected tasks.
  ///
  /// In en, this message translates to:
  /// **'Complete All'**
  String get completeAll;

  /// Bulk action label to drop all selected tasks.
  ///
  /// In en, this message translates to:
  /// **'Mark Dropped'**
  String get markDropped;

  /// Bulk selection action to select all items.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Bulk selection action to deselect all items.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// Action label to initiate copying tasks to another date.
  ///
  /// In en, this message translates to:
  /// **'Copy to another day'**
  String get copyToAnotherDay;

  /// Step navigation back/previous button label.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Prefix label for task copied from source date.
  ///
  /// In en, this message translates to:
  /// **'Copied from'**
  String get copiedFrom;

  /// Prefix label for task ported to target date.
  ///
  /// In en, this message translates to:
  /// **'Ported to'**
  String get portedTo;

  /// Placeholder when task description is empty.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// Action button label to start live timer segment.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get startTimer;

  /// Action button label to stop active timer segment.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get stopTimer;

  /// Status badge label indicating timer is currently tracking.
  ///
  /// In en, this message translates to:
  /// **'Timer running'**
  String get timerRunning;

  /// Button label to add manual time segment.
  ///
  /// In en, this message translates to:
  /// **'Add Manual Segment'**
  String get addManualSegment;

  /// SnackBar confirmation when manual time segment is added.
  ///
  /// In en, this message translates to:
  /// **'Manual segment added'**
  String get manualSegmentAdded;

  /// Label for segment start time field.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get segmentStart;

  /// Label for segment end time field.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get segmentEnd;

  /// Label for time segment type column/field.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get segmentType;

  /// Label for time segment duration column/field.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get segmentDuration;

  /// Label for automatically recorded time segment.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get segmentAuto;

  /// Label for manually added time segment.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get segmentManual;

  /// Duration placeholder for currently active segment.
  ///
  /// In en, this message translates to:
  /// **'running...'**
  String get segmentRunning;

  /// Tooltip explaining an interrupted auto-closed time segment.
  ///
  /// In en, this message translates to:
  /// **'Auto-closed on app restart'**
  String get segmentInterruptedTooltip;

  /// Label for accumulated total time duration.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get totalTime;

  /// Button label to open time segments view.
  ///
  /// In en, this message translates to:
  /// **'Time Segments'**
  String get viewSegments;

  /// Empty state text on time segments list.
  ///
  /// In en, this message translates to:
  /// **'No time segments recorded'**
  String get noSegments;

  /// Validation error message when segment start is equal or after end time.
  ///
  /// In en, this message translates to:
  /// **'Start time must be before end time'**
  String get startBeforeEnd;

  /// Validation error message when time segment overlaps existing segment.
  ///
  /// In en, this message translates to:
  /// **'This segment overlaps with an existing one'**
  String get segmentOverlap;

  /// Validation error message when segment spans across midnight.
  ///
  /// In en, this message translates to:
  /// **'Both times must fall within the same calendar day'**
  String get segmentMustBeSameDay;

  /// SnackBar notification prefix when task status changes.
  ///
  /// In en, this message translates to:
  /// **'Status changed to'**
  String get statusChangedTo;

  /// SnackBar notification when status change is reverted via undo.
  ///
  /// In en, this message translates to:
  /// **'Status change undone'**
  String get undoStatusChange;

  /// SnackBar message after updating status of multiple tasks.
  ///
  /// In en, this message translates to:
  /// **'tasks updated'**
  String get bulkStatusChanged;

  /// SnackBar notification when a new todo task is created.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get todoCreated;

  /// SnackBar notification when a todo task is edited/updated.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get todoUpdated;

  /// SnackBar notification when a task is deleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get todoDeleted;

  /// SnackBar notification when a task is ported.
  ///
  /// In en, this message translates to:
  /// **'Task ported'**
  String get todoPorted;

  /// SnackBar notification count of copied tasks.
  ///
  /// In en, this message translates to:
  /// **'tasks copied'**
  String get todosCopied;

  /// SnackBar notification suffix for duplicate skipped tasks.
  ///
  /// In en, this message translates to:
  /// **'skipped (duplicate title)'**
  String get todosSkipped;

  /// Wizard step title for selecting items to copy.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get stepSelectItems;

  /// Wizard step title for selecting destination date.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get stepPickDate;

  /// Wizard step title for previewing items to copy.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get stepPreview;

  /// Button label to move to next wizard step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Button label to move to previous wizard step.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Final confirmation action label in copy wizard.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyConfirm;

  /// Validation warning when no items are checked in copy wizard.
  ///
  /// In en, this message translates to:
  /// **'Select at least one item'**
  String get noItemsSelected;

  /// Preview badge for duplicate task that will be skipped.
  ///
  /// In en, this message translates to:
  /// **'Already exists - will be skipped'**
  String get willBeSkipped;

  /// Count summary label of valid tasks ready to copy.
  ///
  /// In en, this message translates to:
  /// **'items to copy'**
  String get itemsToCopy;

  /// Count summary label of duplicate tasks that will be skipped.
  ///
  /// In en, this message translates to:
  /// **'will be skipped'**
  String get itemsWillBeSkipped;

  /// Label for destination target date.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// Label for origin source date.
  ///
  /// In en, this message translates to:
  /// **'Source Date'**
  String get sourceDate;

  /// Validation instruction to choose target date in copy wizard.
  ///
  /// In en, this message translates to:
  /// **'Select a target date first'**
  String get selectDateFirst;

  /// Screen title for viewing read-only past todo.
  ///
  /// In en, this message translates to:
  /// **'View Todo'**
  String get viewTodo;

  /// Header badge indicating past date is locked against edits.
  ///
  /// In en, this message translates to:
  /// **'Past date - read only'**
  String get readOnlyPastDate;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @noSearchResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No tasks found matching \'{query}\''**
  String noSearchResultsForQuery(String query);

  /// No description provided for @statusSemantics.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusSemantics(String status);

  /// No description provided for @totalTimeForTask.
  ///
  /// In en, this message translates to:
  /// **'Total time for {title}: {duration}'**
  String totalTimeForTask(String title, String duration);

  /// No description provided for @startTimerForTask.
  ///
  /// In en, this message translates to:
  /// **'Start timer for {title}'**
  String startTimerForTask(String title);

  /// No description provided for @stopTimerForTask.
  ///
  /// In en, this message translates to:
  /// **'Stop timer for {title}'**
  String stopTimerForTask(String title);

  /// No description provided for @runningTimerForTask.
  ///
  /// In en, this message translates to:
  /// **'Timer running for {title}'**
  String runningTimerForTask(String title);

  /// No description provided for @segmentSemantics.
  ///
  /// In en, this message translates to:
  /// **'Segment {index}. {start} to {end}. Duration {duration}. Type {type}.'**
  String segmentSemantics(
    int index,
    String start,
    String end,
    String duration,
    String type,
  );

  /// Label for task repetition setting.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// Option label for no recurrence rule.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeatNone;

  /// Action label to open recurrence configuration.
  ///
  /// In en, this message translates to:
  /// **'Repeat…'**
  String get repeatConfigure;

  /// SnackBar message when a task with recurrence is created.
  ///
  /// In en, this message translates to:
  /// **'Task and recurrence rule created'**
  String get recurrenceCreated;

  /// Label for recurrence start date.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// Label for recurrence end date.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// Label for recurrence end condition.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// Option label for indefinite recurrence.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get endsNever;

  /// Option label for recurrence ending on specific date.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get endsOnDate;

  /// Option label for recurrence ending after fixed count.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get endsAfterDays;

  /// Label for recurrence frequency picker.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Option label for daily frequency.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Option label for weekly frequency.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Option label for monthly frequency.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Option label for yearly frequency.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Prefix label for recurrence interval (e.g. Every 2 weeks).
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// Plural unit label for days interval.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Plural unit label for weeks interval.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// Plural unit label for months interval.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// Plural unit label for years interval.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Label for weekday selector.
  ///
  /// In en, this message translates to:
  /// **'Days of week'**
  String get daysOfWeek;

  /// Header for upcoming recurrence preview dates.
  ///
  /// In en, this message translates to:
  /// **'Next 5 occurrences'**
  String get nextOccurrences;

  /// Empty state text for recurrence rule preview.
  ///
  /// In en, this message translates to:
  /// **'No upcoming occurrences'**
  String get noUpcomingOccurrences;

  /// Short abbreviation for Monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Short abbreviation for Tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Short abbreviation for Wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Short abbreviation for Thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Short abbreviation for Friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Short abbreviation for Saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Short abbreviation for Sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Action/menu label for sorting task list.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTodos;

  /// Sort option for custom drag manual reordering.
  ///
  /// In en, this message translates to:
  /// **'Manual order'**
  String get sortManual;

  /// Sort option for title alphabetical ascending.
  ///
  /// In en, this message translates to:
  /// **'Name A→Z'**
  String get sortNameAZ;

  /// Sort option for title alphabetical descending.
  ///
  /// In en, this message translates to:
  /// **'Name Z→A'**
  String get sortNameZA;

  /// Sort option for creation timestamp ascending.
  ///
  /// In en, this message translates to:
  /// **'Created (oldest first)'**
  String get sortCreatedOldest;

  /// Sort option for creation timestamp descending.
  ///
  /// In en, this message translates to:
  /// **'Created (newest first)'**
  String get sortCreatedNewest;

  /// Sort option for duration descending.
  ///
  /// In en, this message translates to:
  /// **'Time spent (most first)'**
  String get sortTimeMost;

  /// Sort option for duration ascending.
  ///
  /// In en, this message translates to:
  /// **'Time spent (least first)'**
  String get sortTimeLeast;

  /// Sort option grouping by task status.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get sortByStatus;

  /// Navigation label or screen title for Backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupLabel;

  /// Screen/dialog title for exporting backup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get backupExportTitle;

  /// Screen/dialog title for importing backup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get backupImportTitle;

  /// Field label for backup encryption passphrase.
  ///
  /// In en, this message translates to:
  /// **'Backup Passphrase'**
  String get backupPassphraseLabel;

  /// Field label for confirming backup encryption passphrase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passphrase'**
  String get backupPassphraseConfirmLabel;

  /// Validation error when passphrase is shorter than 8 characters.
  ///
  /// In en, this message translates to:
  /// **'Passphrase must be at least 8 characters'**
  String get backupPassphraseMinLength;

  /// Validation error when passphrase confirmation does not match.
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match'**
  String get backupPassphraseMismatch;

  /// Warning banner reminding user to preserve backup passphrase.
  ///
  /// In en, this message translates to:
  /// **'If you forget this passphrase, the backup cannot be recovered. Write it down.'**
  String get backupPassphraseWarning;

  /// Success notification prefix after export finishes.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to'**
  String get backupExportSuccess;

  /// Confirmation title when restoring backup over existing local data.
  ///
  /// In en, this message translates to:
  /// **'Replace All Data?'**
  String get backupImportConfirmTitle;

  /// Warning message when restoring backup over existing local data.
  ///
  /// In en, this message translates to:
  /// **'This will replace ALL current data. This action cannot be undone.'**
  String get backupImportConfirmMessage;

  /// Success notification after data restoration.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get backupImportSuccess;

  /// Error message when backup decryption fails due to invalid passphrase.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passphrase or corrupted backup file'**
  String get backupImportWrongPassphrase;

  /// Error message when importing backup file schema from newer app release.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of the app. Please update.'**
  String get backupImportVersionTooNew;

  /// Error message when backup file format check fails.
  ///
  /// In en, this message translates to:
  /// **'The backup file is corrupted and cannot be restored'**
  String get backupImportCorrupted;

  /// Confirmation dialog title for deleting a local backup file.
  ///
  /// In en, this message translates to:
  /// **'Delete this backup?'**
  String get backupDeleteBackupConfirm;

  /// Empty state title when no local backups exist.
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get backupNoBackupsFound;

  /// Detailed empty state text for backup list.
  ///
  /// In en, this message translates to:
  /// **'No backups found. Export your first backup to keep your data safe.'**
  String get backupNoBackupsFoundDetailed;

  /// Section header for list of recent backup files.
  ///
  /// In en, this message translates to:
  /// **'Recent Backups'**
  String get backupRecentBackups;

  /// Button label to pick destination directory for backup.
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get backupChooseDestination;

  /// Button label to pick backup archive file for restore.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get backupSelectBackupFile;

  /// SnackBar notification when backup file is deleted.
  ///
  /// In en, this message translates to:
  /// **'Backup deleted'**
  String get backupDeleteSuccess;

  /// Progress dialog label during backup export.
  ///
  /// In en, this message translates to:
  /// **'Exporting backup...'**
  String get backupExportInProgress;

  /// Progress dialog label during backup restore.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup...'**
  String get backupImportInProgress;

  /// Title for backup health dashboard.
  ///
  /// In en, this message translates to:
  /// **'Backup Health Dashboard'**
  String get backupHealthDashboardTitle;

  /// Status badge label for healthy backup system.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get backupHealthStatusHealthy;

  /// Status badge label when backup needs attention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get backupHealthStatusWarning;

  /// Status badge label when no backups have been created.
  ///
  /// In en, this message translates to:
  /// **'No Backups Created'**
  String get backupHealthStatusNoBackups;

  /// Header for backup execution diagnostic logs.
  ///
  /// In en, this message translates to:
  /// **'Execution Diagnostic Logs'**
  String get backupHealthLogsTitle;

  /// Label for manually triggered backup execution.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get backupHealthTriggerManual;

  /// Label for scheduled automated backup execution.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get backupHealthTriggerScheduled;

  /// Log entry status label for successful backup operation.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get backupHealthStatusSuccess;

  /// Log entry status label for failed backup operation.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get backupHealthStatusFailed;

  /// Navigation label or screen title for Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// Section header for theme and visual settings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Label for light/dark theme selection setting.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// Option label to follow system theme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsFollowSystem;

  /// Option label for explicit light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// Option label for explicit dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// Label for app language setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Option label for system default locale.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsLanguageSystem;

  /// Option label for English language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Option label for Malayalam language.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get settingsLanguageMalayalam;

  /// Label for keyboard shortcuts settings.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get settingsShortcuts;

  /// Menu label navigating to About screen.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get settingsAboutApp;

  /// Menu label navigating to Permissions disclosure screen.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// Section header emphasizing offline architecture.
  ///
  /// In en, this message translates to:
  /// **'Offline and private'**
  String get settingsOfflineTitle;

  /// Explanatory text describing local-only zero-network operational model.
  ///
  /// In en, this message translates to:
  /// **'This app works fully offline. Tasks, backups, and statistics stay on this device unless you export a local backup file.'**
  String get settingsOfflineBody;

  /// Title for permissions disclosure screen.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsLabel;

  /// Summary paragraph explaining permission model.
  ///
  /// In en, this message translates to:
  /// **'This app requires no explicit permissions. All access is implicit and confined to app-private directories or user-initiated actions.'**
  String get permissionsSummary;

  /// Category title for implicit permissions.
  ///
  /// In en, this message translates to:
  /// **'Implicit'**
  String get permissionsImplicit;

  /// Category title for explicit runtime permissions.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get permissionsExplicit;

  /// Statement confirming zero manifest network or intrusive runtime permissions.
  ///
  /// In en, this message translates to:
  /// **'This app declares zero permissions in the Android manifest for release builds. No runtime permission dialogs are shown.'**
  String get permissionsExplicitNone;

  /// Item title explaining app-private storage access.
  ///
  /// In en, this message translates to:
  /// **'App-private storage'**
  String get permissionsStorageTitle;

  /// Detailed explanation of sandbox database storage.
  ///
  /// In en, this message translates to:
  /// **'The SQLite database is stored in the app-private directory. No storage permission is needed because Android grants every app access to its own data folder.'**
  String get permissionsStorageBody;

  /// Item title explaining SAF system file picker integration.
  ///
  /// In en, this message translates to:
  /// **'File picker access'**
  String get permissionsFilePickerTitle;

  /// Detailed explanation of file picker permission model.
  ///
  /// In en, this message translates to:
  /// **'Backup export and import use the system file picker dialog. Access is granted per file by the user through the picker and requires no persistent permission.'**
  String get permissionsFilePickerBody;

  /// Item title explaining clock reading.
  ///
  /// In en, this message translates to:
  /// **'System clock'**
  String get permissionsSystemClockTitle;

  /// Detailed explanation of system clock access.
  ///
  /// In en, this message translates to:
  /// **'Used for time tracking, timestamps, and date calculations. Reading the system clock requires no permission.'**
  String get permissionsSystemClockBody;

  /// Item title explaining system text selection intent.
  ///
  /// In en, this message translates to:
  /// **'Text processing'**
  String get permissionsTextProcessingTitle;

  /// Detailed explanation of text intent processing.
  ///
  /// In en, this message translates to:
  /// **'Declared as an intent query so the system can handle text selection actions. This is a standard Flutter framework registration and requires no permission.'**
  String get permissionsTextProcessingBody;

  /// Title for About app screen.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// Headline banner text on About screen.
  ///
  /// In en, this message translates to:
  /// **'Private daily planning'**
  String get aboutHeadline;

  /// Summary paragraph describing app intent.
  ///
  /// In en, this message translates to:
  /// **'SreerajP ToDo is an offline-first daily task list and time tracker designed to keep your data on this device.'**
  String get aboutSummary;

  /// Feature card title for local storage.
  ///
  /// In en, this message translates to:
  /// **'Local-only data'**
  String get aboutLocalOnlyTitle;

  /// Feature description emphasizing zero-telemetry.
  ///
  /// In en, this message translates to:
  /// **'Tasks, recurrence rules, backups, and statistics stay on local storage. No cloud sync or telemetry is used.'**
  String get aboutLocalOnlyBody;

  /// Feature card title for encrypted backups.
  ///
  /// In en, this message translates to:
  /// **'Portable encrypted backups'**
  String get aboutBackupTitle;

  /// Feature description for AES-256 ZIP backups.
  ///
  /// In en, this message translates to:
  /// **'Backup export creates encrypted files that you can store anywhere you choose and restore later with your passphrase.'**
  String get aboutBackupBody;

  /// Feature card title for Unicode normalization.
  ///
  /// In en, this message translates to:
  /// **'Unicode-first input'**
  String get aboutUnicodeTitle;

  /// Feature description for NFC Unicode handling.
  ///
  /// In en, this message translates to:
  /// **'Titles and descriptions accept full Unicode text, including RTL scripts, emoji, and composed characters.'**
  String get aboutUnicodeBody;

  /// Feature card title for daily task workflow.
  ///
  /// In en, this message translates to:
  /// **'Built for daily flow'**
  String get aboutNavigationTitle;

  /// Feature description for account-free daily navigation.
  ///
  /// In en, this message translates to:
  /// **'Daily planning, statistics, recurring rules, and backups are available from the main navigation with no account setup.'**
  String get aboutNavigationBody;

  /// Label for author metadata field.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutAuthor;

  /// Author name. Proper noun, not translated.
  ///
  /// In en, this message translates to:
  /// **'Sreeraj P'**
  String get aboutAuthorName;

  /// Label for AI assistant credit.
  ///
  /// In en, this message translates to:
  /// **'AI assisted by'**
  String get aboutAiAssisted;

  /// Model names. Proper nouns, not translated.
  ///
  /// In en, this message translates to:
  /// **'Claude 4.6 & GPT 5.4'**
  String get aboutAiModels;

  /// Label for build date metadata field.
  ///
  /// In en, this message translates to:
  /// **'Build date'**
  String get aboutBuildDate;

  /// Label for version string.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutAppVersion;

  /// Footer message celebrating origin.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤ in India'**
  String get aboutMadeWithLoveIn;

  /// Tab label for daily aggregated overview on statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Daily Overview'**
  String get statsDailyOverview;

  /// Tab label for task specific overview on statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Per-Item Overview'**
  String get statsPerItemOverview;

  /// Dropdown label to filter statistics by task.
  ///
  /// In en, this message translates to:
  /// **'Choose task'**
  String get statsChooseTask;

  /// Filter preset option for 7-day range.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get statsLast7Days;

  /// Filter preset option for 30-day range.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get statsLast30Days;

  /// Filter preset option for all historical data.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsAllTime;

  /// Filter preset option for custom date range picker.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get statsCustomRange;

  /// Tooltip/button label to recalculate statistics.
  ///
  /// In en, this message translates to:
  /// **'Refresh statistics'**
  String get statsRefresh;

  /// Stat card label for total task count.
  ///
  /// In en, this message translates to:
  /// **'Total todos'**
  String get statsTotalTodos;

  /// Label for total accumulated duration.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statsTotal;

  /// Table column header for date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get statsDate;

  /// Table column header for task title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get statsTitle;

  /// Stat card label for number of days task appeared.
  ///
  /// In en, this message translates to:
  /// **'Appearances'**
  String get statsAppearances;

  /// Stat card label for average completed tasks per day.
  ///
  /// In en, this message translates to:
  /// **'Average completed/day'**
  String get statsAverageCompletedPerDay;

  /// Stat card label for average tracked time per day.
  ///
  /// In en, this message translates to:
  /// **'Average time/day'**
  String get statsAverageTimePerDay;

  /// Stat card label for completed tasks total time.
  ///
  /// In en, this message translates to:
  /// **'Productive time'**
  String get statsProductiveTime;

  /// Stat card label for dropped tasks total time.
  ///
  /// In en, this message translates to:
  /// **'Dropped time'**
  String get statsDroppedTime;

  /// Filter input hint on statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Search task titles'**
  String get statsSearchHint;

  /// Empty state text on daily statistics overview.
  ///
  /// In en, this message translates to:
  /// **'No statistics available for this date range'**
  String get statsNoDailyStats;

  /// Empty state text on per-item statistics overview.
  ///
  /// In en, this message translates to:
  /// **'No tracked tasks match the current filter'**
  String get statsNoPerItemStats;

  /// Instructional placeholder in task detail view.
  ///
  /// In en, this message translates to:
  /// **'Select a task to view its time history'**
  String get statsSelectTaskToViewHistory;

  /// Empty state message when selected task has zero tracked time segments.
  ///
  /// In en, this message translates to:
  /// **'No time history recorded for this task'**
  String get statsNoHistoryForTitle;

  /// Chart Y-axis label unit.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get statsMinutes;

  /// Button label for picking custom range start date.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get statsSelectStartDate;

  /// Button label for picking custom range end date.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get statsSelectEndDate;

  /// Button label to display time segment log.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get statsShowHistory;

  /// No description provided for @statsPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {totalPages}'**
  String statsPageOf(int currentPage, int totalPages);

  /// No description provided for @statsHistoryFor.
  ///
  /// In en, this message translates to:
  /// **'Time history: {title}'**
  String statsHistoryFor(String title);

  /// Error message when attempting to modify a past day task.
  ///
  /// In en, this message translates to:
  /// **'Cannot modify tasks from past dates.'**
  String get errorDayLocked;

  /// Error message when attempting to track time on a terminal state task.
  ///
  /// In en, this message translates to:
  /// **'Cannot add time segments to a completed or dropped task.'**
  String get errorCompletedLocked;

  /// Error message when title conflicts with an existing task on the same date.
  ///
  /// In en, this message translates to:
  /// **'A task with this title already exists for this date.'**
  String get errorDuplicateTitle;

  /// Error message when starting a second open timer segment for a task.
  ///
  /// In en, this message translates to:
  /// **'A time segment is already running for this task.'**
  String get errorSegmentAlreadyRunning;

  /// Error message when task lookup fails.
  ///
  /// In en, this message translates to:
  /// **'Task not found.'**
  String get errorTodoNotFound;

  /// Error message when backup schema is incompatible due to app version.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of the app. Please update.'**
  String get errorBackupVersionTooNew;

  /// Error message when backup archive verification fails.
  ///
  /// In en, this message translates to:
  /// **'The backup file is corrupted and cannot be restored.'**
  String get errorBackupCorrupted;

  /// Error message when attempting to port task to today or past date.
  ///
  /// In en, this message translates to:
  /// **'Port target date must be tomorrow or later.'**
  String get errorPortTargetMustBeFuture;

  /// Fallback error message for unexpected exceptions.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorGeneric;

  /// Retryable inline error banner message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Tap to retry.'**
  String get errorRetryableGeneric;

  /// Section title for sub-task checklist.
  ///
  /// In en, this message translates to:
  /// **'Sub-tasks'**
  String get subTasks;

  /// Action button label to add a new sub-task item.
  ///
  /// In en, this message translates to:
  /// **'Add sub-task'**
  String get addSubTask;

  /// Label prefix for task prerequisites.
  ///
  /// In en, this message translates to:
  /// **'Blocked by'**
  String get blockedBy;

  /// Header for prerequisite tasks list.
  ///
  /// In en, this message translates to:
  /// **'Prerequisite Tasks'**
  String get prerequisiteTasks;

  /// Warning message when starting/completing a blocked task.
  ///
  /// In en, this message translates to:
  /// **'Warning: Task is blocked by pending prerequisites'**
  String get blockedWarning;

  /// Title for morning intention setting section.
  ///
  /// In en, this message translates to:
  /// **'Morning Intention'**
  String get morningIntention;

  /// Title for evening reflection ritual section.
  ///
  /// In en, this message translates to:
  /// **'Evening Reflection'**
  String get eveningReflection;

  /// Header title on evening reflection screen.
  ///
  /// In en, this message translates to:
  /// **'Evening Reflection Ritual'**
  String get eveningReflectionTitle;

  /// Header for reflection screen productivity stats.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Productivity Summary'**
  String get reflectionSummaryTitle;

  /// Stat card label for total time on completed tasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Time'**
  String get completedTime;

  /// Stat card label for total time on dropped tasks.
  ///
  /// In en, this message translates to:
  /// **'Dropped Time'**
  String get droppedTime;

  /// Stat card label for task completion percentage.
  ///
  /// In en, this message translates to:
  /// **'Completion Ratio'**
  String get completionRatio;

  /// TextField placeholder for evening reflection notes.
  ///
  /// In en, this message translates to:
  /// **'Write a brief reflection on your day...'**
  String get reflectionNoteHint;

  /// SnackBar confirmation when reflection note is saved.
  ///
  /// In en, this message translates to:
  /// **'Daily reflection saved.'**
  String get reflectionSaved;

  /// Button label to cycle to next daily focus rule/intention.
  ///
  /// In en, this message translates to:
  /// **'Cycle Intention'**
  String get cycleIntention;

  /// Button label to launch evening reflection modal.
  ///
  /// In en, this message translates to:
  /// **'Start Reflection'**
  String get startReflection;

  /// Section header for daily mindful intentions.
  ///
  /// In en, this message translates to:
  /// **'Daily Focus Rules'**
  String get mindfulFocusRules;

  /// Default intention option 1.
  ///
  /// In en, this message translates to:
  /// **'Focus on single-tasking today; handle duty without extra emotional noise.'**
  String get defaultIntention1;

  /// Default intention option 2.
  ///
  /// In en, this message translates to:
  /// **'Prioritize steady progress over perfection; remain calm and persistent.'**
  String get defaultIntention2;

  /// Default intention option 3.
  ///
  /// In en, this message translates to:
  /// **'Accept changing circumstances with composure; single-thread your effort.'**
  String get defaultIntention3;

  /// Default intention option 4.
  ///
  /// In en, this message translates to:
  /// **'Direct your attention to what is within your control; release the rest.'**
  String get defaultIntention4;

  /// Default intention option 5.
  ///
  /// In en, this message translates to:
  /// **'Complete each segment with full presence before stepping to the next.'**
  String get defaultIntention5;

  /// Title for data handoff screen and menu item.
  ///
  /// In en, this message translates to:
  /// **'Data Handoff (JSON & MD)'**
  String get dataHandoffTitle;

  /// Button label to change date or setting.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// Header title on data handoff screen.
  ///
  /// In en, this message translates to:
  /// **'JSON & Markdown Data Handoff'**
  String get dataHandoffHeader;

  /// Sub-header summary on data handoff screen.
  ///
  /// In en, this message translates to:
  /// **'Ingest and export task lists, subtask checklists, and timecard summaries fully offline.'**
  String get dataHandoffSubtitle;

  /// Button label for JSON payload export.
  ///
  /// In en, this message translates to:
  /// **'Export JSON Data Payload'**
  String get exportJsonLabel;

  /// Description text for JSON payload export.
  ///
  /// In en, this message translates to:
  /// **'Exports tasks, subtasks, recurrence rules, time segments, and Markdown notes to a structured JSON file.'**
  String get exportJsonDesc;

  /// Button label for Markdown checklist export.
  ///
  /// In en, this message translates to:
  /// **'Export Markdown Checklist'**
  String get exportMarkdownLabel;

  /// Description text for Markdown checklist export.
  ///
  /// In en, this message translates to:
  /// **'Generates a clean Markdown checklist file (- [ ] / - [x]) and timecard summary.'**
  String get exportMarkdownDesc;

  /// Button label for picking and importing JSON or Markdown file.
  ///
  /// In en, this message translates to:
  /// **'Import JSON / Markdown File'**
  String get importFileLabel;

  /// Description text for file picker import.
  ///
  /// In en, this message translates to:
  /// **'Pick a .json or .md file from device storage to convert and merge into tasks.'**
  String get importFileDesc;

  /// Button label to open raw Markdown text paste dialog.
  ///
  /// In en, this message translates to:
  /// **'Paste Raw Markdown Text'**
  String get pasteMarkdownLabel;

  /// Description text for raw Markdown text paste.
  ///
  /// In en, this message translates to:
  /// **'Paste raw Markdown text containing - [ ] and - [x] checklist items to parse.'**
  String get pasteMarkdownDesc;

  /// Label for target date selector on data handoff screen.
  ///
  /// In en, this message translates to:
  /// **'Target Date for Data Handoff'**
  String get targetDateLabel;

  /// Title for Markdown text import dialog.
  ///
  /// In en, this message translates to:
  /// **'Paste Markdown Checklist Text'**
  String get markdownImportTitle;

  /// Section header for live preview of parsed Markdown tasks.
  ///
  /// In en, this message translates to:
  /// **'Parsed Tasks Preview'**
  String get parseMarkdownPreview;

  /// SnackBar success notification after importing payload.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported tasks.'**
  String get importSuccessMsg;

  /// SnackBar success notification after saving export file.
  ///
  /// In en, this message translates to:
  /// **'Export saved successfully to file.'**
  String get exportSuccessMsg;

  /// Title for local peer-to-peer Wi-Fi sync screen and menu item.
  ///
  /// In en, this message translates to:
  /// **'Local P2P Wi-Fi Sync'**
  String get wifiSyncTitle;

  /// Title for AirQR animated share screen and menu item.
  ///
  /// In en, this message translates to:
  /// **'AirQR Share Stream'**
  String get airQrShareTitle;

  /// Title for AirQR scan camera scanner and menu item.
  ///
  /// In en, this message translates to:
  /// **'AirQR Scan Camera'**
  String get airQrScanTitle;

  /// Tooltip for overflow dotted menu.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
