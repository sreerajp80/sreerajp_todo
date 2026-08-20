import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';
import 'package:sreerajp_todo/presentation/shared/utils/tracked_duration_format.dart';

/// Wraps the app and applies the time-tracking settings that need to react to
/// the clock and to the app coming and going.
///
/// It owns three jobs:
///  * auto-stop, while the app is open;
///  * auto-pause when the app leaves the foreground;
///  * keeping the screen on while a timer runs;
///  * the focus pulse, the nudge given every so often while a timer runs.
///
/// An offline app cannot run in the background forever, so auto-stop can only
/// fire on the exact minute while the app is open. Anything missed is put
/// right by `RepairOrphanedSegments` on the next start.
class TimerLifecycleWatcher extends ConsumerStatefulWidget {
  const TimerLifecycleWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TimerLifecycleWatcher> createState() =>
      _TimerLifecycleWatcherState();
}

class _TimerLifecycleWatcherState extends ConsumerState<TimerLifecycleWatcher>
    with WidgetsBindingObserver {
  Timer? _autoStopTimer;
  bool _keepAwakeRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleAutoStop();
      unawaited(_syncKeepAwake());
      unawaited(_syncFocusPulse());
    });
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        unawaited(_onLeftForeground());
      case AppLifecycleState.resumed:
        unawaited(_onReturnedToForeground());
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onLeftForeground() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    // No pulse can be heard while the app is away, so the schedule is dropped
    // and rebuilt from the clock on the way back.
    ref.read(focusPulseProvider.notifier).stop();

    if (!ref.read(timeTrackingSettingsProvider).autoPauseOnBackground) return;

    final running = await ref
        .read(timeSegmentRepositoryProvider)
        .getAllRunningSegments();
    for (final segment in running) {
      await ref
          .read(timeTrackingProvider(segment.todoId).notifier)
          .pauseTimer();
    }
  }

  Future<void> _onReturnedToForeground() async {
    // The day may have rolled over while the app was away.
    ref.read(pausedTodosProvider.notifier).refresh();

    // Close anything the cut-off passed over while the app was closed.
    await _applyMissedAutoStops();
    _scheduleAutoStop();
    await _syncKeepAwake();
    await _syncFocusPulse();

    if (ref.read(timeTrackingSettingsProvider).pomodoroEnabled) {
      await ref.read(pomodoroProvider.notifier).syncWithClock();
    }
  }

  /// Stops any timer whose auto-stop moment already went by.
  Future<void> _applyMissedAutoStops() async {
    final settings = ref.read(timeTrackingSettingsProvider);
    if (settings.autoStopMode == AutoStopMode.off) return;

    final now = DateTime.now();
    final running = await ref
        .read(timeSegmentRepositoryProvider)
        .getAllRunningSegments();

    for (final segment in running) {
      final start = DateTime.parse(segment.startTime);
      final cutoff = orphanCloseTime(
        start,
        now,
        settings.autoStopMode,
        customHour: settings.autoStopHour,
        customMinute: settings.autoStopMinute,
      );
      if (cutoff == null) continue;
      await ref
          .read(timeTrackingProvider(segment.todoId).notifier)
          .autoStopAt(cutoff);
    }
  }

  /// Sets a single timer for the next cut-off, so the app does not poll.
  void _scheduleAutoStop() {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    final settings = ref.read(timeTrackingSettingsProvider);
    if (settings.autoStopMode == AutoStopMode.off) return;

    final next = settings.nextAutoStopAfter(DateTime.now());
    if (next == null) return;

    final wait = next.difference(DateTime.now());
    _autoStopTimer = Timer(wait.isNegative ? Duration.zero : wait, () async {
      final cutoff = DateTime.now();
      final running = await ref
          .read(timeSegmentRepositoryProvider)
          .getAllRunningSegments();
      for (final segment in running) {
        await ref
            .read(timeTrackingProvider(segment.todoId).notifier)
            .autoStopAt(cutoff);
      }
      if (mounted) _scheduleAutoStop();
    });
  }

  /// Points the focus pulse at the timer that has been running longest, or
  /// clears it when nothing is running.
  ///
  /// The earliest start is used so the gap is measured against real tracked
  /// work, even in the rare case where two timers run at once.
  Future<void> _syncFocusPulse() async {
    final running = await ref
        .read(timeSegmentRepositoryProvider)
        .getAllRunningSegments();

    DateTime? earliest;
    for (final segment in running) {
      final start = DateTime.parse(segment.startTime);
      if (earliest == null || start.isBefore(earliest)) earliest = start;
    }

    if (!mounted) return;
    ref.read(focusPulseProvider.notifier).syncWith(earliest);
  }

  /// Asks the host to keep the screen on only while it is actually wanted.
  Future<void> _syncKeepAwake() async {
    final settings = ref.read(timeTrackingSettingsProvider);
    final running = settings.keepScreenAwake
        ? (await ref
                  .read(timeSegmentRepositoryProvider)
                  .getAllRunningSegments())
              .isNotEmpty
        : false;

    if (running == _keepAwakeRequested) return;
    _keepAwakeRequested = running;
    await ref.read(screenWakeChannelProvider).setKeepAwake(running);
  }

  @override
  Widget build(BuildContext context) {
    // Re-check whenever the settings change, so turning auto-stop on takes
    // effect without a restart.
    ref.listen(timeTrackingSettingsProvider, (previous, next) {
      if (previous?.autoStopMode != next.autoStopMode ||
          previous?.autoStopHour != next.autoStopHour ||
          previous?.autoStopMinute != next.autoStopMinute) {
        _scheduleAutoStop();
      }
      if (previous?.keepScreenAwake != next.keepScreenAwake) {
        unawaited(_syncKeepAwake());
      }
      if (previous?.focusPulseMode != next.focusPulseMode ||
          previous?.focusPulseIntervalMinutes !=
              next.focusPulseIntervalMinutes ||
          previous?.pomodoroEnabled != next.pomodoroEnabled) {
        unawaited(_syncFocusPulse());
      }
    });

    // A timer starting, stopping or pausing changes whether the screen must
    // stay on, and which timer the pulse follows.
    ref.listen(timerActivityTickProvider, (_, _) {
      unawaited(_syncKeepAwake());
      unawaited(_syncFocusPulse());
    });

    // Hand the display choices down so reports deep in the tree can use them
    // without every widget taking a new constructor argument.
    final settings = ref.watch(timeTrackingSettingsProvider);
    return TrackedDurationFormat(
      rounding: settings.rounding,
      format: settings.format,
      child: widget.child,
    );
  }
}
