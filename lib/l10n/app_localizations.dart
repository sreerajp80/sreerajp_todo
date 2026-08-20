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

  /// Label for the optional note attached to a time segment.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get segmentNoteLabel;

  /// Placeholder text for the time segment note field.
  ///
  /// In en, this message translates to:
  /// **'What did you work on?'**
  String get segmentNoteHint;

  /// Tooltip and dialog title for editing a time segment note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editSegmentNote;

  /// Search result subtitle shown when the match came from a time segment note.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String matchedInNote(String note);

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

  /// Subtitle on the Appearance card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Theme mode, typography, and accent color'**
  String get settingsAppearanceSubtitle;

  /// Subtitle on the Language card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used across the app'**
  String get settingsLanguageSubtitle;

  /// Subtitle on the Backup card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Export or import an encrypted backup file'**
  String get settingsBackupSubtitle;

  /// Menu label navigating to Features showcase screen.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get settingsFeatures;

  /// Subtitle on the Features card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Explore all features of SreerajP ToDo'**
  String get settingsFeaturesSubtitle;

  /// Menu label navigating to Help Center screen.
  ///
  /// In en, this message translates to:
  /// **'Help & User Guides'**
  String get settingsHelp;

  /// Subtitle on the Help card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Guides on time tracking, sync, backups, and FAQs'**
  String get settingsHelpSubtitle;

  /// Subtitle on the About card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Version, credits, and app details'**
  String get settingsAboutSubtitle;

  /// Title of the Time tracking settings hub.
  ///
  /// In en, this message translates to:
  /// **'Time tracking'**
  String get settingsTimeTracking;

  /// Subtitle on the Time tracking card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Auto-stop, pause, Pomodoro, and how time is shown'**
  String get settingsTimeTrackingSubtitle;

  /// Title of the auto-stop settings page.
  ///
  /// In en, this message translates to:
  /// **'Auto-stop the timer'**
  String get trackingAutoStop;

  /// Subtitle on the auto-stop card.
  ///
  /// In en, this message translates to:
  /// **'Stop a timer that was left running'**
  String get trackingAutoStopSubtitle;

  /// Auto-stop option: never stop on its own.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get trackingAutoStopOff;

  /// Explains the never option.
  ///
  /// In en, this message translates to:
  /// **'A running timer keeps going until you stop it.'**
  String get trackingAutoStopOffDetail;

  /// Auto-stop option: stop at the end of the day.
  ///
  /// In en, this message translates to:
  /// **'At midnight'**
  String get trackingAutoStopMidnight;

  /// Explains the midnight option.
  ///
  /// In en, this message translates to:
  /// **'Stops at the end of the day so tracked time is not lost.'**
  String get trackingAutoStopMidnightDetail;

  /// Auto-stop option: stop at a chosen time.
  ///
  /// In en, this message translates to:
  /// **'At a set time'**
  String get trackingAutoStopCustom;

  /// Explains the custom time option.
  ///
  /// In en, this message translates to:
  /// **'Stops at the time you pick below.'**
  String get trackingAutoStopCustomDetail;

  /// Label for the custom auto-stop time picker.
  ///
  /// In en, this message translates to:
  /// **'Stop at'**
  String get trackingAutoStopTime;

  /// Honest note about the offline limit of auto-stop.
  ///
  /// In en, this message translates to:
  /// **'While the app is closed the timer cannot be stopped at that exact moment. It is corrected the next time you open the app.'**
  String get trackingAutoStopNote;

  /// Message shown when a timer was auto-stopped.
  ///
  /// In en, this message translates to:
  /// **'Timer stopped automatically'**
  String get trackingAutoStopped;

  /// Title of the timer behaviour settings page.
  ///
  /// In en, this message translates to:
  /// **'Timer behaviour'**
  String get trackingTimerBehaviour;

  /// Subtitle on the timer behaviour card.
  ///
  /// In en, this message translates to:
  /// **'One timer at a time, pause, screen, short segments'**
  String get trackingTimerBehaviourSubtitle;

  /// Switch label for the single timer rule.
  ///
  /// In en, this message translates to:
  /// **'Only one timer at a time'**
  String get trackingSingleTimer;

  /// Explains the single timer rule.
  ///
  /// In en, this message translates to:
  /// **'Starting a timer stops any timer running on another task.'**
  String get trackingSingleTimerDetail;

  /// Message saying how many other timers were stopped to make room for a new one.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Stopped {count} other running timer} other{Stopped {count} other running timers}}'**
  String trackingStoppedOtherCount(int count);

  /// Switch label for auto-pause on background.
  ///
  /// In en, this message translates to:
  /// **'Pause when the app is closed'**
  String get trackingAutoPause;

  /// Explains auto-pause on background.
  ///
  /// In en, this message translates to:
  /// **'Leaving the app pauses a running timer. Time already tracked is kept.'**
  String get trackingAutoPauseDetail;

  /// Switch label for the keep-screen-awake setting.
  ///
  /// In en, this message translates to:
  /// **'Keep the screen on'**
  String get trackingKeepScreenAwake;

  /// Explains the keep-screen-awake setting.
  ///
  /// In en, this message translates to:
  /// **'The screen stays on while a timer runs. Android only.'**
  String get trackingKeepScreenAwakeDetail;

  /// Title for the minimum segment length choice.
  ///
  /// In en, this message translates to:
  /// **'Shortest segment to keep'**
  String get trackingMinimumLength;

  /// Explains the minimum segment length rule.
  ///
  /// In en, this message translates to:
  /// **'A timer you stop sooner than this is thrown away, so a mis-tap does not clutter your log. Manual entries are never touched.'**
  String get trackingMinimumLengthDetail;

  /// Minimum segment length option: no limit.
  ///
  /// In en, this message translates to:
  /// **'Keep everything'**
  String get trackingMinimumOff;

  /// Minimum segment length option: 10 seconds.
  ///
  /// In en, this message translates to:
  /// **'Under 10 seconds'**
  String get trackingMinimum10s;

  /// Minimum segment length option: 30 seconds.
  ///
  /// In en, this message translates to:
  /// **'Under 30 seconds'**
  String get trackingMinimum30s;

  /// Minimum segment length option: 1 minute.
  ///
  /// In en, this message translates to:
  /// **'Under 1 minute'**
  String get trackingMinimum1m;

  /// Minimum segment length option: 5 minutes.
  ///
  /// In en, this message translates to:
  /// **'Under 5 minutes'**
  String get trackingMinimum5m;

  /// Message when a short segment was dropped.
  ///
  /// In en, this message translates to:
  /// **'Segment was too short and was not saved'**
  String get trackingSegmentDiscarded;

  /// Title of the Pomodoro settings page.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get trackingPomodoro;

  /// Subtitle on the Pomodoro card.
  ///
  /// In en, this message translates to:
  /// **'Focus blocks and breaks'**
  String get trackingPomodoroSubtitle;

  /// Switch label turning Pomodoro on.
  ///
  /// In en, this message translates to:
  /// **'Use focus blocks'**
  String get trackingPomodoroEnabled;

  /// Explains the Pomodoro switch.
  ///
  /// In en, this message translates to:
  /// **'A running timer becomes a work block that ends on its own.'**
  String get trackingPomodoroEnabledDetail;

  /// Label for the Pomodoro work block length.
  ///
  /// In en, this message translates to:
  /// **'Work block'**
  String get trackingPomodoroWork;

  /// Label for the Pomodoro short break length.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get trackingPomodoroShortBreak;

  /// Label for the Pomodoro long break length.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get trackingPomodoroLongBreak;

  /// Label for how many work blocks precede a long break.
  ///
  /// In en, this message translates to:
  /// **'Long break after'**
  String get trackingPomodoroBlocks;

  /// Switch label for Pomodoro auto-start.
  ///
  /// In en, this message translates to:
  /// **'Start the next block on its own'**
  String get trackingPomodoroAutoStart;

  /// Explains Pomodoro auto-start.
  ///
  /// In en, this message translates to:
  /// **'When off, each block waits for you to tap start.'**
  String get trackingPomodoroAutoStartDetail;

  /// Honest note about the in-app-only Pomodoro alert.
  ///
  /// In en, this message translates to:
  /// **'The alert only sounds while the app is open. This app sends no notifications, so a block that ends in the background makes no sound. The time is still counted correctly.'**
  String get trackingPomodoroNote;

  /// A length written in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} minute} other{{count} minutes}}'**
  String trackingMinutes(int count);

  /// A count of Pomodoro work blocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} work block} other{{count} work blocks}}'**
  String trackingBlocks(int count);

  /// Badge shown during a Pomodoro work block.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get trackingBlockWork;

  /// Badge shown during a Pomodoro short break.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get trackingBlockShortBreak;

  /// Badge shown during a Pomodoro long break.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get trackingBlockLongBreak;

  /// Shown when a Pomodoro block ended and waits for a tap.
  ///
  /// In en, this message translates to:
  /// **'Block finished'**
  String get trackingBlockDone;

  /// Button that starts the waiting Pomodoro block.
  ///
  /// In en, this message translates to:
  /// **'Start next block'**
  String get trackingStartNextBlock;

  /// Title of the time display settings page.
  ///
  /// In en, this message translates to:
  /// **'Time display'**
  String get trackingTimeDisplay;

  /// Subtitle on the time display card.
  ///
  /// In en, this message translates to:
  /// **'Rounding, format, and manual entry default'**
  String get trackingTimeDisplaySubtitle;

  /// Title for the rounding choice.
  ///
  /// In en, this message translates to:
  /// **'Rounding in reports'**
  String get trackingRounding;

  /// Explains that rounding is display only.
  ///
  /// In en, this message translates to:
  /// **'Changes only what is shown. Your saved times are never altered.'**
  String get trackingRoundingDetail;

  /// Rounding option: no rounding.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get trackingRoundingOff;

  /// Rounding option: nearest minute.
  ///
  /// In en, this message translates to:
  /// **'Nearest minute'**
  String get trackingRounding1m;

  /// Rounding option: nearest 5 minutes.
  ///
  /// In en, this message translates to:
  /// **'Nearest 5 minutes'**
  String get trackingRounding5m;

  /// Rounding option: nearest 15 minutes.
  ///
  /// In en, this message translates to:
  /// **'Nearest 15 minutes'**
  String get trackingRounding15m;

  /// Title for the duration format choice.
  ///
  /// In en, this message translates to:
  /// **'How times are written'**
  String get trackingFormat;

  /// Duration format option HH:MM:SS.
  ///
  /// In en, this message translates to:
  /// **'Hours, minutes, seconds'**
  String get trackingFormatHhmmss;

  /// Duration format option HH:MM.
  ///
  /// In en, this message translates to:
  /// **'Hours and minutes'**
  String get trackingFormatHhmm;

  /// Duration format option decimal hours.
  ///
  /// In en, this message translates to:
  /// **'Decimal hours'**
  String get trackingFormatDecimal;

  /// Note that the live timer keeps seconds.
  ///
  /// In en, this message translates to:
  /// **'A running timer always shows seconds.'**
  String get trackingFormatNote;

  /// Title for the manual entry default duration.
  ///
  /// In en, this message translates to:
  /// **'Manual entry length'**
  String get trackingManualDefault;

  /// Explains the manual entry default.
  ///
  /// In en, this message translates to:
  /// **'Picking a start time fills the end time this far ahead. You can still change it.'**
  String get trackingManualDefaultDetail;

  /// Manual entry default option: 15 minutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get trackingManual15m;

  /// Manual entry default option: 30 minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get trackingManual30m;

  /// Manual entry default option: 1 hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get trackingManual1h;

  /// Manual entry default option: 2 hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get trackingManual2h;

  /// Tooltip on the pause button.
  ///
  /// In en, this message translates to:
  /// **'Pause timer'**
  String get pauseTimer;

  /// Tooltip on the resume button.
  ///
  /// In en, this message translates to:
  /// **'Resume timer'**
  String get resumeTimer;

  /// Badge shown on a task whose timer is paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get timerPaused;

  /// Subtitle on the Permissions card in Settings.
  ///
  /// In en, this message translates to:
  /// **'What this app can and cannot access'**
  String get settingsPermissionsSubtitle;

  /// Subtitle on the Theme Mode card.
  ///
  /// In en, this message translates to:
  /// **'Choose Light, Dark, or follow the system'**
  String get appearanceThemeModeSubtitle;

  /// Title of the typography settings page and card.
  ///
  /// In en, this message translates to:
  /// **'Typography & Text Size'**
  String get appearanceTypography;

  /// Subtitle on the Typography card.
  ///
  /// In en, this message translates to:
  /// **'App font family and text size'**
  String get appearanceTypographySubtitle;

  /// Title of the accent colour settings page and card.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get appearanceAccentColor;

  /// Subtitle on the Accent Color card.
  ///
  /// In en, this message translates to:
  /// **'Presets, color wheel, and live preview'**
  String get appearanceAccentColorSubtitle;

  /// Helper text on the Theme Mode page.
  ///
  /// In en, this message translates to:
  /// **'System mode follows the dark mode setting of your device.'**
  String get themeModeHelp;

  /// Section label above the font list.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get typographyFontLabel;

  /// Section label above the text size choice.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get typographyTextSizeLabel;

  /// Latin sample text shown in the font preview.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox 0123'**
  String get typographySampleLatin;

  /// Malayalam sample text shown in the font preview.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം സുന്ദരമാണ്'**
  String get typographySampleMalayalam;

  /// Font option that keeps the platform default font.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get fontSystemDefault;

  /// Font family name. Proper noun, not translated.
  ///
  /// In en, this message translates to:
  /// **'Manjari'**
  String get fontManjari;

  /// Font family name. Proper noun, not translated.
  ///
  /// In en, this message translates to:
  /// **'Anek Malayalam'**
  String get fontAnekMalayalam;

  /// Font family name. Proper noun, not translated.
  ///
  /// In en, this message translates to:
  /// **'Noto Sans Malayalam'**
  String get fontNotoSansMalayalam;

  /// Text size option, 0.85x.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// Text size option, 1.0x.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textSizeDefault;

  /// Text size option, 1.15x.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// Text size option, 1.30x.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get textSizeLarger;

  /// Section label above the accent colour preview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get accentLivePreview;

  /// Section label above the preset colour swatches.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get accentPresets;

  /// Section label above the HSV colour wheel.
  ///
  /// In en, this message translates to:
  /// **'Custom color wheel'**
  String get accentCustomWheel;

  /// Text shown inside the accent colour preview chip.
  ///
  /// In en, this message translates to:
  /// **'Sample text'**
  String get accentSampleText;

  /// Note telling which theme the edited accent applies to.
  ///
  /// In en, this message translates to:
  /// **'This color is used while the app is in light mode.'**
  String get accentAppliesToLight;

  /// Note telling which theme the edited accent applies to.
  ///
  /// In en, this message translates to:
  /// **'This color is used while the app is in dark mode.'**
  String get accentAppliesToDark;

  /// Button that clears the light mode accent override.
  ///
  /// In en, this message translates to:
  /// **'Reset light mode color'**
  String get accentResetLight;

  /// Button that clears the dark mode accent override.
  ///
  /// In en, this message translates to:
  /// **'Reset dark mode color'**
  String get accentResetDark;

  /// Helper note under the accent colour controls.
  ///
  /// In en, this message translates to:
  /// **'Text contrast is adjusted automatically for readability.'**
  String get accentContrastNote;

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

  /// Label for the build number metadata field.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get aboutBuildNumber;

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

  /// Title of the Task defaults settings hub.
  ///
  /// In en, this message translates to:
  /// **'Task defaults'**
  String get settingsTaskDefaults;

  /// Subtitle on the Task defaults card in Settings.
  ///
  /// In en, this message translates to:
  /// **'New task values, day list order, confirmations and carry-over'**
  String get settingsTaskDefaultsSubtitle;

  /// Title of the New task defaults page.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get defaultsNewTask;

  /// Subtitle of the New task defaults page.
  ///
  /// In en, this message translates to:
  /// **'Status, priority and target time a new task starts with'**
  String get defaultsNewTaskSubtitle;

  /// Title of the Day list defaults page.
  ///
  /// In en, this message translates to:
  /// **'Day list'**
  String get defaultsDayList;

  /// Subtitle of the Day list defaults page.
  ///
  /// In en, this message translates to:
  /// **'Order, and whether finished tasks are shown'**
  String get defaultsDayListSubtitle;

  /// Title of the Task actions defaults page.
  ///
  /// In en, this message translates to:
  /// **'Task actions'**
  String get defaultsTaskActions;

  /// Subtitle of the Task actions defaults page.
  ///
  /// In en, this message translates to:
  /// **'Confirmations and carrying tasks over to a new day'**
  String get defaultsTaskActionsSubtitle;

  /// Title of the Autocomplete defaults page.
  ///
  /// In en, this message translates to:
  /// **'Autocomplete'**
  String get defaultsAutocomplete;

  /// Subtitle of the Autocomplete defaults page.
  ///
  /// In en, this message translates to:
  /// **'Title suggestions while you type'**
  String get defaultsAutocompleteSubtitle;

  /// Header of the default status choice list.
  ///
  /// In en, this message translates to:
  /// **'Default status'**
  String get defaultsStatusTitle;

  /// Help line under the default status header.
  ///
  /// In en, this message translates to:
  /// **'The status a new task starts in.'**
  String get defaultsStatusSubtitle;

  /// Help line for the pending default status option.
  ///
  /// In en, this message translates to:
  /// **'The normal choice. The task waits until you start it.'**
  String get defaultsStatusPendingDetail;

  /// Help line for the working default status option.
  ///
  /// In en, this message translates to:
  /// **'The task opens as working. No timer is started.'**
  String get defaultsStatusWorkingDetail;

  /// Header of the default priority choice list.
  ///
  /// In en, this message translates to:
  /// **'Default priority'**
  String get defaultsPriorityTitle;

  /// Help line under the default priority header.
  ///
  /// In en, this message translates to:
  /// **'The priority a new task starts with.'**
  String get defaultsPrioritySubtitle;

  /// Header of the default target time choice list.
  ///
  /// In en, this message translates to:
  /// **'Default target time'**
  String get defaultsTargetTitle;

  /// Help line under the default target time header.
  ///
  /// In en, this message translates to:
  /// **'How long a new task is expected to take. You can change it on any task.'**
  String get defaultsTargetSubtitle;

  /// Option label for no default target time.
  ///
  /// In en, this message translates to:
  /// **'No target'**
  String get defaultsTargetNone;

  /// Priority level name.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Priority level name.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// Priority level name.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Priority level name.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// Field label for the priority of a task.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// Field label for the target time of a task.
  ///
  /// In en, this message translates to:
  /// **'Target time'**
  String get targetTimeLabel;

  /// Help line under the target time field.
  ///
  /// In en, this message translates to:
  /// **'Leave both at zero for no target.'**
  String get targetTimeHint;

  /// Label of the hours box in the target time field.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get targetHoursLabel;

  /// Label of the minutes box in the target time field.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get targetMinutesLabel;

  /// Tracked time against the target on a task tile.
  ///
  /// In en, this message translates to:
  /// **'{tracked} of {target}'**
  String targetProgressLabel(String target, String tracked);

  /// Shown when tracked time has passed the target.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String targetOverBy(String amount);

  /// Header of the default sort choice list.
  ///
  /// In en, this message translates to:
  /// **'Default order'**
  String get defaultsSortTitle;

  /// Help line under the default order header.
  ///
  /// In en, this message translates to:
  /// **'The order the day list opens in.'**
  String get defaultsSortSubtitle;

  /// Switch label for saving the sort chosen from the day list.
  ///
  /// In en, this message translates to:
  /// **'Remember the last order I pick'**
  String get defaultsRememberSort;

  /// Help line for the remember-sort switch.
  ///
  /// In en, this message translates to:
  /// **'Changing the order from the day list also saves it as the default.'**
  String get defaultsRememberSortDetail;

  /// Switch label for showing completed tasks in the day list.
  ///
  /// In en, this message translates to:
  /// **'Show completed tasks'**
  String get defaultsShowCompleted;

  /// Help line for the show completed switch.
  ///
  /// In en, this message translates to:
  /// **'Turn off to hide tasks you have finished.'**
  String get defaultsShowCompletedDetail;

  /// Switch label for showing dropped tasks in the day list.
  ///
  /// In en, this message translates to:
  /// **'Show dropped tasks'**
  String get defaultsShowDropped;

  /// Help line for the show dropped switch.
  ///
  /// In en, this message translates to:
  /// **'Turn off to hide tasks you have given up.'**
  String get defaultsShowDroppedDetail;

  /// Switch label for pushing finished tasks below the rest.
  ///
  /// In en, this message translates to:
  /// **'Move finished tasks to the bottom'**
  String get defaultsSinkFinished;

  /// Help line for the sink finished switch.
  ///
  /// In en, this message translates to:
  /// **'Completed, dropped and ported tasks sit below the rest. Drag to reorder then works only among unfinished tasks.'**
  String get defaultsSinkFinishedDetail;

  /// Line shown at the bottom of the day list when a filter hides tasks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 finished task hidden} other{{count} finished tasks hidden}}'**
  String hiddenTasksCount(num count);

  /// Button that reveals hidden finished tasks for this visit.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showHiddenTasks;

  /// Switch label for confirming a complete action.
  ///
  /// In en, this message translates to:
  /// **'Ask before completing'**
  String get defaultsConfirmComplete;

  /// Help line for the confirm complete switch.
  ///
  /// In en, this message translates to:
  /// **'Show a short question before a task is marked complete.'**
  String get defaultsConfirmCompleteDetail;

  /// Switch label for confirming a drop action.
  ///
  /// In en, this message translates to:
  /// **'Ask before dropping'**
  String get defaultsConfirmDrop;

  /// Help line for the confirm drop switch.
  ///
  /// In en, this message translates to:
  /// **'Show a short question before a task is dropped.'**
  String get defaultsConfirmDropDetail;

  /// Title of the confirm complete dialog.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete?'**
  String get confirmCompleteTitle;

  /// Confirmation dialog body text when completing a task.
  ///
  /// In en, this message translates to:
  /// **'This task will be marked as complete. Any running timer is stopped.'**
  String get confirmCompleteBody;

  /// Switch label for the carry-over prompt.
  ///
  /// In en, this message translates to:
  /// **'Ask to carry over unfinished tasks'**
  String get defaultsCarryOver;

  /// Help line for the carry-over switch.
  ///
  /// In en, this message translates to:
  /// **'The first time you open a new day, offer to copy unfinished tasks forward.'**
  String get defaultsCarryOverDetail;

  /// Header of the carry-over look-back choice list.
  ///
  /// In en, this message translates to:
  /// **'How far back to look'**
  String get defaultsCarryOverLookBackTitle;

  /// Look-back option label.
  ///
  /// In en, this message translates to:
  /// **'Previous day only'**
  String get defaultsCarryOverPreviousDay;

  /// Look-back option label.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get defaultsCarryOverLastSevenDays;

  /// Title of the carry-over sheet.
  ///
  /// In en, this message translates to:
  /// **'Carry over unfinished tasks'**
  String get carryOverTitle;

  /// Body line of the carry-over sheet.
  ///
  /// In en, this message translates to:
  /// **'These tasks were not finished. Pick the ones to copy to today.'**
  String get carryOverBody;

  /// Button that copies the ticked tasks.
  ///
  /// In en, this message translates to:
  /// **'Carry over'**
  String get carryOverAction;

  /// Button that closes the carry-over sheet.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get carryOverNotNow;

  /// Button that turns the carry-over prompt off.
  ///
  /// In en, this message translates to:
  /// **'Do not ask again'**
  String get carryOverNeverAsk;

  /// Button that ticks every task in the carry-over sheet.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get carryOverSelectAll;

  /// Button that unticks every task in the carry-over sheet.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get carryOverClearAll;

  /// SnackBar shown after a carry-over.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task carried over} other{{count} tasks carried over}}'**
  String carryOverDone(num count);

  /// SnackBar part for duplicates skipped during carry-over.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 task skipped, it already exists today} other{{count} tasks skipped, they already exist today}}'**
  String carryOverSkipped(num count);

  /// Switch label for title autocomplete.
  ///
  /// In en, this message translates to:
  /// **'Suggest titles while typing'**
  String get defaultsAutocompleteEnabled;

  /// Help line for the autocomplete switch.
  ///
  /// In en, this message translates to:
  /// **'Turn off to stop reading past titles as you type.'**
  String get defaultsAutocompleteEnabledDetail;

  /// Header of the suggestion count choice list.
  ///
  /// In en, this message translates to:
  /// **'How many suggestions'**
  String get defaultsSuggestionCountTitle;

  /// Suggestion count option label.
  ///
  /// In en, this message translates to:
  /// **'{count} suggestions'**
  String suggestionCountValue(num count);

  /// Sort menu item for priority order.
  ///
  /// In en, this message translates to:
  /// **'Priority (high first)'**
  String get sortPriorityHigh;

  /// Settings card title for the date and time group.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get settingsDateTime;

  /// Settings card subtitle for the date and time group.
  ///
  /// In en, this message translates to:
  /// **'Week start, clock, date format, day start, working days'**
  String get settingsDateTimeSubtitle;

  /// Date & time page link: week start.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get dateTimeWeekStart;

  /// Subtitle for the week start link.
  ///
  /// In en, this message translates to:
  /// **'Which day the calendar starts on'**
  String get dateTimeWeekStartSubtitle;

  /// Date & time page link: clock format.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get dateTimeClock;

  /// Subtitle for the clock link.
  ///
  /// In en, this message translates to:
  /// **'12-hour or 24-hour times'**
  String get dateTimeClockSubtitle;

  /// Date & time page link: date format.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateTimeDateFormat;

  /// Subtitle for the date format link.
  ///
  /// In en, this message translates to:
  /// **'How dates are written'**
  String get dateTimeDateFormatSubtitle;

  /// Date & time page link: day start hour.
  ///
  /// In en, this message translates to:
  /// **'Day start'**
  String get dateTimeDayStart;

  /// Subtitle for the day start link.
  ///
  /// In en, this message translates to:
  /// **'When a new day begins for you'**
  String get dateTimeDayStartSubtitle;

  /// Date & time page link: working days.
  ///
  /// In en, this message translates to:
  /// **'Working days'**
  String get dateTimeWorkingDays;

  /// Subtitle for the working days link.
  ///
  /// In en, this message translates to:
  /// **'Days counted in statistics'**
  String get dateTimeWorkingDaysSubtitle;

  /// Header of the week start choice list.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get weekStartTitle;

  /// Explains where the week start is used.
  ///
  /// In en, this message translates to:
  /// **'Used by the calendar in the day list.'**
  String get weekStartSubtitle;

  /// Week start option: use the device locale.
  ///
  /// In en, this message translates to:
  /// **'Follow the device'**
  String get weekStartSystem;

  /// Header of the clock format choice list.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get clockFormatTitle;

  /// Explains where the clock format is used.
  ///
  /// In en, this message translates to:
  /// **'Used everywhere a time of day is shown.'**
  String get clockFormatSubtitle;

  /// Clock option: use the device locale.
  ///
  /// In en, this message translates to:
  /// **'Follow the device'**
  String get clockFormatSystem;

  /// Clock option: 12-hour times.
  ///
  /// In en, this message translates to:
  /// **'12-hour'**
  String get clockFormat12;

  /// Clock option: 24-hour times.
  ///
  /// In en, this message translates to:
  /// **'24-hour'**
  String get clockFormat24;

  /// Header of the date format choice list.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormatTitle;

  /// Explains where the date format is used.
  ///
  /// In en, this message translates to:
  /// **'Used everywhere a date is shown.'**
  String get dateFormatSubtitle;

  /// Date format option: the locale long form.
  ///
  /// In en, this message translates to:
  /// **'Follow the device (long)'**
  String get dateFormatSystem;

  /// Date format option: the locale short form.
  ///
  /// In en, this message translates to:
  /// **'Follow the device (short)'**
  String get dateFormatSystemShort;

  /// Date format option: 19/08/2026.
  ///
  /// In en, this message translates to:
  /// **'Day/Month/Year'**
  String get dateFormatDayMonthYear;

  /// Date format option: 08/19/2026.
  ///
  /// In en, this message translates to:
  /// **'Month/Day/Year'**
  String get dateFormatMonthDayYear;

  /// Date format option: 19 Aug 2026.
  ///
  /// In en, this message translates to:
  /// **'Day Month Year'**
  String get dateFormatDayMonthNameYear;

  /// Date format option: 2026-08-19.
  ///
  /// In en, this message translates to:
  /// **'Year-Month-Day'**
  String get dateFormatIso;

  /// Header of the day start hour choice list.
  ///
  /// In en, this message translates to:
  /// **'A new day begins at'**
  String get dayStartTitle;

  /// Explains what the day start hour is for.
  ///
  /// In en, this message translates to:
  /// **'Pick a later hour if you often work past midnight.'**
  String get dayStartSubtitle;

  /// Day start option for hour zero.
  ///
  /// In en, this message translates to:
  /// **'Midnight (normal)'**
  String get dayStartMidnight;

  /// Header of the day start explanation card.
  ///
  /// In en, this message translates to:
  /// **'What this changes'**
  String get dayStartExplainTitle;

  /// Long explanation of the day start hour.
  ///
  /// In en, this message translates to:
  /// **'With a later day start, the hours after midnight still count as the day before. Your task list, the day lock and your time totals all follow this. Nothing already saved is moved or changed.'**
  String get dayStartExplainBody;

  /// Shows which date the app currently considers today.
  ///
  /// In en, this message translates to:
  /// **'Right now the app treats today as {date}.'**
  String dayStartCurrentDay(String date);

  /// Header of the working days card.
  ///
  /// In en, this message translates to:
  /// **'Working days'**
  String get workingDaysTitle;

  /// Explains what working days are for.
  ///
  /// In en, this message translates to:
  /// **'Statistics use only these days when working out averages.'**
  String get workingDaysSubtitle;

  /// Button that restores the default working days.
  ///
  /// In en, this message translates to:
  /// **'Reset to Monday to Friday'**
  String get workingDaysReset;

  /// Warning when the user turned every day off.
  ///
  /// In en, this message translates to:
  /// **'No working days are picked, so averages fall back to all seven days.'**
  String get workingDaysNoneWarning;

  /// Settings card title for the security group.
  ///
  /// In en, this message translates to:
  /// **'Security & privacy'**
  String get settingsSecurity;

  /// Settings card subtitle for the security group.
  ///
  /// In en, this message translates to:
  /// **'App lock, auto-lock, screen privacy, database key'**
  String get settingsSecuritySubtitle;

  /// Security page link: app lock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get securityAppLock;

  /// Subtitle for the app lock link.
  ///
  /// In en, this message translates to:
  /// **'Ask for a PIN, password or your phone lock'**
  String get securityAppLockSubtitle;

  /// Security page link: auto-lock delay.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get securityAutoLock;

  /// Subtitle for the auto-lock link.
  ///
  /// In en, this message translates to:
  /// **'How long the app may stay open in the background'**
  String get securityAutoLockSubtitle;

  /// Security page link: database key rotation.
  ///
  /// In en, this message translates to:
  /// **'Database key'**
  String get securityDatabaseKey;

  /// Subtitle for the database key link.
  ///
  /// In en, this message translates to:
  /// **'Give your data a brand new encryption key'**
  String get securityDatabaseKeySubtitle;

  /// Header of the screen privacy card.
  ///
  /// In en, this message translates to:
  /// **'Screen privacy'**
  String get securityScreenPrivacy;

  /// Switch that turns on the secure window flag.
  ///
  /// In en, this message translates to:
  /// **'Hide the app in recent apps'**
  String get securitySecureScreen;

  /// Explains the secure window flag.
  ///
  /// In en, this message translates to:
  /// **'The app preview stays blank when you switch apps, and screenshots are blocked. Android only.'**
  String get securitySecureScreenDetail;

  /// Note shown when the secure flag cannot be used.
  ///
  /// In en, this message translates to:
  /// **'This is an Android setting. It does nothing on this device.'**
  String get securitySecureScreenUnsupported;

  /// Explains why there is no notification privacy setting.
  ///
  /// In en, this message translates to:
  /// **'The app sends no notifications at all, so there are no task titles to hide there. The setting above covers the recent-apps preview instead.'**
  String get securityNotificationsNote;

  /// Header of the app lock mode choice list.
  ///
  /// In en, this message translates to:
  /// **'How to unlock'**
  String get appLockModeTitle;

  /// Explains when the lock is asked for.
  ///
  /// In en, this message translates to:
  /// **'Asked for when you open the app.'**
  String get appLockModeSubtitle;

  /// App lock option: no lock at all.
  ///
  /// In en, this message translates to:
  /// **'No lock'**
  String get appLockOff;

  /// App lock option: a digits-only code.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get appLockPin;

  /// App lock option: a free-text password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appLockPassword;

  /// App lock option: the device unlock screen.
  ///
  /// In en, this message translates to:
  /// **'Phone screen lock'**
  String get appLockDeviceCredential;

  /// Explains the device unlock option.
  ///
  /// In en, this message translates to:
  /// **'Uses your fingerprint, face or phone PIN.'**
  String get appLockDeviceCredentialDetail;

  /// Shown when the device has no screen lock.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock on your phone first.'**
  String get appLockDeviceUnavailable;

  /// Title of the PIN setup sheet.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get appLockSetPin;

  /// Title of the password setup sheet.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get appLockSetPassword;

  /// Label of the first secret field.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get appLockNewSecret;

  /// Label of the confirmation field.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get appLockConfirmSecret;

  /// Button that opens the change sheet.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get appLockChange;

  /// Confirmation after a lock is set.
  ///
  /// In en, this message translates to:
  /// **'App lock is on.'**
  String get appLockSaved;

  /// Confirmation after a lock is removed.
  ///
  /// In en, this message translates to:
  /// **'App lock is off.'**
  String get appLockRemoved;

  /// Header of the forgotten-secret warning.
  ///
  /// In en, this message translates to:
  /// **'There is no way back in'**
  String get appLockWarningTitle;

  /// Warns that a forgotten secret cannot be recovered.
  ///
  /// In en, this message translates to:
  /// **'Nothing about your PIN or password leaves this device, and nothing can recover it. If you forget it, the only way back into the app is to reinstall it, which erases your data. Keep a backup.'**
  String get appLockWarningBody;

  /// Error when the secret field is empty.
  ///
  /// In en, this message translates to:
  /// **'Type something first.'**
  String get appLockErrorEmpty;

  /// Error when a PIN has non-digits.
  ///
  /// In en, this message translates to:
  /// **'A PIN can only hold digits.'**
  String get appLockErrorNotDigits;

  /// Error when a PIN is too short.
  ///
  /// In en, this message translates to:
  /// **'A PIN needs at least 4 digits.'**
  String get appLockErrorPinTooShort;

  /// Error when a PIN is too long.
  ///
  /// In en, this message translates to:
  /// **'A PIN can hold at most 8 digits.'**
  String get appLockErrorPinTooLong;

  /// Error when a password is too short.
  ///
  /// In en, this message translates to:
  /// **'A password needs at least 6 characters.'**
  String get appLockErrorPasswordTooShort;

  /// Error when the confirmation does not match.
  ///
  /// In en, this message translates to:
  /// **'The two entries do not match.'**
  String get appLockErrorMismatch;

  /// Header of the auto-lock choice list.
  ///
  /// In en, this message translates to:
  /// **'Lock again after'**
  String get autoLockTitle;

  /// Explains what the auto-lock delay measures.
  ///
  /// In en, this message translates to:
  /// **'Counted from the moment you leave the app.'**
  String get autoLockSubtitle;

  /// Auto-lock option: lock as soon as the app leaves the screen.
  ///
  /// In en, this message translates to:
  /// **'At once'**
  String get autoLockImmediately;

  /// Auto-lock option.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get autoLock30Seconds;

  /// Auto-lock option.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get autoLock1Minute;

  /// Auto-lock option.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get autoLock5Minutes;

  /// Auto-lock option.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get autoLock15Minutes;

  /// Auto-lock option: never re-lock while running.
  ///
  /// In en, this message translates to:
  /// **'Only when the app restarts'**
  String get autoLockNever;

  /// Note shown when auto-lock has no lock to apply.
  ///
  /// In en, this message translates to:
  /// **'Turn the app lock on first.'**
  String get autoLockNeedsLock;

  /// Header of the database key page.
  ///
  /// In en, this message translates to:
  /// **'New database key'**
  String get databaseKeyTitle;

  /// Explains what key rotation does.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored encrypted with a key held by this device. Rotating it writes the whole database again under a brand new key.'**
  String get databaseKeyBody;

  /// Warns to back up first.
  ///
  /// In en, this message translates to:
  /// **'Take a backup before you start. If anything goes wrong part way, the backup is the only way back.'**
  String get databaseKeyBackupFirst;

  /// Clarifies that backups keep their own passphrase.
  ///
  /// In en, this message translates to:
  /// **'Backup files are not affected. They keep the passphrase you exported them with.'**
  String get databaseKeyOldBackups;

  /// Button that starts the rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotate the key now'**
  String get databaseKeyRotate;

  /// Title of the rotation confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Rotate the database key?'**
  String get databaseKeyConfirmTitle;

  /// Body of the rotation confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This rewrites your whole database under a new key. Do not close the app while it runs.'**
  String get databaseKeyConfirmBody;

  /// Shown while the rotation runs.
  ///
  /// In en, this message translates to:
  /// **'Rotating the key. Please wait.'**
  String get databaseKeyWorking;

  /// Shown after a successful rotation.
  ///
  /// In en, this message translates to:
  /// **'The database has a new key.'**
  String get databaseKeyDone;

  /// Shown after a failed rotation.
  ///
  /// In en, this message translates to:
  /// **'The key was not changed. Your data is untouched and still opens with the old key.'**
  String get databaseKeyFailed;

  /// Title of the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockScreenTitle;

  /// Prompt on the lock screen for a PIN.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockScreenEnterPin;

  /// Prompt on the lock screen for a password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get lockScreenEnterPassword;

  /// Button that submits the secret.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockScreenUnlock;

  /// Shown after a wrong entry.
  ///
  /// In en, this message translates to:
  /// **'That did not match. Try again.'**
  String get lockScreenWrong;

  /// Shown while the retry wait is running.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait {seconds} seconds.'**
  String lockScreenWait(int seconds);

  /// Button that opens the device unlock screen.
  ///
  /// In en, this message translates to:
  /// **'Use my phone lock'**
  String get lockScreenUseDeviceLock;

  /// Title shown on the device unlock screen.
  ///
  /// In en, this message translates to:
  /// **'Unlock SreerajP ToDo'**
  String get lockScreenDevicePrompt;

  /// Description shown on the device unlock screen.
  ///
  /// In en, this message translates to:
  /// **'Confirm it is you to open your tasks.'**
  String get lockScreenDeviceDescription;

  /// Shown when the device unlock was cancelled or failed.
  ///
  /// In en, this message translates to:
  /// **'That did not open the app.'**
  String get lockScreenDeviceFailed;

  /// Title of the full screen Focus view.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTitle;

  /// Tooltip on the button that opens the Focus view.
  ///
  /// In en, this message translates to:
  /// **'Open focus view'**
  String get focusOpen;

  /// Tooltip on the button that closes the Focus view.
  ///
  /// In en, this message translates to:
  /// **'Leave focus'**
  String get focusLeave;

  /// Label above the time the running timer has counted so far.
  ///
  /// In en, this message translates to:
  /// **'Running now'**
  String get focusRunningNow;

  /// Label above the total time tracked on the task.
  ///
  /// In en, this message translates to:
  /// **'Total tracked'**
  String get focusTotalTracked;

  /// Heading above the sub-task checklist in the Focus view.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get focusSteps;

  /// Shown in the Focus view when the task has no sub-tasks.
  ///
  /// In en, this message translates to:
  /// **'This task has no steps.'**
  String get focusNoSteps;

  /// Shown in the Focus view when no timer is running on the task.
  ///
  /// In en, this message translates to:
  /// **'The timer is not running.'**
  String get focusNotRunning;

  /// Countdown to the next focus nudge.
  ///
  /// In en, this message translates to:
  /// **'Next nudge in {time}'**
  String focusNextNudge(String time);

  /// Shown in the Focus view when the nudge is switched off.
  ///
  /// In en, this message translates to:
  /// **'Nudges are off'**
  String get focusNudgesOff;

  /// Title of the Focus mode settings page.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get trackingFocusMode;

  /// Subtitle on the Focus mode card.
  ///
  /// In en, this message translates to:
  /// **'Full screen focus view and the nudge while a timer runs'**
  String get trackingFocusModeSubtitle;

  /// Heading of the nudge setting.
  ///
  /// In en, this message translates to:
  /// **'Nudge while a timer runs'**
  String get trackingFocusPulse;

  /// Nudge mode: nothing happens.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get trackingFocusPulseOff;

  /// Nudge mode: vibration only.
  ///
  /// In en, this message translates to:
  /// **'Vibration only'**
  String get trackingFocusPulseVibration;

  /// Nudge mode: sound only.
  ///
  /// In en, this message translates to:
  /// **'Sound only'**
  String get trackingFocusPulseSound;

  /// Nudge mode: vibration and sound.
  ///
  /// In en, this message translates to:
  /// **'Vibration and sound'**
  String get trackingFocusPulseBoth;

  /// Label of the stepper that sets the gap between nudges.
  ///
  /// In en, this message translates to:
  /// **'Nudge every'**
  String get trackingFocusPulseEvery;

  /// Heading of the Focus view settings group.
  ///
  /// In en, this message translates to:
  /// **'Focus view'**
  String get trackingFocusView;

  /// Switch that hides the status bar in the Focus view.
  ///
  /// In en, this message translates to:
  /// **'Immersive full screen'**
  String get trackingFocusImmersive;

  /// Detail under the immersive switch.
  ///
  /// In en, this message translates to:
  /// **'Hide the status bar while the Focus view is open.'**
  String get trackingFocusImmersiveDetail;

  /// Note explaining that the nudge only works while the app is open.
  ///
  /// In en, this message translates to:
  /// **'The nudge only works while the app is open. This app sends no notifications, so nothing sounds in the background. Your time is still counted correctly.'**
  String get trackingFocusNote;

  /// Note explaining that the nudge is quiet while Pomodoro is on.
  ///
  /// In en, this message translates to:
  /// **'Focus blocks are on, so the nudge stays quiet. Pomodoro already sounds its own alert at the end of every block.'**
  String get trackingFocusPomodoroNote;

  /// Title of the voice task sheet.
  ///
  /// In en, this message translates to:
  /// **'Voice task'**
  String get voiceSheetTitle;

  /// Note under the voice sheet title explaining that it stays on the device.
  ///
  /// In en, this message translates to:
  /// **'Everything is worked out on this phone. Nothing is recorded and nothing is sent anywhere.'**
  String get voiceSheetOfflineNote;

  /// Label of the text box in the voice sheet.
  ///
  /// In en, this message translates to:
  /// **'Say or type one sentence'**
  String get voiceSheetFieldLabel;

  /// Example sentence shown under the voice sheet text box.
  ///
  /// In en, this message translates to:
  /// **'For example: Call the bank tomorrow at 10 am for 30 minutes'**
  String get voiceSheetExample;

  /// Language choice in the voice sheet.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get voiceLanguageEnglish;

  /// Language choice in the voice sheet.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get voiceLanguageMalayalam;

  /// Label under the microphone button before listening starts.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceTapToSpeak;

  /// Label under the microphone button while listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get voiceListening;

  /// Tooltip of the button that empties the voice sheet text box.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get voiceClear;

  /// Heading above the chips showing what the sentence meant.
  ///
  /// In en, this message translates to:
  /// **'Understood as'**
  String get voiceUnderstoodHeading;

  /// Chip shown when the sentence has no title left in it.
  ///
  /// In en, this message translates to:
  /// **'No title yet'**
  String get voiceNoTitle;

  /// Button that opens the create form with the voice reading filled in.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get voiceCreateTask;

  /// Shown when a spoken day was in the past and was moved to today.
  ///
  /// In en, this message translates to:
  /// **'That day has already passed, so today is used instead.'**
  String get voiceDateMovedToToday;

  /// Shown when the microphone permission was refused.
  ///
  /// In en, this message translates to:
  /// **'The microphone was not allowed. You can still type the sentence.'**
  String get voiceErrorPermission;

  /// Shown when the recogniser heard nothing it could read.
  ///
  /// In en, this message translates to:
  /// **'Nothing was heard. Try again, or type the sentence.'**
  String get voiceErrorNoMatch;

  /// Shown when the recogniser has no on-device language pack. This is also what a recogniser reports when it wanted the network.
  ///
  /// In en, this message translates to:
  /// **'This phone has no offline language pack for that language. Install one in your phone settings, or type the sentence.'**
  String get voiceErrorNoOfflineLanguage;

  /// Shown when the speech recogniser is already running.
  ///
  /// In en, this message translates to:
  /// **'The recogniser is busy. Try again in a moment.'**
  String get voiceErrorBusy;

  /// Shown for any other recogniser failure.
  ///
  /// In en, this message translates to:
  /// **'The microphone could not be used. You can still type the sentence.'**
  String get voiceErrorUnknown;

  /// Shown on a platform with no speech recogniser at all, such as Windows.
  ///
  /// In en, this message translates to:
  /// **'This device has no voice input. Type the sentence instead.'**
  String get voiceUnavailableDevice;

  /// Shown when Android reports no recognition service.
  ///
  /// In en, this message translates to:
  /// **'No speech app was found on this device. Type the sentence instead.'**
  String get voiceUnavailableNoRecogniser;

  /// Shown when no on-device recogniser can be pinned, so listening is refused to keep the app offline.
  ///
  /// In en, this message translates to:
  /// **'This device cannot recognise speech without going online, so the microphone stays off. Type the sentence instead.'**
  String get voiceUnavailableNoOffline;

  /// Shown when the microphone permission has not been granted yet.
  ///
  /// In en, this message translates to:
  /// **'The microphone needs your permission. Tap the microphone to be asked.'**
  String get voiceUnavailableNoPermission;

  /// Tooltip of the microphone button on the day list.
  ///
  /// In en, this message translates to:
  /// **'New task by voice'**
  String get voiceOpenTooltip;

  /// Settings switch that shows the microphone button on the day list.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInputSetting;

  /// Detail under the voice input switch.
  ///
  /// In en, this message translates to:
  /// **'Show a microphone button on the day list. It uses the offline recogniser already on your phone, and asks for the microphone the first time you use it. The sentence is read on this device.'**
  String get voiceInputSettingDetail;

  /// Note under the voice input switch making clear that typing works either way.
  ///
  /// In en, this message translates to:
  /// **'The sentence is always read on this device, whether you speak it or type it. Voice input only adds the microphone.'**
  String get voiceInputTypingNote;

  /// Permission entry title for the camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionsCameraTitle;

  /// Permission entry body for the camera.
  ///
  /// In en, this message translates to:
  /// **'Asked for only when you scan a QR code to move data between your own devices. No photo is ever saved.'**
  String get permissionsCameraBody;

  /// Permission entry title for the microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get permissionsMicrophoneTitle;

  /// Permission entry body for the microphone, explaining the offline guarantee.
  ///
  /// In en, this message translates to:
  /// **'Asked for only after you turn Voice input on and tap the microphone. The phone recogniser is always asked for its offline engine, and listening is refused rather than going online. No audio is recorded or kept.'**
  String get permissionsMicrophoneBody;

  /// Statement under the explicit permission list confirming there is no network permission.
  ///
  /// In en, this message translates to:
  /// **'These two are the only permissions this app asks for, and both are asked for only when you use the feature that needs them. The app declares no internet or network permission at all, so nothing it holds can leave this device on its own.'**
  String get permissionsExplicitNote;

  /// Note written into the description when the sentence named a time of day. A task has no time column of its own.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String voiceTimeNote(String time);
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
