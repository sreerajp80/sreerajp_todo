import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/constants/todo_sort_option.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';

/// SharedPreferences key for the status a new task starts in.
const String kDefaultNewTaskStatusKey = 'defaults_new_task_status';

/// SharedPreferences key for the priority a new task starts with.
const String kDefaultPriorityKey = 'defaults_priority';

/// SharedPreferences key for the target time a new task starts with.
const String kDefaultTargetTimeKey = 'defaults_target_time';

/// SharedPreferences key for the day list sort order.
const String kDefaultSortOptionKey = 'defaults_sort_option';

/// SharedPreferences key for "write the sort I pick back to the default".
const String kRememberLastSortKey = 'defaults_remember_last_sort';

/// SharedPreferences key for "show completed tasks in the day list".
const String kShowCompletedKey = 'defaults_show_completed';

/// SharedPreferences key for "show dropped tasks in the day list".
const String kShowDroppedKey = 'defaults_show_dropped';

/// SharedPreferences key for "push finished tasks below the rest".
const String kSinkFinishedKey = 'defaults_sink_finished';

/// SharedPreferences key for "ask before marking a task complete".
const String kConfirmCompleteKey = 'defaults_confirm_complete';

/// SharedPreferences key for "ask before dropping a task".
const String kConfirmDropKey = 'defaults_confirm_drop';

/// SharedPreferences key for the automatic carry-over on/off switch.
const String kAutoCarryOverEnabledKey = 'defaults_auto_carry_over_enabled';

/// SharedPreferences key for the carry-over prompt on/off switch.
const String kCarryOverEnabledKey = 'defaults_carry_over_enabled';

/// SharedPreferences key for how far back the carry-over sheet looks (enum index).
const String kCarryOverLookBackKey = 'defaults_carry_over_look_back';

/// SharedPreferences key for how far back carry-over looks in integer days (1..45).
const String kCarryOverLookBackDaysKey = 'defaults_carry_over_look_back_days';

/// SharedPreferences key for the day the carry-over sheet was last shown.
const String kCarryOverLastAskedKey = 'defaults_carry_over_last_asked';

/// SharedPreferences key for the title autocomplete on/off switch.
const String kAutocompleteEnabledKey = 'defaults_autocomplete_enabled';

/// SharedPreferences key for how many suggestions autocomplete may show.
const String kSuggestionCountKey = 'defaults_suggestion_count';

/// SharedPreferences key for the voice task sheet on/off switch.
const String kVoiceInputEnabledKey = 'defaults_voice_input_enabled';

/// Immutable snapshot of every task-default preference.
@immutable
class TaskDefaults {
  const TaskDefaults({
    this.newTaskStatus = NewTaskStatus.pending,
    this.priority = TodoPriority.normal,
    this.targetTime = DefaultTargetTime.none,
    this.sortOption = TodoSortOption.manual,
    this.rememberLastSort = true,
    this.showCompleted = true,
    this.showDropped = true,
    this.sinkFinished = false,
    this.confirmComplete = false,
    this.confirmDrop = true,
    this.autoCarryOverEnabled = true,
    this.carryOverEnabled = false,
    this.carryOverLookBack = CarryOverLookBack.lastSevenDays,
    this.carryOverLookBackDays = kDefaultCarryOverLookBackDays,
    this.carryOverLastAsked,
    this.autocompleteEnabled = true,
    this.suggestionCount = SuggestionCount.twenty,
    this.voiceInputEnabled = false,
  });

  /// The status pre-selected on the create form.
  final NewTaskStatus newTaskStatus;

  /// The priority pre-selected on the create form.
  final TodoPriority priority;

  /// The target time pre-filled on the create form.
  final DefaultTargetTime targetTime;

  /// The order the day list opens in.
  final TodoSortOption sortOption;

  /// When true, choosing a sort in the day list menu also saves it.
  final bool rememberLastSort;

  /// When false, `completed` tasks are hidden from the day list.
  final bool showCompleted;

  /// When false, `dropped` tasks are hidden from the day list.
  final bool showDropped;

  /// When true, finished tasks are pushed below the unfinished ones.
  final bool sinkFinished;

  /// When true, completing a task asks first.
  final bool confirmComplete;

  /// When true, dropping a task asks first.
  final bool confirmDrop;

  /// When true, unfinished tasks from past days are automatically carried over.
  final bool autoCarryOverEnabled;

  /// When true, the carry-over sheet is offered once a day.
  final bool carryOverEnabled;

  /// How far back the carry-over sheet looks for unfinished tasks.
  final CarryOverLookBack carryOverLookBack;

  /// How many days back (1..45) carry-over looks for unfinished tasks.
  final int carryOverLookBackDays;

  /// The day the carry-over sheet was last shown, as `yyyy-MM-dd`.
  final String? carryOverLastAsked;

  /// When false, the title field never queries for suggestions.
  final bool autocompleteEnabled;

  /// How many suggestions the title field may show.
  final SuggestionCount suggestionCount;

  /// When true, the day list shows a microphone button that opens the voice
  /// task sheet.
  ///
  /// Off by default, and deliberately so. Turning it on is what leads to the
  /// microphone permission being asked for, so a fresh install never sees that
  /// prompt and behaves exactly as it did before this feature existed.
  final bool voiceInputEnabled;

  /// The `LIMIT` to apply to the autocomplete query. Zero when autocomplete is
  /// off, which callers read as "do not query at all".
  int get autocompleteLimit => autocompleteEnabled ? suggestionCount.limit : 0;

  TaskDefaults copyWith({
    NewTaskStatus? newTaskStatus,
    TodoPriority? priority,
    DefaultTargetTime? targetTime,
    TodoSortOption? sortOption,
    bool? rememberLastSort,
    bool? showCompleted,
    bool? showDropped,
    bool? sinkFinished,
    bool? confirmComplete,
    bool? confirmDrop,
    bool? autoCarryOverEnabled,
    bool? carryOverEnabled,
    CarryOverLookBack? carryOverLookBack,
    int? carryOverLookBackDays,
    String? carryOverLastAsked,
    bool? autocompleteEnabled,
    SuggestionCount? suggestionCount,
    bool? voiceInputEnabled,
  }) {
    final newDays =
        carryOverLookBackDays ??
        (carryOverLookBack != null
            ? carryOverLookBack.days
            : this.carryOverLookBackDays);
    return TaskDefaults(
      newTaskStatus: newTaskStatus ?? this.newTaskStatus,
      priority: priority ?? this.priority,
      targetTime: targetTime ?? this.targetTime,
      sortOption: sortOption ?? this.sortOption,
      rememberLastSort: rememberLastSort ?? this.rememberLastSort,
      showCompleted: showCompleted ?? this.showCompleted,
      showDropped: showDropped ?? this.showDropped,
      sinkFinished: sinkFinished ?? this.sinkFinished,
      confirmComplete: confirmComplete ?? this.confirmComplete,
      confirmDrop: confirmDrop ?? this.confirmDrop,
      autoCarryOverEnabled: autoCarryOverEnabled ?? this.autoCarryOverEnabled,
      carryOverEnabled: carryOverEnabled ?? this.carryOverEnabled,
      carryOverLookBack: carryOverLookBack ?? this.carryOverLookBack,
      carryOverLookBackDays: sanitizeCarryOverLookBackDays(newDays),
      carryOverLastAsked: carryOverLastAsked ?? this.carryOverLastAsked,
      autocompleteEnabled: autocompleteEnabled ?? this.autocompleteEnabled,
      suggestionCount: suggestionCount ?? this.suggestionCount,
      voiceInputEnabled: voiceInputEnabled ?? this.voiceInputEnabled,
    );
  }
}

/// Owns the task-default preferences and writes every change straight to
/// [SharedPreferences], so the choices survive a restart.
///
/// Mirrors the shape of `TimeTrackingSettingsNotifier` on purpose, so both
/// settings groups read the same way.
class TaskDefaultsNotifier extends StateNotifier<TaskDefaults> {
  TaskDefaultsNotifier(this._prefs) : super(_loadInitialState(_prefs));

  final SharedPreferences _prefs;

  static TaskDefaults _loadInitialState(SharedPreferences prefs) {
    const defaults = TaskDefaults();
    final lookBackEnum = _readEnum(
      prefs.getInt(kCarryOverLookBackKey),
      CarryOverLookBack.values,
      defaults.carryOverLookBack,
    );
    final savedDays =
        prefs.getInt(kCarryOverLookBackDaysKey) ??
        (prefs.getInt(kCarryOverLookBackKey) != null
            ? lookBackEnum.days
            : defaults.carryOverLookBackDays);

    return TaskDefaults(
      newTaskStatus: _readEnum(
        prefs.getInt(kDefaultNewTaskStatusKey),
        NewTaskStatus.values,
        defaults.newTaskStatus,
      ),
      priority: _readEnum(
        prefs.getInt(kDefaultPriorityKey),
        TodoPriority.values,
        defaults.priority,
      ),
      targetTime: _readEnum(
        prefs.getInt(kDefaultTargetTimeKey),
        DefaultTargetTime.values,
        defaults.targetTime,
      ),
      sortOption: _readEnum(
        prefs.getInt(kDefaultSortOptionKey),
        TodoSortOption.values,
        defaults.sortOption,
      ),
      rememberLastSort:
          prefs.getBool(kRememberLastSortKey) ?? defaults.rememberLastSort,
      showCompleted: prefs.getBool(kShowCompletedKey) ?? defaults.showCompleted,
      showDropped: prefs.getBool(kShowDroppedKey) ?? defaults.showDropped,
      sinkFinished: prefs.getBool(kSinkFinishedKey) ?? defaults.sinkFinished,
      confirmComplete:
          prefs.getBool(kConfirmCompleteKey) ?? defaults.confirmComplete,
      confirmDrop: prefs.getBool(kConfirmDropKey) ?? defaults.confirmDrop,
      autoCarryOverEnabled:
          prefs.getBool(kAutoCarryOverEnabledKey) ??
          defaults.autoCarryOverEnabled,
      carryOverEnabled:
          prefs.getBool(kCarryOverEnabledKey) ?? defaults.carryOverEnabled,
      carryOverLookBack: lookBackEnum,
      carryOverLookBackDays: sanitizeCarryOverLookBackDays(savedDays),
      carryOverLastAsked: prefs.getString(kCarryOverLastAskedKey),
      autocompleteEnabled:
          prefs.getBool(kAutocompleteEnabledKey) ??
          defaults.autocompleteEnabled,
      suggestionCount: _readEnum(
        prefs.getInt(kSuggestionCountKey),
        SuggestionCount.values,
        defaults.suggestionCount,
      ),
      voiceInputEnabled:
          prefs.getBool(kVoiceInputEnabledKey) ?? defaults.voiceInputEnabled,
    );
  }

  /// Reads a saved enum index, falling back when it is missing or out of range.
  /// A bad stored value can only come from a downgrade or a hand-edited file,
  /// and must never crash the app.
  static T _readEnum<T>(int? index, List<T> values, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  /// Sets the status a new task starts in.
  Future<void> setNewTaskStatus(NewTaskStatus value) async {
    if (value == state.newTaskStatus) return;
    state = state.copyWith(newTaskStatus: value);
    await _prefs.setInt(kDefaultNewTaskStatusKey, value.index);
  }

  /// Sets the priority a new task starts with.
  Future<void> setPriority(TodoPriority value) async {
    if (value == state.priority) return;
    state = state.copyWith(priority: value);
    await _prefs.setInt(kDefaultPriorityKey, value.index);
  }

  /// Sets the target time a new task starts with.
  Future<void> setTargetTime(DefaultTargetTime value) async {
    if (value == state.targetTime) return;
    state = state.copyWith(targetTime: value);
    await _prefs.setInt(kDefaultTargetTimeKey, value.index);
  }

  /// Sets the order the day list opens in.
  Future<void> setSortOption(TodoSortOption value) async {
    if (value == state.sortOption) return;
    state = state.copyWith(sortOption: value);
    await _prefs.setInt(kDefaultSortOptionKey, value.index);
  }

  /// Saves [value] as the default sort only when "remember the last sort I
  /// pick" is on. Called by the day list every time the sort menu is used, so
  /// the screen itself does not have to know about the switch.
  Future<void> rememberSortOption(TodoSortOption value) async {
    if (!state.rememberLastSort) return;
    await setSortOption(value);
  }

  /// Turns "remember the last sort I pick" on or off.
  Future<void> setRememberLastSort(bool value) async {
    if (value == state.rememberLastSort) return;
    state = state.copyWith(rememberLastSort: value);
    await _prefs.setBool(kRememberLastSortKey, value);
  }

  /// Shows or hides completed tasks in the day list.
  Future<void> setShowCompleted(bool value) async {
    if (value == state.showCompleted) return;
    state = state.copyWith(showCompleted: value);
    await _prefs.setBool(kShowCompletedKey, value);
  }

  /// Shows or hides dropped tasks in the day list.
  Future<void> setShowDropped(bool value) async {
    if (value == state.showDropped) return;
    state = state.copyWith(showDropped: value);
    await _prefs.setBool(kShowDroppedKey, value);
  }

  /// Turns "push finished tasks below the rest" on or off.
  Future<void> setSinkFinished(bool value) async {
    if (value == state.sinkFinished) return;
    state = state.copyWith(sinkFinished: value);
    await _prefs.setBool(kSinkFinishedKey, value);
  }

  /// Turns "ask before completing" on or off.
  Future<void> setConfirmComplete(bool value) async {
    if (value == state.confirmComplete) return;
    state = state.copyWith(confirmComplete: value);
    await _prefs.setBool(kConfirmCompleteKey, value);
  }

  /// Turns "ask before dropping" on or off.
  Future<void> setConfirmDrop(bool value) async {
    if (value == state.confirmDrop) return;
    state = state.copyWith(confirmDrop: value);
    await _prefs.setBool(kConfirmDropKey, value);
  }

  /// Turns automatic carry-over of incomplete tasks on or off.
  Future<void> setAutoCarryOverEnabled(bool value) async {
    if (value == state.autoCarryOverEnabled) return;
    state = state.copyWith(autoCarryOverEnabled: value);
    await _prefs.setBool(kAutoCarryOverEnabledKey, value);
  }

  /// Turns the carry-over prompt on or off.
  Future<void> setCarryOverEnabled(bool value) async {
    if (value == state.carryOverEnabled) return;
    state = state.copyWith(carryOverEnabled: value);
    await _prefs.setBool(kCarryOverEnabledKey, value);
  }

  /// Sets how far back the carry-over sheet looks (enum preset).
  Future<void> setCarryOverLookBack(CarryOverLookBack value) async {
    if (value == state.carryOverLookBack &&
        value.days == state.carryOverLookBackDays) {
      return;
    }
    state = state.copyWith(
      carryOverLookBack: value,
      carryOverLookBackDays: value.days,
    );
    await _prefs.setInt(kCarryOverLookBackKey, value.index);
    await _prefs.setInt(kCarryOverLookBackDaysKey, value.days);
  }

  /// Sets how far back carry-over looks in integer days (1..45).
  Future<void> setCarryOverLookBackDays(int days) async {
    final sanitized = sanitizeCarryOverLookBackDays(days);
    if (sanitized == state.carryOverLookBackDays) return;
    final matchingEnum =
        CarryOverLookBack.values
            .where((e) => e.days == sanitized)
            .firstOrNull ??
        state.carryOverLookBack;
    state = state.copyWith(
      carryOverLookBackDays: sanitized,
      carryOverLookBack: matchingEnum,
    );
    await _prefs.setInt(kCarryOverLookBackDaysKey, sanitized);
    await _prefs.setInt(kCarryOverLookBackKey, matchingEnum.index);
  }

  /// Records that the carry-over sheet was shown on [isoDate], so it is not
  /// offered again until the next day.
  Future<void> markCarryOverAsked(String isoDate) async {
    if (isoDate == state.carryOverLastAsked) return;
    state = state.copyWith(carryOverLastAsked: isoDate);
    await _prefs.setString(kCarryOverLastAskedKey, isoDate);
  }

  /// Turns title autocomplete on or off.
  Future<void> setAutocompleteEnabled(bool value) async {
    if (value == state.autocompleteEnabled) return;
    state = state.copyWith(autocompleteEnabled: value);
    await _prefs.setBool(kAutocompleteEnabledKey, value);
  }

  /// Sets how many suggestions the title field may show.
  Future<void> setSuggestionCount(SuggestionCount value) async {
    if (value == state.suggestionCount) return;
    state = state.copyWith(suggestionCount: value);
    await _prefs.setInt(kSuggestionCountKey, value.index);
  }

  /// Shows or hides the microphone button on the day list.
  Future<void> setVoiceInputEnabled(bool value) async {
    if (value == state.voiceInputEnabled) return;
    state = state.copyWith(voiceInputEnabled: value);
    await _prefs.setBool(kVoiceInputEnabledKey, value);
  }
}
