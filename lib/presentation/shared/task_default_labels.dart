import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/todo_sort_option.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';

/// Shared labels and colours for the task-default values.
///
/// The settings pages, the create/edit form, the day tile and the sort menu all
/// name the same things, so the naming lives in one place instead of being
/// repeated four times.

/// The translated name of [priority].
String priorityName(AppLocalizations l10n, TodoPriority priority) {
  return switch (priority) {
    TodoPriority.low => l10n.priorityLow,
    TodoPriority.normal => l10n.priorityNormal,
    TodoPriority.high => l10n.priorityHigh,
    TodoPriority.urgent => l10n.priorityUrgent,
  };
}

/// The colour used for the priority dot and chip.
///
/// [TodoPriority.normal] deliberately returns null: the ordinary case shows no
/// dot at all, so a list of ordinary tasks stays quiet.
Color? priorityColor(ThemeData theme, TodoPriority priority) {
  final isDark = theme.brightness == Brightness.dark;
  return switch (priority) {
    TodoPriority.low =>
      isDark ? const Color(0xFF9AA4B2) : const Color(0xFF7A8494),
    TodoPriority.normal => null,
    TodoPriority.high =>
      isDark ? const Color(0xFFFFC66C) : const Color(0xFFE88B1E),
    TodoPriority.urgent =>
      isDark ? const Color(0xFFFF8A84) : const Color(0xFFD64545),
  };
}

/// The translated name of [option] as shown in the sort menu and in Settings.
String sortOptionName(AppLocalizations l10n, TodoSortOption option) {
  return switch (option) {
    TodoSortOption.manual => l10n.sortManual,
    TodoSortOption.nameAsc => l10n.sortNameAZ,
    TodoSortOption.nameDesc => l10n.sortNameZA,
    TodoSortOption.createdOldest => l10n.sortCreatedOldest,
    TodoSortOption.createdNewest => l10n.sortCreatedNewest,
    TodoSortOption.timeMost => l10n.sortTimeMost,
    TodoSortOption.timeLeast => l10n.sortTimeLeast,
    TodoSortOption.status => l10n.sortByStatus,
    TodoSortOption.priorityHigh => l10n.sortPriorityHigh,
  };
}

/// The icon shown next to [option] in the sort menu.
IconData sortOptionIcon(TodoSortOption option) {
  return switch (option) {
    TodoSortOption.manual => Icons.reorder,
    TodoSortOption.nameAsc => Icons.sort_by_alpha,
    TodoSortOption.nameDesc => Icons.sort_by_alpha,
    TodoSortOption.createdOldest => Icons.arrow_upward,
    TodoSortOption.createdNewest => Icons.arrow_downward,
    TodoSortOption.timeMost => Icons.timer,
    TodoSortOption.timeLeast => Icons.timer_outlined,
    TodoSortOption.status => Icons.flag_outlined,
    TodoSortOption.priorityHigh => Icons.priority_high_rounded,
  };
}

/// The translated name of a default target time option.
///
/// Anything under an hour reads as plain minutes; an hour or more reads as
/// hours plus any leftover minutes, so "90" shows as "1 h 30 m" rather than as
/// a number the reader has to divide.
String defaultTargetName(AppLocalizations l10n, DefaultTargetTime target) {
  if (target == DefaultTargetTime.none) return l10n.defaultsTargetNone;
  return formatTargetMinutes(target.minutes);
}

/// Writes [minutes] as a short target length, for example `45 m` or `1 h 30 m`.
String formatTargetMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '$rest m';
  if (rest == 0) return '$hours h';
  return '$hours h $rest m';
}
