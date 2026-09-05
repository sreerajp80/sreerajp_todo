import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/time_tracking_notifier.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';

/// Runs a timer action and shows whatever the user needs to know about it.
///
/// Kept in one place so the day list tile and the Time Segments screen behave
/// exactly the same: the same "stopped another timer" message, the same undo
/// for a discarded short segment.
class TimerActions {
  const TimerActions._();

  /// Starts or resumes the timer on [todoId].
  static Future<void> start(
    BuildContext context,
    WidgetRef ref,
    String todoId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final result = await ref
        .read(timeTrackingProvider(todoId).notifier)
        .startTimer();
    if (result.error != null) return;
    ref.read(timerActivityTickProvider.notifier).state++;

    if (result.tookOver) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.trackingStoppedOtherCount(result.stoppedTodoIds.length),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }

    // A Pomodoro work block only begins once the timer really started.
    final settings = ref.read(timeTrackingSettingsProvider);
    if (settings.pomodoroEnabled) {
      await ref.read(pomodoroProvider.notifier).startWork(todoId);
    }
  }

  /// Stops the timer on [todoId] for good.
  static Future<void> stop(
    BuildContext context,
    WidgetRef ref,
    String todoId,
  ) async {
    final notifier = ref.read(timeTrackingProvider(todoId).notifier);
    final pomodoro = ref.read(pomodoroProvider);
    final result = await notifier.stopTimer();

    if (pomodoro.todoId == todoId) {
      await ref.read(pomodoroProvider.notifier).stop();
    }
    ref.read(timerActivityTickProvider.notifier).state++;
    if (context.mounted) _reportDiscard(context, notifier, result);
  }

  /// Pauses the timer on [todoId], keeping the time worked so far.
  static Future<void> pause(
    BuildContext context,
    WidgetRef ref,
    String todoId,
  ) async {
    final notifier = ref.read(timeTrackingProvider(todoId).notifier);
    final pomodoro = ref.read(pomodoroProvider);
    final result = await notifier.pauseTimer();

    if (pomodoro.todoId == todoId) {
      await ref.read(pomodoroProvider.notifier).stop();
    }
    ref.read(timerActivityTickProvider.notifier).state++;
    if (context.mounted) _reportDiscard(context, notifier, result);
  }

  /// Tells the user when a segment was dropped for being too short, and offers
  /// to put it back. Matches the 5 second undo used elsewhere in the app.
  static void _reportDiscard(
    BuildContext context,
    TimeTrackingNotifier notifier,
    StopTimerResult result,
  ) {
    final TimeSegmentEntity? discarded = result.discardedSegment;
    if (discarded == null) return;

    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.trackingSegmentDiscarded),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => notifier.undoDiscardedSegment(discarded),
          ),
        ),
      );
  }
}
