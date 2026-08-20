import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/core/utils/time_tracking_rules.dart';

/// Carries the user's rounding and format choices down the widget tree.
///
/// Reports such as Statistics are built from plain [StatelessWidget]s several
/// levels deep. Passing the settings through every constructor would touch a
/// lot of unrelated code, so they are handed down here instead and read with
/// `context.trackedDuration(seconds)`.
class TrackedDurationFormat extends InheritedWidget {
  const TrackedDurationFormat({
    super.key,
    required this.rounding,
    required this.format,
    required super.child,
  });

  final DurationRounding rounding;
  final DurationFormat format;

  /// The settings in force, or the app defaults when nothing wrapped the tree.
  ///
  /// Falling back rather than asserting keeps widget tests that pump a single
  /// widget working without extra setup.
  static TrackedDurationFormat? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TrackedDurationFormat>();
  }

  @override
  bool updateShouldNotify(TrackedDurationFormat oldWidget) {
    return rounding != oldWidget.rounding || format != oldWidget.format;
  }
}

extension TrackedDurationContext on BuildContext {
  /// Formats a settled tracked duration using the user's settings.
  ///
  /// Never use this for a running timer: a live clock always keeps its
  /// seconds, so call `formatDuration` directly there.
  String trackedDuration(int seconds) {
    final settings = TrackedDurationFormat.maybeOf(this);
    if (settings == null) return formatDuration(seconds);
    return formatDuration(
      seconds,
      rounding: settings.rounding,
      format: settings.format,
    );
  }
}
