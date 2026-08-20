// Dart does not allow a private initialising formal on a named parameter
// (`this._workMinutes` is illegal), so this file assigns the injected callbacks
// to their private fields in the initialiser list instead.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The kind of Pomodoro block that is running or waiting to start.
enum PomodoroBlock {
  /// Nothing is running.
  idle,

  /// A work block. Tracked time is only ever recorded during this block.
  work,

  /// A short break between work blocks.
  shortBreak,

  /// A longer break after a run of work blocks.
  longBreak;

  /// True when this block is a break rather than work.
  bool get isBreak =>
      this == PomodoroBlock.shortBreak || this == PomodoroBlock.longBreak;
}

/// Immutable snapshot of where the Pomodoro cycle is.
@immutable
class PomodoroState {
  const PomodoroState({
    this.block = PomodoroBlock.idle,
    this.todoId,
    this.endsAt,
    this.completedWorkBlocks = 0,
    this.awaitingStart = false,
  });

  /// What is running now.
  final PomodoroBlock block;

  /// The todo the current work block belongs to. Null during a break that has
  /// outlived its todo, and while idle.
  final String? todoId;

  /// When the current block runs out. Null when nothing is running.
  final DateTime? endsAt;

  /// Work blocks finished in this run, used to decide on a long break.
  final int completedWorkBlocks;

  /// True when a block has ended and the next one is waiting for a tap,
  /// because auto-start is off.
  final bool awaitingStart;

  /// True when a block is counting down right now.
  bool get isRunning => endsAt != null && !awaitingStart;

  /// Seconds left in the current block at [now], never below zero.
  int secondsLeft(DateTime now) {
    final end = endsAt;
    if (end == null) return 0;
    final left = end.difference(now).inSeconds;
    return left < 0 ? 0 : left;
  }

  PomodoroState copyWith({
    PomodoroBlock? block,
    String? todoId,
    DateTime? endsAt,
    int? completedWorkBlocks,
    bool? awaitingStart,
    bool clearTodoId = false,
    bool clearEndsAt = false,
  }) {
    return PomodoroState(
      block: block ?? this.block,
      todoId: clearTodoId ? null : (todoId ?? this.todoId),
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      completedWorkBlocks: completedWorkBlocks ?? this.completedWorkBlocks,
      awaitingStart: awaitingStart ?? this.awaitingStart,
    );
  }
}

/// Drives the Pomodoro work / break cycle.
///
/// The notifier owns the cycle only. Starting and stopping the actual time
/// segment is left to the caller through [onWorkBlockEnded] and
/// [onWorkBlockStarted], so all database work stays in the time-tracking
/// notifier and this class stays easy to test.
///
/// Known limit: the alert is in-app only. With no notification support in the
/// app, a block that ends while the app is closed or in the background makes
/// no sound. The elapsed time is still correct when the app comes back.
class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier({
    required int Function() workMinutes,
    required int Function() shortBreakMinutes,
    required int Function() longBreakMinutes,
    required int Function() blocksBeforeLongBreak,
    required bool Function() autoStartNext,
    Future<void> Function(String todoId)? onWorkBlockEnded,
    Future<void> Function(String todoId)? onWorkBlockStarted,
    Future<void> Function()? alert,
    DateTime Function()? now,
  }) : _workMinutes = workMinutes,
       _shortBreakMinutes = shortBreakMinutes,
       _longBreakMinutes = longBreakMinutes,
       _blocksBeforeLongBreak = blocksBeforeLongBreak,
       _autoStartNext = autoStartNext,
       _onWorkBlockEnded = onWorkBlockEnded,
       _onWorkBlockStarted = onWorkBlockStarted,
       _alert = alert ?? _defaultAlert,
       _now = now ?? DateTime.now,
       super(const PomodoroState());

  final int Function() _workMinutes;
  final int Function() _shortBreakMinutes;
  final int Function() _longBreakMinutes;
  final int Function() _blocksBeforeLongBreak;
  final bool Function() _autoStartNext;
  final Future<void> Function(String todoId)? _onWorkBlockEnded;
  final Future<void> Function(String todoId)? _onWorkBlockStarted;
  final Future<void> Function() _alert;
  final DateTime Function() _now;

  Timer? _timer;

  static Future<void> _defaultAlert() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.heavyImpact();
  }

  /// Starts a work block on [todoId].
  Future<void> startWork(String todoId) async {
    _cancelTimer();
    state = PomodoroState(
      block: PomodoroBlock.work,
      todoId: todoId,
      endsAt: _now().add(Duration(minutes: _workMinutes())),
      completedWorkBlocks: state.completedWorkBlocks,
    );
    await _onWorkBlockStarted?.call(todoId);
    _scheduleBlockEnd();
  }

  /// Starts the break that follows the work blocks finished so far.
  void startBreak() {
    _cancelTimer();
    final isLong =
        state.completedWorkBlocks > 0 &&
        state.completedWorkBlocks % _blocksBeforeLongBreak() == 0;
    final minutes = isLong ? _longBreakMinutes() : _shortBreakMinutes();

    state = state.copyWith(
      block: isLong ? PomodoroBlock.longBreak : PomodoroBlock.shortBreak,
      endsAt: _now().add(Duration(minutes: minutes)),
      awaitingStart: false,
    );
    _scheduleBlockEnd();
  }

  /// Ends the whole cycle and clears the counter.
  Future<void> stop() async {
    _cancelTimer();
    final todoId = state.todoId;
    if (state.block == PomodoroBlock.work && todoId != null) {
      await _onWorkBlockEnded?.call(todoId);
    }
    state = const PomodoroState();
  }

  /// Called when a block that was waiting for a tap should now begin.
  Future<void> startNextBlock() async {
    if (!state.awaitingStart) return;
    if (state.block.isBreak) {
      final todoId = state.todoId;
      if (todoId == null) {
        state = const PomodoroState();
        return;
      }
      await startWork(todoId);
    } else {
      startBreak();
    }
  }

  /// Re-checks the clock and finishes any block whose time already ran out.
  ///
  /// Called when the app comes back to the foreground, where the in-app timer
  /// was not firing.
  Future<void> syncWithClock() async {
    if (state.endsAt == null || state.awaitingStart) return;
    if (state.secondsLeft(_now()) > 0) {
      _scheduleBlockEnd();
      return;
    }
    await _finishBlock();
  }

  void _scheduleBlockEnd() {
    _cancelTimer();
    final endsAt = state.endsAt;
    if (endsAt == null) return;

    final left = endsAt.difference(_now());
    _timer = Timer(left.isNegative ? Duration.zero : left, _finishBlock);
  }

  Future<void> _finishBlock() async {
    _cancelTimer();
    final finished = state.block;
    final todoId = state.todoId;

    if (finished == PomodoroBlock.work) {
      if (todoId != null) {
        await _onWorkBlockEnded?.call(todoId);
      }
      state = state.copyWith(
        completedWorkBlocks: state.completedWorkBlocks + 1,
        clearEndsAt: true,
        awaitingStart: true,
      );
    } else if (finished.isBreak) {
      state = state.copyWith(clearEndsAt: true, awaitingStart: true);
    } else {
      return;
    }

    await _alert();

    if (_autoStartNext()) {
      await startNextBlock();
    }
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
