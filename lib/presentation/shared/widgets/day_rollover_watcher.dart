import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';

final RegExp _dayListPath = RegExp(r'^/day/\d{4}-\d{2}-\d{2}$');

/// Where to send the user when the app comes back, or null to stay put.
///
/// Only a day list is moved, and only when the calendar day changed while the
/// app was away. Any other screen may hold unsaved work, so it is left alone.
/// [currentLocation] is null when something is pushed on top of the day list.
@visibleForTesting
String? dayRolloverTarget({
  required String lastSeenDay,
  required String today,
  required String? currentLocation,
}) {
  if (lastSeenDay == today) return null;
  if (currentLocation == null || !_dayListPath.hasMatch(currentLocation)) {
    return null;
  }
  final target = AppRoutes.dailyListPath(today);
  return currentLocation == target ? null : target;
}

/// Brings the day list back to today when a new day starts.
///
/// It checks when the app comes back from the background, and also just after
/// midnight while the app stays open (a desktop window left open overnight
/// never goes to the background).
///
/// Without this, a list left open on another day (for example after checking
/// where a task was moved) is still showing that day the next morning, and the
/// user can start or finish the wrong day's copy of a repeating task.
class DayRolloverWatcher extends StatefulWidget {
  const DayRolloverWatcher({
    super.key,
    required this.router,
    required this.child,
    this.today = todayAsIso,
    this.now = DateTime.now,
  });

  final GoRouter router;
  final Widget child;

  /// Injected so tests can move the clock to another day.
  final String Function() today;

  /// Injected so tests can control when the midnight check fires.
  final DateTime Function() now;

  @override
  State<DayRolloverWatcher> createState() => _DayRolloverWatcherState();
}

class _DayRolloverWatcherState extends State<DayRolloverWatcher>
    with WidgetsBindingObserver {
  late String _lastSeenDay;

  /// True from leaving the foreground until the next resume. Coming back also
  /// passes through `hidden`, so the day is noted only on the way out.
  bool _away = false;

  /// Fires just after the next local midnight while the app is in front.
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _lastSeenDay = widget.today();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightCheck();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();
    final now = widget.now();
    // One second past midnight, so the new date is surely in effect.
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      _checkForNewDay();
      _scheduleMidnightCheck();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (!_away) {
          _away = true;
          _lastSeenDay = widget.today();
          // Resume does the check, so no timer is needed in the background.
          _midnightTimer?.cancel();
        }
      case AppLifecycleState.resumed:
        _away = false;
        _checkForNewDay();
        _scheduleMidnightCheck();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _checkForNewDay() {
    final today = widget.today();
    final target = dayRolloverTarget(
      lastSeenDay: _lastSeenDay,
      today: today,
      currentLocation: _currentDayListLocation(),
    );
    _lastSeenDay = today;
    if (target == null) return;

    widget.router.go(target);
    ScaffoldMessenger.maybeOf(context)
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(context.l10n.newDayShowingToday)));
  }

  /// The location of the screen on top, or null when a screen was pushed over
  /// the base route (an edit form, time records, and so on).
  String? _currentDayListLocation() {
    final config = widget.router.routerDelegate.currentConfiguration;
    if (config.isEmpty) return null;
    if (config.matches.last is ImperativeRouteMatch) return null;
    return config.uri.path;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
