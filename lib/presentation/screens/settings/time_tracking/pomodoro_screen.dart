import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/application/time_tracking_settings_notifier.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Time tracking -> Pomodoro.
class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(timeTrackingSettingsProvider);
    final notifier = ref.read(timeTrackingSettingsProvider.notifier);
    final enabled = settings.pomodoroEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingPomodoro)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            AppSectionCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: enabled,
                onChanged: notifier.setPomodoroEnabled,
                title: Text(l10n.trackingPomodoroEnabled),
                subtitle: Text(l10n.trackingPomodoroEnabledDetail),
              ),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.trackingPomodoro,
              child: Column(
                children: [
                  _MinuteStepper(
                    label: l10n.trackingPomodoroWork,
                    minutes: settings.pomodoroWorkMinutes,
                    enabled: enabled,
                    onChanged: notifier.setPomodoroWorkMinutes,
                  ),
                  _MinuteStepper(
                    label: l10n.trackingPomodoroShortBreak,
                    minutes: settings.pomodoroShortBreakMinutes,
                    enabled: enabled,
                    onChanged: notifier.setPomodoroShortBreakMinutes,
                  ),
                  _MinuteStepper(
                    label: l10n.trackingPomodoroLongBreak,
                    minutes: settings.pomodoroLongBreakMinutes,
                    enabled: enabled,
                    onChanged: notifier.setPomodoroLongBreakMinutes,
                  ),
                  _Stepper(
                    label: l10n.trackingPomodoroBlocks,
                    value: settings.pomodoroBlocksBeforeLongBreak,
                    valueLabel: l10n.trackingBlocks(
                      settings.pomodoroBlocksBeforeLongBreak,
                    ),
                    min: kPomodoroMinBlocks,
                    max: kPomodoroMaxBlocks,
                    step: 1,
                    enabled: enabled,
                    onChanged: notifier.setPomodoroBlocksBeforeLongBreak,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.pomodoroAutoStartNext,
                    onChanged: enabled
                        ? notifier.setPomodoroAutoStartNext
                        : null,
                    title: Text(l10n.trackingPomodoroAutoStart),
                    subtitle: Text(l10n.trackingPomodoroAutoStartDetail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SettingsNoteCard(
              icon: Icons.notifications_off_outlined,
              text: l10n.trackingPomodoroNote,
            ),
          ],
        ),
      ),
    );
  }
}

/// A stepper whose value is a number of minutes.
class _MinuteStepper extends StatelessWidget {
  const _MinuteStepper({
    required this.label,
    required this.minutes,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int minutes;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Stepper(
      label: label,
      value: minutes,
      valueLabel: context.l10n.trackingMinutes(minutes),
      min: kPomodoroMinMinutes,
      max: kPomodoroMaxMinutes,
      step: 5,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

/// A plain minus / value / plus row.
///
/// A stepper is used rather than a free text field so a length can never be
/// left empty or set to something the engine cannot run.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.step,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final String valueLabel;
  final int min;
  final int max;
  final int step;
  final bool enabled;
  final ValueChanged<int> onChanged;

  /// Moves to the next whole step, so 25 minus a 5-step lands on 20 rather
  /// than drifting off the grid.
  int _next(int delta) {
    final raw = value + delta;
    if (raw <= min) return min;
    if (raw >= max) return max;
    if (step <= 1) return raw;
    final snapped = (raw / step).round() * step;
    return snapped.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = enabled && value > min;
    final canIncrease = enabled && value < max;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: enabled ? null : theme.disabledColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: label,
            onPressed: canDecrease ? () => onChanged(_next(-step)) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96),
            child: Text(
              valueLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: enabled ? null : theme.disabledColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: label,
            onPressed: canIncrease ? () => onChanged(_next(step)) : null,
          ),
        ],
      ),
    );
  }
}
