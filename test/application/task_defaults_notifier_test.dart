import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/task_defaults_notifier.dart';
import 'package:sreerajp_todo/core/constants/todo_sort_option.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> freshPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('TaskDefaultsNotifier defaults', () {
    test('nothing saved keeps the behaviour the app already had', () async {
      final state = TaskDefaultsNotifier(await freshPrefs()).state;

      expect(state.newTaskStatus, NewTaskStatus.pending);
      expect(state.priority, TodoPriority.normal);
      expect(state.targetTime, DefaultTargetTime.none);
      expect(state.sortOption, TodoSortOption.manual);
      expect(state.rememberLastSort, isTrue);
      expect(state.showCompleted, isTrue);
      expect(state.showDropped, isTrue);
      expect(state.sinkFinished, isFalse);
      expect(state.confirmDrop, isTrue);
      expect(state.confirmComplete, isFalse);
      expect(state.carryOverEnabled, isFalse);
      expect(state.carryOverLookBack, CarryOverLookBack.previousDay);
      expect(state.carryOverLastAsked, isNull);
      expect(state.autocompleteEnabled, isTrue);
      expect(state.suggestionCount, SuggestionCount.twenty);
    });

    test('autocompleteLimit is the chosen count, or zero when off', () async {
      final notifier = TaskDefaultsNotifier(await freshPrefs());
      expect(notifier.state.autocompleteLimit, 20);

      await notifier.setSuggestionCount(SuggestionCount.five);
      expect(notifier.state.autocompleteLimit, 5);

      await notifier.setAutocompleteEnabled(false);
      expect(notifier.state.autocompleteLimit, 0);
    });
  });

  group('TaskDefaultsNotifier loading', () {
    test('reads saved values back', () async {
      final prefs = await freshPrefs({
        kDefaultNewTaskStatusKey: NewTaskStatus.working.index,
        kDefaultPriorityKey: TodoPriority.high.index,
        kDefaultTargetTimeKey: DefaultTargetTime.thirtyMinutes.index,
        kDefaultSortOptionKey: TodoSortOption.priorityHigh.index,
        kRememberLastSortKey: false,
        kShowCompletedKey: false,
        kSinkFinishedKey: true,
        kConfirmCompleteKey: true,
        kCarryOverEnabledKey: true,
        kCarryOverLookBackKey: CarryOverLookBack.lastSevenDays.index,
        kCarryOverLastAskedKey: '2026-08-18',
        kSuggestionCountKey: SuggestionCount.fifty.index,
      });
      final state = TaskDefaultsNotifier(prefs).state;

      expect(state.newTaskStatus, NewTaskStatus.working);
      expect(state.priority, TodoPriority.high);
      expect(state.targetTime, DefaultTargetTime.thirtyMinutes);
      expect(state.sortOption, TodoSortOption.priorityHigh);
      expect(state.rememberLastSort, isFalse);
      expect(state.showCompleted, isFalse);
      expect(state.sinkFinished, isTrue);
      expect(state.confirmComplete, isTrue);
      expect(state.carryOverEnabled, isTrue);
      expect(state.carryOverLookBack, CarryOverLookBack.lastSevenDays);
      expect(state.carryOverLastAsked, '2026-08-18');
      expect(state.suggestionCount, SuggestionCount.fifty);
    });

    test(
      'a stored index out of range falls back instead of crashing',
      () async {
        final prefs = await freshPrefs({
          kDefaultPriorityKey: 99,
          kDefaultSortOptionKey: -3,
          kSuggestionCountKey: 42,
        });
        final state = TaskDefaultsNotifier(prefs).state;

        expect(state.priority, TodoPriority.normal);
        expect(state.sortOption, TodoSortOption.manual);
        expect(state.suggestionCount, SuggestionCount.twenty);
      },
    );
  });

  group('TaskDefaultsNotifier saving', () {
    test('every setter writes through to SharedPreferences', () async {
      final prefs = await freshPrefs();
      final notifier = TaskDefaultsNotifier(prefs);

      await notifier.setNewTaskStatus(NewTaskStatus.working);
      await notifier.setPriority(TodoPriority.urgent);
      await notifier.setTargetTime(DefaultTargetTime.oneHour);
      await notifier.setSortOption(TodoSortOption.nameAsc);
      await notifier.setShowDropped(false);
      await notifier.setSinkFinished(true);
      await notifier.setConfirmDrop(false);
      await notifier.setCarryOverEnabled(true);
      await notifier.setCarryOverLookBack(CarryOverLookBack.lastSevenDays);
      await notifier.markCarryOverAsked('2026-08-19');
      await notifier.setAutocompleteEnabled(false);

      expect(
        prefs.getInt(kDefaultNewTaskStatusKey),
        NewTaskStatus.working.index,
      );
      expect(prefs.getInt(kDefaultPriorityKey), TodoPriority.urgent.index);
      expect(
        prefs.getInt(kDefaultTargetTimeKey),
        DefaultTargetTime.oneHour.index,
      );
      expect(prefs.getInt(kDefaultSortOptionKey), TodoSortOption.nameAsc.index);
      expect(prefs.getBool(kShowDroppedKey), isFalse);
      expect(prefs.getBool(kSinkFinishedKey), isTrue);
      expect(prefs.getBool(kConfirmDropKey), isFalse);
      expect(prefs.getBool(kCarryOverEnabledKey), isTrue);
      expect(
        prefs.getInt(kCarryOverLookBackKey),
        CarryOverLookBack.lastSevenDays.index,
      );
      expect(prefs.getString(kCarryOverLastAskedKey), '2026-08-19');
      expect(prefs.getBool(kAutocompleteEnabledKey), isFalse);
    });

    test('rememberSortOption saves only while the switch is on', () async {
      final prefs = await freshPrefs();
      final notifier = TaskDefaultsNotifier(prefs);

      await notifier.rememberSortOption(TodoSortOption.nameAsc);
      expect(notifier.state.sortOption, TodoSortOption.nameAsc);
      expect(prefs.getInt(kDefaultSortOptionKey), TodoSortOption.nameAsc.index);

      await notifier.setRememberLastSort(false);
      await notifier.rememberSortOption(TodoSortOption.timeMost);

      expect(notifier.state.sortOption, TodoSortOption.nameAsc);
      expect(prefs.getInt(kDefaultSortOptionKey), TodoSortOption.nameAsc.index);
    });
  });
}
