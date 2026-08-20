import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

/// SharedPreferences key for the ids of todos whose timer is paused.
const String kPausedTodoIdsKey = 'tracking_paused_todo_ids';

/// SharedPreferences key for the day the paused marks belong to.
const String kPausedTodoDateKey = 'tracking_paused_todo_date';

/// Remembers which todos are paused rather than simply stopped.
///
/// A pause closes the running segment, exactly like a stop, so no worked time
/// is lost and the one-open-segment-per-todo rule still holds. The only thing
/// left over is the fact that the user means to come back, which is screen
/// state and not user data. That is why it lives in [SharedPreferences] and is
/// deliberately kept out of the database, out of backups and out of sync.
class TimerPausedStore {
  TimerPausedStore(this._prefs);

  final SharedPreferences _prefs;

  /// The ids of todos currently marked paused, for [today].
  ///
  /// Marks from an earlier day are dropped, because a pause is only meaningful
  /// within the day that is still editable.
  Set<String> pausedIds(String today) {
    final savedDate = _prefs.getString(kPausedTodoDateKey);
    if (savedDate != today) return <String>{};
    return (_prefs.getStringList(kPausedTodoIdsKey) ?? const <String>[])
        .toSet();
  }

  /// True when [todoId] is marked paused today.
  bool isPaused(String todoId, String today) =>
      pausedIds(today).contains(todoId);

  /// Marks [todoId] as paused for [today].
  Future<void> markPaused(String todoId, String today) async {
    final ids = pausedIds(today)..add(todoId);
    await _write(ids, today);
  }

  /// Clears the paused mark on [todoId].
  ///
  /// Called on resume, on stop, and whenever the todo becomes completed or
  /// dropped, so a finished task never shows a stale Resume button.
  Future<void> clearPaused(String todoId, String today) async {
    final ids = pausedIds(today);
    if (!ids.remove(todoId)) return;
    await _write(ids, today);
  }

  /// Clears every paused mark.
  Future<void> clearAll() async {
    await _prefs.remove(kPausedTodoIdsKey);
    await _prefs.remove(kPausedTodoDateKey);
  }

  Future<void> _write(Set<String> ids, String today) async {
    if (ids.isEmpty) {
      await clearAll();
      return;
    }
    await _prefs.setStringList(kPausedTodoIdsKey, ids.toList());
    await _prefs.setString(kPausedTodoDateKey, today);
  }
}

/// Holds the paused todo ids in memory so every tile rebuilds together when
/// one timer is paused or resumed.
class PausedTodosNotifier extends StateNotifier<Set<String>> {
  PausedTodosNotifier(this._store) : super(_store.pausedIds(todayAsIso()));

  final TimerPausedStore _store;

  /// True when [todoId] is showing a Resume button rather than a Start button.
  bool isPaused(String todoId) => state.contains(todoId);

  /// Marks [todoId] paused.
  Future<void> markPaused(String todoId) async {
    final today = todayAsIso();
    await _store.markPaused(todoId, today);
    state = _store.pausedIds(today);
  }

  /// Clears the paused mark on [todoId], if it had one.
  Future<void> clearPaused(String todoId) async {
    if (!state.contains(todoId)) return;
    final today = todayAsIso();
    await _store.clearPaused(todoId, today);
    state = _store.pausedIds(today);
  }

  /// Drops every paused mark, used when the day rolls over.
  Future<void> clearAll() async {
    if (state.isEmpty) return;
    await _store.clearAll();
    state = <String>{};
  }

  /// Re-reads the marks for today. Called when the app comes back to the
  /// foreground, which may be on a new day.
  void refresh() {
    state = _store.pausedIds(todayAsIso());
  }
}
