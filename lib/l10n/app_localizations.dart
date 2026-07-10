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

  /// No description provided for @dailyList.
  ///
  /// In en, this message translates to:
  /// **'My ToDos'**
  String get dailyList;

  /// No description provided for @createTodo.
  ///
  /// In en, this message translates to:
  /// **'New Todo'**
  String get createTodo;

  /// No description provided for @editTodo.
  ///
  /// In en, this message translates to:
  /// **'Edit Todo'**
  String get editTodo;

  /// No description provided for @timeSegments.
  ///
  /// In en, this message translates to:
  /// **'Time Segments'**
  String get timeSegments;

  /// No description provided for @copyTodos.
  ///
  /// In en, this message translates to:
  /// **'Copy Todos'**
  String get copyTodos;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @recurringTasks.
  ///
  /// In en, this message translates to:
  /// **'Recurring Tasks'**
  String get recurringTasks;

  /// No description provided for @newRecurrence.
  ///
  /// In en, this message translates to:
  /// **'New Recurrence Rule'**
  String get newRecurrence;

  /// No description provided for @editRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurrence Rule'**
  String get editRecurrence;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get titleHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get descriptionHint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search todos...'**
  String get searchHint;

  /// No description provided for @noTodosForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTodosForDay;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @addFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Add your first task'**
  String get addFirstTask;

  /// No description provided for @noTasksTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks today'**
  String get noTasksTodayTitle;

  /// No description provided for @noTasksTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to start planning this day.'**
  String get noTasksTodayMessage;

  /// No description provided for @noTasksForPastDayMessage.
  ///
  /// In en, this message translates to:
  /// **'No tasks were recorded for this day.'**
  String get noTasksForPastDayMessage;

  /// No description provided for @searchTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your tasks'**
  String get searchTasksTitle;

  /// No description provided for @searchTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a title or description to search across days.'**
  String get searchTasksMessage;

  /// No description provided for @noStatisticsData.
  ///
  /// In en, this message translates to:
  /// **'Start tracking tasks to see your statistics'**
  String get noStatisticsData;

  /// No description provided for @noRecurringTasksDetailed.
  ///
  /// In en, this message translates to:
  /// **'No recurring tasks. Create one to automate task creation.'**
  String get noRecurringTasksDetailed;

  /// No description provided for @noSegmentsRecordedDetailed.
  ///
  /// In en, this message translates to:
  /// **'Track time or add a manual segment to see history here.'**
  String get noSegmentsRecordedDetailed;

  /// No description provided for @backupDirectory.
  ///
  /// In en, this message translates to:
  /// **'Backup folder'**
  String get backupDirectory;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @openCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get openCalendar;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @toggleSelection.
  ///
  /// In en, this message translates to:
  /// **'Toggle selection'**
  String get toggleSelection;

  /// No description provided for @openTaskActions.
  ///
  /// In en, this message translates to:
  /// **'Open task actions'**
  String get openTaskActions;

  /// No description provided for @lockedTask.
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

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @taskStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskStatus;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get statusWorking;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @statusPorted.
  ///
  /// In en, this message translates to:
  /// **'Ported'**
  String get statusPorted;

  /// No description provided for @completeAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// No description provided for @dropAction.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get dropAction;

  /// No description provided for @confirmDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop this task?'**
  String get confirmDrop;

  /// No description provided for @confirmDropBody.
  ///
  /// In en, this message translates to:
  /// **'This task will be marked as dropped. Time spent will be categorised as dropped time.'**
  String get confirmDropBody;

  /// No description provided for @confirmPort.
  ///
  /// In en, this message translates to:
  /// **'Port this task?'**
  String get confirmPort;

  /// No description provided for @confirmPortBody.
  ///
  /// In en, this message translates to:
  /// **'This task will be moved to the selected date.'**
  String get confirmPortBody;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This task and all its time segments will be permanently deleted.'**
  String get confirmDeleteBody;

  /// No description provided for @confirmDeleteRecurring.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring task?'**
  String get confirmDeleteRecurring;

  /// No description provided for @confirmDeleteRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'This task was created by a recurrence rule.'**
  String get confirmDeleteRecurringBody;

  /// No description provided for @deleteOnlyThis.
  ///
  /// In en, this message translates to:
  /// **'Delete only this one'**
  String get deleteOnlyThis;

  /// No description provided for @deleteThisAndFuture.
  ///
  /// In en, this message translates to:
  /// **'Delete this and future'**
  String get deleteThisAndFuture;

  /// No description provided for @deleteAllOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Delete all occurrences'**
  String get deleteAllOccurrences;

  /// No description provided for @allOccurrencesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All occurrences deleted'**
  String get allOccurrencesDeleted;

  /// No description provided for @futureOccurrencesDeleted.
  ///
  /// In en, this message translates to:
  /// **'This and future occurrences deleted'**
  String get futureOccurrencesDeleted;

  /// No description provided for @confirmBulkDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop selected tasks?'**
  String get confirmBulkDrop;

  /// No description provided for @confirmBulkDropBody.
  ///
  /// In en, this message translates to:
  /// **'All selected tasks will be marked as dropped.'**
  String get confirmBulkDropBody;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @selectTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Select target date'**
  String get selectTargetDate;

  /// No description provided for @completeAll.
  ///
  /// In en, this message translates to:
  /// **'Complete All'**
  String get completeAll;

  /// No description provided for @markDropped.
  ///
  /// In en, this message translates to:
  /// **'Mark Dropped'**
  String get markDropped;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @copyToAnotherDay.
  ///
  /// In en, this message translates to:
  /// **'Copy to another day'**
  String get copyToAnotherDay;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @copiedFrom.
  ///
  /// In en, this message translates to:
  /// **'Copied from'**
  String get copiedFrom;

  /// No description provided for @portedTo.
  ///
  /// In en, this message translates to:
  /// **'Ported to'**
  String get portedTo;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get startTimer;

  /// No description provided for @stopTimer.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get stopTimer;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timer running'**
  String get timerRunning;

  /// No description provided for @addManualSegment.
  ///
  /// In en, this message translates to:
  /// **'Add Manual Segment'**
  String get addManualSegment;

  /// No description provided for @manualSegmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Manual segment added'**
  String get manualSegmentAdded;

  /// No description provided for @segmentStart.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get segmentStart;

  /// No description provided for @segmentEnd.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get segmentEnd;

  /// No description provided for @segmentType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get segmentType;

  /// No description provided for @segmentDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get segmentDuration;

  /// No description provided for @segmentAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get segmentAuto;

  /// No description provided for @segmentManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get segmentManual;

  /// No description provided for @segmentRunning.
  ///
  /// In en, this message translates to:
  /// **'running...'**
  String get segmentRunning;

  /// No description provided for @segmentInterruptedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Auto-closed on app restart'**
  String get segmentInterruptedTooltip;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get totalTime;

  /// No description provided for @viewSegments.
  ///
  /// In en, this message translates to:
  /// **'Time Segments'**
  String get viewSegments;

  /// No description provided for @noSegments.
  ///
  /// In en, this message translates to:
  /// **'No time segments recorded'**
  String get noSegments;

  /// No description provided for @startBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'Start time must be before end time'**
  String get startBeforeEnd;

  /// No description provided for @segmentOverlap.
  ///
  /// In en, this message translates to:
  /// **'This segment overlaps with an existing one'**
  String get segmentOverlap;

  /// No description provided for @segmentMustBeSameDay.
  ///
  /// In en, this message translates to:
  /// **'Both times must fall within the same calendar day'**
  String get segmentMustBeSameDay;

  /// No description provided for @statusChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Status changed to'**
  String get statusChangedTo;

  /// No description provided for @undoStatusChange.
  ///
  /// In en, this message translates to:
  /// **'Status change undone'**
  String get undoStatusChange;

  /// No description provided for @bulkStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'tasks updated'**
  String get bulkStatusChanged;

  /// No description provided for @todoCreated.
  ///
  /// In en, this message translates to:
  /// **'Task created'**
  String get todoCreated;

  /// No description provided for @todoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get todoUpdated;

  /// No description provided for @todoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get todoDeleted;

  /// No description provided for @todoPorted.
  ///
  /// In en, this message translates to:
  /// **'Task ported'**
  String get todoPorted;

  /// No description provided for @todosCopied.
  ///
  /// In en, this message translates to:
  /// **'tasks copied'**
  String get todosCopied;

  /// No description provided for @todosSkipped.
  ///
  /// In en, this message translates to:
  /// **'skipped (duplicate title)'**
  String get todosSkipped;

  /// No description provided for @stepSelectItems.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get stepSelectItems;

  /// No description provided for @stepPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get stepPickDate;

  /// No description provided for @stepPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get stepPreview;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @copyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyConfirm;

  /// No description provided for @noItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one item'**
  String get noItemsSelected;

  /// No description provided for @willBeSkipped.
  ///
  /// In en, this message translates to:
  /// **'Already exists - will be skipped'**
  String get willBeSkipped;

  /// No description provided for @itemsToCopy.
  ///
  /// In en, this message translates to:
  /// **'items to copy'**
  String get itemsToCopy;

  /// No description provided for @itemsWillBeSkipped.
  ///
  /// In en, this message translates to:
  /// **'will be skipped'**
  String get itemsWillBeSkipped;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @sourceDate.
  ///
  /// In en, this message translates to:
  /// **'Source Date'**
  String get sourceDate;

  /// No description provided for @selectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a target date first'**
  String get selectDateFirst;

  /// No description provided for @viewTodo.
  ///
  /// In en, this message translates to:
  /// **'View Todo'**
  String get viewTodo;

  /// No description provided for @readOnlyPastDate.
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

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeatNone;

  /// No description provided for @repeatConfigure.
  ///
  /// In en, this message translates to:
  /// **'Repeat…'**
  String get repeatConfigure;

  /// No description provided for @recurrenceCreated.
  ///
  /// In en, this message translates to:
  /// **'Task and recurrence rule created'**
  String get recurrenceCreated;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @endsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get endsNever;

  /// No description provided for @endsOnDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get endsOnDate;

  /// No description provided for @endsAfterDays.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get endsAfterDays;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of week'**
  String get daysOfWeek;

  /// No description provided for @nextOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Next 5 occurrences'**
  String get nextOccurrences;

  /// No description provided for @noUpcomingOccurrences.
  ///
  /// In en, this message translates to:
  /// **'No upcoming occurrences'**
  String get noUpcomingOccurrences;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @sortTodos.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTodos;

  /// No description provided for @sortManual.
  ///
  /// In en, this message translates to:
  /// **'Manual order'**
  String get sortManual;

  /// No description provided for @sortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name A→Z'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name Z→A'**
  String get sortNameZA;

  /// No description provided for @sortCreatedOldest.
  ///
  /// In en, this message translates to:
  /// **'Created (oldest first)'**
  String get sortCreatedOldest;

  /// No description provided for @sortCreatedNewest.
  ///
  /// In en, this message translates to:
  /// **'Created (newest first)'**
  String get sortCreatedNewest;

  /// No description provided for @sortTimeMost.
  ///
  /// In en, this message translates to:
  /// **'Time spent (most first)'**
  String get sortTimeMost;

  /// No description provided for @sortTimeLeast.
  ///
  /// In en, this message translates to:
  /// **'Time spent (least first)'**
  String get sortTimeLeast;

  /// No description provided for @sortByStatus.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get sortByStatus;

  /// No description provided for @backupLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupLabel;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get backupExportTitle;

  /// No description provided for @backupImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get backupImportTitle;

  /// No description provided for @backupPassphraseLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup Passphrase'**
  String get backupPassphraseLabel;

  /// No description provided for @backupPassphraseConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passphrase'**
  String get backupPassphraseConfirmLabel;

  /// No description provided for @backupPassphraseMinLength.
  ///
  /// In en, this message translates to:
  /// **'Passphrase must be at least 8 characters'**
  String get backupPassphraseMinLength;

  /// No description provided for @backupPassphraseMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match'**
  String get backupPassphraseMismatch;

  /// No description provided for @backupPassphraseWarning.
  ///
  /// In en, this message translates to:
  /// **'If you forget this passphrase, the backup cannot be recovered. Write it down.'**
  String get backupPassphraseWarning;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to'**
  String get backupExportSuccess;

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace All Data?'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace ALL current data. This action cannot be undone.'**
  String get backupImportConfirmMessage;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get backupImportSuccess;

  /// No description provided for @backupImportWrongPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passphrase or corrupted backup file'**
  String get backupImportWrongPassphrase;

  /// No description provided for @backupImportVersionTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of the app. Please update.'**
  String get backupImportVersionTooNew;

  /// No description provided for @backupImportCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The backup file is corrupted and cannot be restored'**
  String get backupImportCorrupted;

  /// No description provided for @backupDeleteBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this backup?'**
  String get backupDeleteBackupConfirm;

  /// No description provided for @backupNoBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get backupNoBackupsFound;

  /// No description provided for @backupNoBackupsFoundDetailed.
  ///
  /// In en, this message translates to:
  /// **'No backups found. Export your first backup to keep your data safe.'**
  String get backupNoBackupsFoundDetailed;

  /// No description provided for @backupRecentBackups.
  ///
  /// In en, this message translates to:
  /// **'Recent Backups'**
  String get backupRecentBackups;

  /// No description provided for @backupChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get backupChooseDestination;

  /// No description provided for @backupSelectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get backupSelectBackupFile;

  /// No description provided for @backupDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup deleted'**
  String get backupDeleteSuccess;

  /// No description provided for @backupExportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Exporting backup...'**
  String get backupExportInProgress;

  /// No description provided for @backupImportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup...'**
  String get backupImportInProgress;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// No description provided for @settingsFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsFollowSystem;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get settingsShortcuts;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get settingsAboutApp;

  /// No description provided for @settingsPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// No description provided for @settingsOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline and private'**
  String get settingsOfflineTitle;

  /// No description provided for @settingsOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'This app works fully offline. Tasks, backups, and statistics stay on this device unless you export a local backup file.'**
  String get settingsOfflineBody;

  /// No description provided for @permissionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsLabel;

  /// No description provided for @permissionsSummary.
  ///
  /// In en, this message translates to:
  /// **'This app requires no explicit permissions. All access is implicit and confined to app-private directories or user-initiated actions.'**
  String get permissionsSummary;

  /// No description provided for @permissionsImplicit.
  ///
  /// In en, this message translates to:
  /// **'Implicit'**
  String get permissionsImplicit;

  /// No description provided for @permissionsExplicit.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get permissionsExplicit;

  /// No description provided for @permissionsExplicitNone.
  ///
  /// In en, this message translates to:
  /// **'This app declares zero permissions in the Android manifest for release builds. No runtime permission dialogs are shown.'**
  String get permissionsExplicitNone;

  /// No description provided for @permissionsStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'App-private storage'**
  String get permissionsStorageTitle;

  /// No description provided for @permissionsStorageBody.
  ///
  /// In en, this message translates to:
  /// **'The SQLite database is stored in the app-private directory. No storage permission is needed because Android grants every app access to its own data folder.'**
  String get permissionsStorageBody;

  /// No description provided for @permissionsFilePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'File picker access'**
  String get permissionsFilePickerTitle;

  /// No description provided for @permissionsFilePickerBody.
  ///
  /// In en, this message translates to:
  /// **'Backup export and import use the system file picker dialog. Access is granted per file by the user through the picker and requires no persistent permission.'**
  String get permissionsFilePickerBody;

  /// No description provided for @permissionsSystemClockTitle.
  ///
  /// In en, this message translates to:
  /// **'System clock'**
  String get permissionsSystemClockTitle;

  /// No description provided for @permissionsSystemClockBody.
  ///
  /// In en, this message translates to:
  /// **'Used for time tracking, timestamps, and date calculations. Reading the system clock requires no permission.'**
  String get permissionsSystemClockBody;

  /// No description provided for @permissionsTextProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Text processing'**
  String get permissionsTextProcessingTitle;

  /// No description provided for @permissionsTextProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Declared as an intent query so the system can handle text selection actions. This is a standard Flutter framework registration and requires no permission.'**
  String get permissionsTextProcessingBody;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @aboutHeadline.
  ///
  /// In en, this message translates to:
  /// **'Private daily planning'**
  String get aboutHeadline;

  /// No description provided for @aboutSummary.
  ///
  /// In en, this message translates to:
  /// **'SreerajP ToDo is an offline-first daily task list and time tracker designed to keep your data on this device.'**
  String get aboutSummary;

  /// No description provided for @aboutLocalOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Local-only data'**
  String get aboutLocalOnlyTitle;

  /// No description provided for @aboutLocalOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks, recurrence rules, backups, and statistics stay on local storage. No cloud sync or telemetry is used.'**
  String get aboutLocalOnlyBody;

  /// No description provided for @aboutBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Portable encrypted backups'**
  String get aboutBackupTitle;

  /// No description provided for @aboutBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Backup export creates encrypted files that you can store anywhere you choose and restore later with your passphrase.'**
  String get aboutBackupBody;

  /// No description provided for @aboutUnicodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Unicode-first input'**
  String get aboutUnicodeTitle;

  /// No description provided for @aboutUnicodeBody.
  ///
  /// In en, this message translates to:
  /// **'Titles and descriptions accept full Unicode text, including RTL scripts, emoji, and composed characters.'**
  String get aboutUnicodeBody;

  /// No description provided for @aboutNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Built for daily flow'**
  String get aboutNavigationTitle;

  /// No description provided for @aboutNavigationBody.
  ///
  /// In en, this message translates to:
  /// **'Daily planning, statistics, recurring rules, and backups are available from the main navigation with no account setup.'**
  String get aboutNavigationBody;

  /// No description provided for @aboutAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutAuthor;

  /// Author name. Proper noun, not translated.
  ///
  /// In en, this message translates to:
  /// **'Sreeraj P'**
  String get aboutAuthorName;

  /// No description provided for @aboutAiAssisted.
  ///
  /// In en, this message translates to:
  /// **'AI assisted by'**
  String get aboutAiAssisted;

  /// Model names. Proper nouns, not translated.
  ///
  /// In en, this message translates to:
  /// **'Claude 4.6 & GPT 5.4'**
  String get aboutAiModels;

  /// No description provided for @aboutBuildDate.
  ///
  /// In en, this message translates to:
  /// **'Build date'**
  String get aboutBuildDate;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutAppVersion;

  /// No description provided for @aboutMadeWithLoveIn.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤ in India'**
  String get aboutMadeWithLoveIn;

  /// No description provided for @statsDailyOverview.
  ///
  /// In en, this message translates to:
  /// **'Daily Overview'**
  String get statsDailyOverview;

  /// No description provided for @statsPerItemOverview.
  ///
  /// In en, this message translates to:
  /// **'Per-Item Overview'**
  String get statsPerItemOverview;

  /// No description provided for @statsChooseTask.
  ///
  /// In en, this message translates to:
  /// **'Choose task'**
  String get statsChooseTask;

  /// No description provided for @statsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get statsLast7Days;

  /// No description provided for @statsLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get statsLast30Days;

  /// No description provided for @statsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsAllTime;

  /// No description provided for @statsCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get statsCustomRange;

  /// No description provided for @statsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh statistics'**
  String get statsRefresh;

  /// No description provided for @statsTotalTodos.
  ///
  /// In en, this message translates to:
  /// **'Total todos'**
  String get statsTotalTodos;

  /// No description provided for @statsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statsTotal;

  /// No description provided for @statsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get statsDate;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get statsTitle;

  /// No description provided for @statsAppearances.
  ///
  /// In en, this message translates to:
  /// **'Appearances'**
  String get statsAppearances;

  /// No description provided for @statsAverageCompletedPerDay.
  ///
  /// In en, this message translates to:
  /// **'Average completed/day'**
  String get statsAverageCompletedPerDay;

  /// No description provided for @statsAverageTimePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average time/day'**
  String get statsAverageTimePerDay;

  /// No description provided for @statsProductiveTime.
  ///
  /// In en, this message translates to:
  /// **'Productive time'**
  String get statsProductiveTime;

  /// No description provided for @statsDroppedTime.
  ///
  /// In en, this message translates to:
  /// **'Dropped time'**
  String get statsDroppedTime;

  /// No description provided for @statsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search task titles'**
  String get statsSearchHint;

  /// No description provided for @statsNoDailyStats.
  ///
  /// In en, this message translates to:
  /// **'No statistics available for this date range'**
  String get statsNoDailyStats;

  /// No description provided for @statsNoPerItemStats.
  ///
  /// In en, this message translates to:
  /// **'No tracked tasks match the current filter'**
  String get statsNoPerItemStats;

  /// No description provided for @statsSelectTaskToViewHistory.
  ///
  /// In en, this message translates to:
  /// **'Select a task to view its time history'**
  String get statsSelectTaskToViewHistory;

  /// No description provided for @statsNoHistoryForTitle.
  ///
  /// In en, this message translates to:
  /// **'No time history recorded for this task'**
  String get statsNoHistoryForTitle;

  /// No description provided for @statsMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get statsMinutes;

  /// No description provided for @statsSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get statsSelectStartDate;

  /// No description provided for @statsSelectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get statsSelectEndDate;

  /// No description provided for @statsShowHistory.
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

  /// No description provided for @errorDayLocked.
  ///
  /// In en, this message translates to:
  /// **'Cannot modify tasks from past dates.'**
  String get errorDayLocked;

  /// No description provided for @errorCompletedLocked.
  ///
  /// In en, this message translates to:
  /// **'Cannot add time segments to a completed or dropped task.'**
  String get errorCompletedLocked;

  /// No description provided for @errorDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'A task with this title already exists for this date.'**
  String get errorDuplicateTitle;

  /// No description provided for @errorSegmentAlreadyRunning.
  ///
  /// In en, this message translates to:
  /// **'A time segment is already running for this task.'**
  String get errorSegmentAlreadyRunning;

  /// No description provided for @errorTodoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found.'**
  String get errorTodoNotFound;

  /// No description provided for @errorBackupVersionTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of the app. Please update.'**
  String get errorBackupVersionTooNew;

  /// No description provided for @errorBackupCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The backup file is corrupted and cannot be restored.'**
  String get errorBackupCorrupted;

  /// No description provided for @errorPortTargetMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Port target date must be tomorrow or later.'**
  String get errorPortTargetMustBeFuture;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorGeneric;

  /// No description provided for @errorRetryableGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Tap to retry.'**
  String get errorRetryableGeneric;
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
