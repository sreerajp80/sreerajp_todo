import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/focus_pulse_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Time tracking -> Focus mode.
class FocusModeScreen extends ConsumerWidget {
  const FocusModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(timeTrackingSettingsProvider);
    final notifier = ref.read(timeTrackingSettingsProvider.notifier);
    final pulseOn = settings.focusPulseMode.isOn;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingFocusMode)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsChoiceList<FocusPulseMode>(
              title: l10n.trackingFocusPulse,
              selected: settings.focusPulseMode,
              onChanged: notifier.setFocusPulseMode,
              choices: [
                SettingsChoice(
                  value: FocusPulseMode.off,
                  label: l10n.trackingFocusPulseOff,
                ),
                SettingsChoice(
                  value: FocusPulseMode.vibration,
                  label: l10n.trackingFocusPulseVibration,
                ),
                SettingsChoice(
                  value: FocusPulseMode.sound,
                  label: l10n.trackingFocusPulseSound,
                ),
                SettingsChoice(
                  value: FocusPulseMode.both,
                  label: l10n.trackingFocusPulseBoth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              child: _MinuteStepper(
                label: l10n.trackingFocusPulseEvery,
                minutes: settings.focusPulseIntervalMinutes,
                enabled: pulseOn,
                onChanged: notifier.setFocusPulseIntervalMinutes,
              ),
            ),
            const SizedBox(height: 16),
            SettingsNoteCard(
              icon: Icons.notifications_off_outlined,
              text: l10n.trackingFocusNote,
            ),
            // Pomodoro makes its own noise, so the two never sound together.
            if (settings.pomodoroEnabled) ...[
              const SizedBox(height: 16),
              SettingsNoteCard(
                icon: Icons.av_timer_rounded,
                text: l10n.trackingFocusPomodoroNote,
              ),
            ],
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.trackingFocusView,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: settings.focusImmersive,
                onChanged: notifier.setFocusImmersive,
                title: Text(l10n.trackingFocusImmersive),
                subtitle: Text(l10n.trackingFocusImmersiveDetail),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A minus / value / plus row for the gap between nudges.
///
/// A stepper is used rather than a free text field so the gap can never be
/// left empty or set to something the engine cannot run.
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

  /// Moves to the next whole step, so a value never drifts off the grid.
  int _next(int delta) {
    final raw = minutes + delta;
    if (raw <= kFocusPulseMinMinutes) return kFocusPulseMinMinutes;
    if (raw >= kFocusPulseMaxMinutes) return kFocusPulseMaxMinutes;
    final snapped =
        (raw / kFocusPulseStepMinutes).round() * kFocusPulseStepMinutes;
    return snapped.clamp(kFocusPulseMinMinutes, kFocusPulseMaxMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrease = enabled && minutes > kFocusPulseMinMinutes;
    final canIncrease = enabled && minutes < kFocusPulseMaxMinutes;

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
            onPressed: canDecrease
                ? () => onChanged(_next(-kFocusPulseStepMinutes))
                : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96),
            child: Text(
              context.l10n.trackingMinutes(minutes),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: enabled ? null : theme.disabledColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: label,
            onPressed: canIncrease
                ? () => onChanged(_next(kFocusPulseStepMinutes))
                : null,
          ),
        ],
      ),
    );
  }
}
