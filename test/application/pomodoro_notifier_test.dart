import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/pomodoro_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Builds a notifier with a clock the test controls, so no test ever has to
  /// wait for a real 25 minute block.
  PomodoroNotifier build({
    int workMinutes = 25,
    int shortBreakMinutes = 5,
    int longBreakMinutes = 15,
    int blocksBeforeLongBreak = 4,
    bool autoStartNext = false,
    required DateTime Function() now,
    List<String>? endedBlocks,
    List<String>? startedBlocks,
    List<String>? alerts,
  }) {
    return PomodoroNotifier(
      workMinutes: () => workMinutes,
      shortBreakMinutes: () => shortBreakMinutes,
      longBreakMinutes: () => longBreakMinutes,
      blocksBeforeLongBreak: () => blocksBeforeLongBreak,
      autoStartNext: () => autoStartNext,
      onWorkBlockEnded: (todoId) async => endedBlocks?.add(todoId),
      onWorkBlockStarted: (todoId) async => startedBlocks?.add(todoId),
      alert: () async => alerts?.add('alert'),
      now: now,
    );
  }

  group('PomodoroNotifier', () {
    test('starts idle', () {
      final notifier = build(now: () => DateTime(2026, 8, 18, 9));
      expect(notifier.state.block, PomodoroBlock.idle);
      expect(notifier.state.isRunning, isFalse);
    });

    test('startWork opens a work block and tells the caller', () async {
      final clock = DateTime(2026, 8, 18, 9);
      final started = <String>[];
      final notifier = build(now: () => clock, startedBlocks: started);

      await notifier.startWork('todo-1');

      expect(notifier.state.block, PomodoroBlock.work);
      expect(notifier.state.todoId, 'todo-1');
      expect(notifier.state.endsAt, DateTime(2026, 8, 18, 9, 25));
      expect(notifier.state.secondsLeft(clock), 25 * 60);
      expect(started, ['todo-1']);

      notifier.dispose();
    });

    test('secondsLeft never goes below zero', () async {
      final clock = DateTime(2026, 8, 18, 9);
      final notifier = build(now: () => clock);
      await notifier.startWork('todo-1');

      expect(notifier.state.secondsLeft(DateTime(2026, 8, 18, 10)), 0);
      notifier.dispose();
    });

    test('a finished work block stops the timer, alerts and waits', () async {
      var clock = DateTime(2026, 8, 18, 9);
      final ended = <String>[];
      final alerts = <String>[];
      final notifier = build(
        now: () => clock,
        endedBlocks: ended,
        alerts: alerts,
      );

      await notifier.startWork('todo-1');
      clock = DateTime(2026, 8, 18, 9, 25);
      await notifier.syncWithClock();

      expect(ended, ['todo-1']);
      expect(alerts, ['alert']);
      expect(notifier.state.completedWorkBlocks, 1);
      expect(notifier.state.awaitingStart, isTrue);
      expect(notifier.state.isRunning, isFalse);

      notifier.dispose();
    });

    test('the break after one work block is a short break', () async {
      var clock = DateTime(2026, 8, 18, 9);
      final notifier = build(now: () => clock);

      await notifier.startWork('todo-1');
      clock = DateTime(2026, 8, 18, 9, 25);
      await notifier.syncWithClock();
      notifier.startBreak();

      expect(notifier.state.block, PomodoroBlock.shortBreak);
      expect(notifier.state.endsAt, DateTime(2026, 8, 18, 9, 30));

      notifier.dispose();
    });

    test('the fourth work block earns a long break', () async {
      var clock = DateTime(2026, 8, 18, 9);
      final notifier = build(now: () => clock, blocksBeforeLongBreak: 4);

      for (var i = 0; i < 4; i++) {
        await notifier.startWork('todo-1');
        clock = clock.add(const Duration(minutes: 25));
        await notifier.syncWithClock();
        if (i < 3) notifier.startBreak();
      }

      expect(notifier.state.completedWorkBlocks, 4);
      notifier.startBreak();
      expect(notifier.state.block, PomodoroBlock.longBreak);

      notifier.dispose();
    });

    test('auto-start moves straight into the break', () async {
      var clock = DateTime(2026, 8, 18, 9);
      final notifier = build(now: () => clock, autoStartNext: true);

      await notifier.startWork('todo-1');
      clock = DateTime(2026, 8, 18, 9, 25);
      await notifier.syncWithClock();

      expect(notifier.state.block, PomodoroBlock.shortBreak);
      expect(notifier.state.awaitingStart, isFalse);

      notifier.dispose();
    });

    test('a finished break goes back to work on the same todo', () async {
      var clock = DateTime(2026, 8, 18, 9);
      final started = <String>[];
      final notifier = build(now: () => clock, startedBlocks: started);

      await notifier.startWork('todo-1');
      clock = DateTime(2026, 8, 18, 9, 25);
      await notifier.syncWithClock();
      notifier.startBreak();
      clock = DateTime(2026, 8, 18, 9, 30);
      await notifier.syncWithClock();

      expect(notifier.state.awaitingStart, isTrue);
      await notifier.startNextBlock();

      expect(notifier.state.block, PomodoroBlock.work);
      expect(started, ['todo-1', 'todo-1']);

      notifier.dispose();
    });

    test('stop ends the cycle and clears the count', () async {
      final clock = DateTime(2026, 8, 18, 9);
      final ended = <String>[];
      final notifier = build(now: () => clock, endedBlocks: ended);

      await notifier.startWork('todo-1');
      await notifier.stop();

      expect(ended, ['todo-1']);
      expect(notifier.state.block, PomodoroBlock.idle);
      expect(notifier.state.completedWorkBlocks, 0);

      notifier.dispose();
    });

    test('syncWithClock leaves a block that still has time to run', () async {
      var clock = DateTime(2026, 8, 18, 9);
      final ended = <String>[];
      final notifier = build(now: () => clock, endedBlocks: ended);

      await notifier.startWork('todo-1');
      clock = DateTime(2026, 8, 18, 9, 10);
      await notifier.syncWithClock();

      expect(ended, isEmpty);
      expect(notifier.state.block, PomodoroBlock.work);

      notifier.dispose();
    });
  });
}
