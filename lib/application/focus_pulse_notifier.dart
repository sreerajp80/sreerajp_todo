// Dart does not allow a private initialising formal on a named parameter
// (`this._mode` is illegal), so this file assigns the injected callbacks to
// their private fields in the initialiser list instead.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/core/utils/focus_pulse_rules.dart';

/// Where the focus pulse schedule stands right now.
@immutable
class FocusPulseState {
  const FocusPulseState({this.nextPulseAt, this.pulseCount = 0});

  /// When the next pulse is due. Null when no pulse is scheduled, either
  /// because no timer is running or because pulses are switched off.
  final DateTime? nextPulseAt;

  /// How many pulses have fired for the timer running now. Reset every time a
  /// fresh timer starts.
  final int pulseCount;

  /// True when a pulse is waiting to fire.
  bool get isArmed => nextPulseAt != null;

  /// Seconds until the next pulse at [now], never below zero. Zero when
  /// nothing is scheduled.
  int secondsToNextPulse(DateTime now) {
    final next = nextPulseAt;
    if (next == null) return 0;
    final left = next.difference(now).inSeconds;
    return left < 0 ? 0 : left;
  }

  FocusPulseState copyWith({
    DateTime? nextPulseAt,
    int? pulseCount,
    bool clearNextPulseAt = false,
  }) {
    return FocusPulseState(
      nextPulseAt: clearNextPulseAt ? null : (nextPulseAt ?? this.nextPulseAt),
      pulseCount: pulseCount ?? this.pulseCount,
    );
  }
}

/// Gives a gentle nudge every so often while a timer runs, so the user
/// notices time passing.
///
/// The notifier owns the schedule only. It never touches the database and
/// never decides whether a timer is running: the caller passes in the start
/// time of the running segment through [syncWith]. Every input is an injected
/// function, so the whole class can be tested with a fake clock and a fake
/// nudge.
///
/// Known limit: like the Pomodoro alert, this is in-app only. The app sends no
/// notifications, so no pulse fires while the app is closed or in the
/// background. Nothing is queued up either; the schedule simply picks up from
/// the clock when the app comes back.
class FocusPulseNotifier extends StateNotifier<FocusPulseState> {
  FocusPulseNotifier({
    required FocusPulseMode Function() mode,
    required Duration Function() interval,
    bool Function()? suppressed,
    Future<void> Function(FocusPulseMode mode)? pulse,
    DateTime Function()? now,
  }) : _mode = mode,
       _interval = interval,
       _suppressed = suppressed ?? _neverSuppressed,
       _pulse = pulse ?? defaultPulse,
       _now = now ?? DateTime.now,
       super(const FocusPulseState());

  final FocusPulseMode Function() _mode;
  final Duration Function() _interval;
  final bool Function() _suppressed;
  final Future<void> Function(FocusPulseMode mode) _pulse;
  final DateTime Function() _now;

  Timer? _timer;

  /// The start of the timer the schedule is following, or null when idle.
  DateTime? _runningSince;

  static bool _neverSuppressed() => false;

  /// The real nudge: a short vibration, a short system chime, or both.
  ///
  /// Both come from the Flutter engine itself, so nothing is downloaded and no
  /// sound file has to be shipped.
  static Future<void> defaultPulse(FocusPulseMode mode) async {
    if (mode.hasSound) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (mode.hasVibration) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Points the schedule at the timer that started at [runningSince], or
  /// clears it when [runningSince] is null.
  ///
  /// Safe to call as often as needed. A call that names the same start time
  /// keeps the pulses already given, so a settings change or a trip to the
  /// background never restarts the count.
  void syncWith(DateTime? runningSince) {
    if (runningSince == null) {
      _clear();
      return;
    }

    if (_runningSince != runningSince) {
      _runningSince = runningSince;
      state = const FocusPulseState();
    }
    _schedule();
  }

  /// Stops the schedule and forgets the running timer.
  void stop() => _clear();

  /// Works out when the next pulse is due and sets a single timer for it, so
  /// nothing polls.
  void _schedule() {
    _cancelTimer();

    final startedAt = _runningSince;
    if (startedAt == null) return;

    if (!_mode().isOn || _suppressed()) {
      state = state.copyWith(clearNextPulseAt: true);
      return;
    }

    final now = _now();
    final next = nextFocusPulseAfter(startedAt, now, _interval());
    if (next == null) {
      state = state.copyWith(clearNextPulseAt: true);
      return;
    }

    state = state.copyWith(nextPulseAt: next);

    final wait = next.difference(now);
    _timer = Timer(wait.isNegative ? Duration.zero : wait, () {
      unawaited(_fire());
    });
  }

  Future<void> _fire() async {
    _cancelTimer();
    if (_runningSince == null) return;

    // Re-read the settings at the moment of firing, so switching pulses off
    // during a block takes effect at once.
    final mode = _mode();
    if (mode.isOn && !_suppressed()) {
      state = state.copyWith(pulseCount: state.pulseCount + 1);
      await _pulse(mode);
    }
    if (mounted) _schedule();
  }

  void _clear() {
    _cancelTimer();
    _runningSince = null;
    state = const FocusPulseState();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
