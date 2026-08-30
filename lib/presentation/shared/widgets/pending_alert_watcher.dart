import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/carry_over_sheet.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart';

/// Wraps the application and monitors day-start and interval-based triggers
/// for pending task alerts.
class PendingAlertWatcher extends ConsumerStatefulWidget {
  const PendingAlertWatcher({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  ConsumerState<PendingAlertWatcher> createState() =>
      _PendingAlertWatcherState();
}

class _PendingAlertWatcherState extends ConsumerState<PendingAlertWatcher>
    with WidgetsBindingObserver {
  Timer? _checkTimer;
  bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeIntervalClock();
      _evaluateAlertConditions();
      _startPeriodicTimer();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _evaluateAlertConditions();
    }
  }

  void _initializeIntervalClock() {
    final settings = ref.read(pendingAlertSettingsProvider);
    if (settings.lastIntervalAlertEpoch == null) {
      ref
          .read(pendingAlertSettingsProvider.notifier)
          .markIntervalAlertShown(DateTime.now().millisecondsSinceEpoch);
    }
  }

  void _startPeriodicTimer() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _evaluateAlertConditions();
    });
  }

  Future<void> _evaluateAlertConditions() async {
    if (!mounted || _isSheetOpen) return;

    final settings = ref.read(pendingAlertSettingsProvider);
    if (!settings.enabled) return;

    final now = DateTime.now();
    final today = todayAsIso();

    final isDayStartTrigger = settings.shouldTriggerDayStartAlert(today, now);
    final isIntervalTrigger = settings.shouldTriggerIntervalAlert(now);

    if (!isDayStartTrigger && !isIntervalTrigger) return;

    // If auto carry-over is enabled and not yet executed today, run it before querying pending tasks
    final defaults = ref.read(taskDefaultsProvider);
    if (defaults.autoCarryOverEnabled && defaults.carryOverLastAsked != today) {
      await ref.read(taskDefaultsProvider.notifier).markCarryOverAsked(today);
      try {
        final candidates = await CarryOverSheet.findAllUnfinishedCandidates(
          ref,
          targetDate: today,
          lookBackDays: defaults.carryOverLookBackDays,
        );
        if (candidates.isNotEmpty) {
          final ordered = candidates.map((t) => t.id).toList();
          await ref.read(copyTodosProvider)(ordered, today);
          ref.invalidate(dailyTodoProvider(today));
          ref.invalidate(pendingAlertPayloadProvider);
          ref.invalidate(statisticsProvider);
        }
      } catch (e) {
        debugPrint('PendingAlertWatcher: auto carry-over failed ($e)');
      }
    }

    // Check if there are active pending or working tasks (today and previous dates)
    final payload = await ref.read(pendingAlertPayloadProvider.future);

    // If day start or interval matched, update markers
    if (isDayStartTrigger) {
      await ref
          .read(pendingAlertSettingsProvider.notifier)
          .markDayAlertShown(today);
      await ref
          .read(pendingAlertSettingsProvider.notifier)
          .markIntervalAlertShown(now.millisecondsSinceEpoch);
    } else if (isIntervalTrigger) {
      await ref
          .read(pendingAlertSettingsProvider.notifier)
          .markIntervalAlertShown(now.millisecondsSinceEpoch);
    }

    if (payload.isEmpty) return;

    // Post native Android system notification
    final notificationChannel = ref.read(pendingNotificationChannelProvider);
    final count = payload.totalCount;
    final summary = payload.previousTodos.isNotEmpty
        ? '${payload.todayTodos.length} today, ${payload.previousTodos.length} from previous days'
        : '$count tasks remaining today';

    await notificationChannel.showReminder(
      title: 'Pending Tasks Reminder',
      body: 'You have $count pending tasks waiting ($summary)',
      count: count,
    );

    if (!mounted || _isSheetOpen) return;

    final navContext = widget.navigatorKey?.currentContext;
    if (navContext != null && navContext.mounted) {
      if (settings.haptic) {
        await HapticFeedback.mediumImpact();
      }

      if (!navContext.mounted) return;
      _isSheetOpen = true;
      try {
        await PendingTodosAlertSheet.showPayload(navContext, payload);
      } catch (e) {
        debugPrint('PendingAlertWatcher: failed to show sheet ($e)');
      } finally {
        _isSheetOpen = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-check when settings change
    ref.listen(pendingAlertSettingsProvider, (previous, next) {
      if (previous?.enabled != next.enabled ||
          previous?.intervalMinutes != next.intervalMinutes ||
          previous?.dayStartAlertEnabled != next.dayStartAlertEnabled ||
          previous?.dayStartHour != next.dayStartHour ||
          previous?.dayStartMinute != next.dayStartMinute) {
        _evaluateAlertConditions();
      }
    });

    return widget.child;
  }
}
