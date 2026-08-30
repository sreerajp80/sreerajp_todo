import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';

/// SharedPreferences key for the Ritual mode on/off switch.
const String kRitualEnabledKey = 'ritual_enabled';

/// SharedPreferences key for "open the ritual on the first launch of a day".
const String kRitualOpenOnLaunchKey = 'ritual_open_on_launch';

/// SharedPreferences key for the chosen breathing rhythm.
const String kRitualBreathTechniqueKey = 'ritual_breath_technique';

/// SharedPreferences key for how many breaths the first step runs.
const String kRitualBreathCountKey = 'ritual_breath_count';

/// SharedPreferences key for the buzz at each breathing phase change.
const String kRitualHapticKey = 'ritual_haptic';

/// SharedPreferences key for the card step on/off switch.
const String kRitualCardStepKey = 'ritual_card_step';

/// SharedPreferences key for the settle step on/off switch.
const String kRitualSettleStepKey = 'ritual_settle_step';

/// SharedPreferences key for the evening close on/off switch.
const String kRitualEveningCloseKey = 'ritual_evening_close';

/// SharedPreferences key for the hour the evening close starts being offered.
const String kRitualEveningHourKey = 'ritual_evening_hour';

/// SharedPreferences key for the last day the ritual was run, `yyyy-MM-dd`.
const String kRitualLastRunKey = 'ritual_last_run';

/// SharedPreferences key for the last day the evening close was offered.
const String kRitualEveningLastAskedKey = 'ritual_evening_last_asked';

/// Immutable snapshot of every Ritual mode preference.
///
/// All of it is device state: which rhythm this person likes, and which day
/// the ritual last ran. None of it is user content, so it stays in
/// [SharedPreferences] and out of the database, backups and sync payloads.
@immutable
class RitualSettings {
  const RitualSettings({
    this.enabled = false,
    this.openOnLaunch = true,
    this.technique = BreathTechnique.box,
    this.breathCount = kRitualDefaultBreaths,
    this.haptic = false,
    this.cardStep = true,
    this.settleStep = true,
    this.eveningClose = false,
    this.eveningHour = kRitualDefaultEveningHour,
    this.lastRunDate,
    this.eveningLastAsked,
  });

  /// Off on a fresh install, deliberately. Someone who never turns it on sees
  /// the app behave exactly as it did before this feature existed.
  final bool enabled;

  /// When true, the first launch of a day opens the ritual by itself.
  final bool openOnLaunch;

  /// The breathing rhythm the first step follows.
  final BreathTechnique technique;

  /// How many breaths the first step runs for.
  final int breathCount;

  /// When true, a short buzz marks each change of breathing phase.
  final bool haptic;

  /// When false, the ritual skips the reflection card.
  final bool cardStep;

  /// When false, the ritual skips carry-over and picking today's three.
  final bool settleStep;

  /// When true, the day list offers the evening reflection once a day.
  final bool eveningClose;

  /// The hour, 0 to 23, from which the evening close may be offered.
  final int eveningHour;

  /// The last day the ritual ran, as `yyyy-MM-dd`, or null if it never has.
  final String? lastRunDate;

  /// The last day the evening close was offered, as `yyyy-MM-dd`.
  final String? eveningLastAsked;

  /// True when the ritual should open by itself for [today].
  ///
  /// The gate is deliberately three separate conditions rather than one clever
  /// one, so a bug report can be answered by reading it aloud: the feature is
  /// on, automatic opening is on, and it has not already run today.
  bool shouldOpenOn(String today) {
    if (!enabled) return false;
    if (!openOnLaunch) return false;
    return lastRunDate != today;
  }

  /// True when the evening reflection should be offered at [now] on [today].
  bool shouldOfferEveningClose(String today, DateTime now) {
    if (!enabled) return false;
    if (!eveningClose) return false;
    if (now.hour < eveningHour) return false;
    return eveningLastAsked != today;
  }

  RitualSettings copyWith({
    bool? enabled,
    bool? openOnLaunch,
    BreathTechnique? technique,
    int? breathCount,
    bool? haptic,
    bool? cardStep,
    bool? settleStep,
    bool? eveningClose,
    int? eveningHour,
    String? lastRunDate,
    String? eveningLastAsked,
  }) {
    return RitualSettings(
      enabled: enabled ?? this.enabled,
      openOnLaunch: openOnLaunch ?? this.openOnLaunch,
      technique: technique ?? this.technique,
      breathCount: breathCount ?? this.breathCount,
      haptic: haptic ?? this.haptic,
      cardStep: cardStep ?? this.cardStep,
      settleStep: settleStep ?? this.settleStep,
      eveningClose: eveningClose ?? this.eveningClose,
      eveningHour: eveningHour ?? this.eveningHour,
      lastRunDate: lastRunDate ?? this.lastRunDate,
      eveningLastAsked: eveningLastAsked ?? this.eveningLastAsked,
    );
  }
}

/// Owns the Ritual mode preferences and writes every change straight to
/// [SharedPreferences], so the choices survive a restart.
///
/// Mirrors `TaskDefaultsNotifier` on purpose, so every settings group in the
/// app reads the same way.
class RitualNotifier extends StateNotifier<RitualSettings> {
  RitualNotifier(this._prefs) : super(_loadInitialState(_prefs));

  final SharedPreferences _prefs;

  static RitualSettings _loadInitialState(SharedPreferences prefs) {
    const defaults = RitualSettings();
    return RitualSettings(
      enabled: prefs.getBool(kRitualEnabledKey) ?? defaults.enabled,
      openOnLaunch:
          prefs.getBool(kRitualOpenOnLaunchKey) ?? defaults.openOnLaunch,
      technique: _readEnum(
        prefs.getInt(kRitualBreathTechniqueKey),
        BreathTechnique.values,
        defaults.technique,
      ),
      breathCount: _clampBreaths(
        prefs.getInt(kRitualBreathCountKey) ?? defaults.breathCount,
      ),
      haptic: prefs.getBool(kRitualHapticKey) ?? defaults.haptic,
      cardStep: prefs.getBool(kRitualCardStepKey) ?? defaults.cardStep,
      settleStep: prefs.getBool(kRitualSettleStepKey) ?? defaults.settleStep,
      eveningClose:
          prefs.getBool(kRitualEveningCloseKey) ?? defaults.eveningClose,
      eveningHour: _clampHour(
        prefs.getInt(kRitualEveningHourKey) ?? defaults.eveningHour,
      ),
      lastRunDate: prefs.getString(kRitualLastRunKey),
      eveningLastAsked: prefs.getString(kRitualEveningLastAskedKey),
    );
  }

  /// Reads a saved enum index, falling back when it is missing or out of
  /// range. A bad stored value can only come from a downgrade or a hand-edited
  /// file, and must never crash the app.
  static T _readEnum<T>(int? index, List<T> values, T fallback) {
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  static int _clampBreaths(int value) =>
      value.clamp(kRitualMinBreaths, kRitualMaxBreaths);

  static int _clampHour(int value) =>
      value.clamp(kRitualMinEveningHour, kRitualMaxEveningHour);

  /// Turns Ritual mode on or off.
  Future<void> setEnabled(bool value) async {
    if (value == state.enabled) return;
    state = state.copyWith(enabled: value);
    await _prefs.setBool(kRitualEnabledKey, value);
  }

  /// Turns the automatic once-a-day opening on or off.
  Future<void> setOpenOnLaunch(bool value) async {
    if (value == state.openOnLaunch) return;
    state = state.copyWith(openOnLaunch: value);
    await _prefs.setBool(kRitualOpenOnLaunchKey, value);
  }

  /// Sets the breathing rhythm.
  Future<void> setTechnique(BreathTechnique value) async {
    if (value == state.technique) return;
    state = state.copyWith(technique: value);
    await _prefs.setInt(kRitualBreathTechniqueKey, value.index);
  }

  /// Sets how many breaths the first step runs for.
  Future<void> setBreathCount(int value) async {
    final clamped = _clampBreaths(value);
    if (clamped == state.breathCount) return;
    state = state.copyWith(breathCount: clamped);
    await _prefs.setInt(kRitualBreathCountKey, clamped);
  }

  /// Turns the buzz at each breathing phase change on or off.
  Future<void> setHaptic(bool value) async {
    if (value == state.haptic) return;
    state = state.copyWith(haptic: value);
    await _prefs.setBool(kRitualHapticKey, value);
  }

  /// Includes or skips the reflection card step.
  Future<void> setCardStep(bool value) async {
    if (value == state.cardStep) return;
    state = state.copyWith(cardStep: value);
    await _prefs.setBool(kRitualCardStepKey, value);
  }

  /// Includes or skips the settle step.
  Future<void> setSettleStep(bool value) async {
    if (value == state.settleStep) return;
    state = state.copyWith(settleStep: value);
    await _prefs.setBool(kRitualSettleStepKey, value);
  }

  /// Turns the evening reflection offer on or off.
  Future<void> setEveningClose(bool value) async {
    if (value == state.eveningClose) return;
    state = state.copyWith(eveningClose: value);
    await _prefs.setBool(kRitualEveningCloseKey, value);
  }

  /// Sets the hour from which the evening close may be offered.
  Future<void> setEveningHour(int value) async {
    final clamped = _clampHour(value);
    if (clamped == state.eveningHour) return;
    state = state.copyWith(eveningHour: clamped);
    await _prefs.setInt(kRitualEveningHourKey, clamped);
  }

  /// Remembers that the ritual ran on [date], so it does not open again today.
  ///
  /// Called whether the ritual was finished or skipped: being asked twice in
  /// one day is exactly what someone who skipped it does not want.
  Future<void> markRun(String date) async {
    state = state.copyWith(lastRunDate: date);
    await _prefs.setString(kRitualLastRunKey, date);
  }

  /// Remembers that the evening close was offered on [date].
  Future<void> markEveningAsked(String date) async {
    state = state.copyWith(eveningLastAsked: date);
    await _prefs.setString(kRitualEveningLastAskedKey, date);
  }
}
