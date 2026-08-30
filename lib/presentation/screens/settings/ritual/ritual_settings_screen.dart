import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Ritual mode.
///
/// Every switch here is device state kept in preferences. Nothing on this page
/// writes to the database, so none of it appears in a backup or a sync.
class RitualSettingsScreen extends ConsumerWidget {
  const RitualSettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ritualResetConfirmTitle),
        content: Text(l10n.ritualResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.ritualResetReviews),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await ref.read(ritualServiceProvider).resetAllReviews();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ritualResetDone)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(ritualProvider);
    final notifier = ref.read(ritualProvider.notifier);
    final on = settings.enabled;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ritualTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            AppSectionCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.enabled,
                    onChanged: notifier.setEnabled,
                    title: Text(l10n.ritualEnabled),
                    subtitle: Text(l10n.ritualEnabledDetail),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.openOnLaunch,
                    onChanged: on ? notifier.setOpenOnLaunch : null,
                    title: Text(l10n.ritualOpenOnLaunch),
                    subtitle: Text(l10n.ritualOpenOnLaunchDetail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // The rhythm stays pickable even with Ritual mode off, unlike the
            // switches below it. Choosing one changes nothing until the mode is
            // on, and it lets the whole thing be set up before it is switched on.
            SettingsChoiceList<BreathTechnique>(
              title: l10n.ritualBreathTechnique,
              selected: settings.technique,
              onChanged: notifier.setTechnique,
              choices: [
                SettingsChoice(
                  value: BreathTechnique.box,
                  label: l10n.ritualBreathBox,
                ),
                SettingsChoice(
                  value: BreathTechnique.relaxing,
                  label: l10n.ritualBreathRelaxing,
                ),
                SettingsChoice(
                  value: BreathTechnique.calm,
                  label: l10n.ritualBreathCalm,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.ritualBreathSection,
              child: Column(
                children: [
                  _BreathStepper(
                    label: l10n.ritualBreathCyclesLabel,
                    breaths: settings.breathCount,
                    enabled: on,
                    onChanged: notifier.setBreathCount,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.haptic,
                    onChanged: on ? notifier.setHaptic : null,
                    title: Text(l10n.ritualHaptic),
                    subtitle: Text(l10n.ritualHapticDetail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.ritualStepsSection,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.cardStep,
                    onChanged: on ? notifier.setCardStep : null,
                    title: Text(l10n.ritualCardStepSwitch),
                    subtitle: Text(l10n.ritualCardStepDetail),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.settleStep,
                    onChanged: on ? notifier.setSettleStep : null,
                    title: Text(l10n.ritualSettleStepSwitch),
                    subtitle: Text(l10n.ritualSettleStepDetail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.ritualEveningSection,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.eveningClose,
                    onChanged: on ? notifier.setEveningClose : null,
                    title: Text(l10n.ritualEveningClose),
                    subtitle: Text(l10n.ritualEveningCloseDetail),
                  ),
                  _HourStepper(
                    label: l10n.ritualEveningFrom,
                    hour: settings.eveningHour,
                    enabled: on && settings.eveningClose,
                    onChanged: notifier.setEveningHour,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.ritualDeckSection,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.style_outlined),
                    title: Text(l10n.ritualBrowseDeck),
                    subtitle: Text(l10n.ritualBrowseDeckDetail),
                    onTap: () => context.push(AppRoutes.ritualDeck),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: Text(l10n.ritualResetReviews),
                    subtitle: Text(l10n.ritualResetReviewsDetail),
                    onTap: () => _confirmReset(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: on ? () => context.push(AppRoutes.ritual) : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.ritualRunNow),
            ),
          ],
        ),
      ),
    );
  }
}

/// A minus / value / plus row for how many breaths the first step runs.
///
/// A stepper rather than a text field, so the count can never be left empty or
/// set to something the step cannot run.
class _BreathStepper extends StatelessWidget {
  const _BreathStepper({
    required this.label,
    required this.breaths,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int breaths;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            onPressed: enabled && breaths > kRitualMinBreaths
                ? () => onChanged(breaths - 1)
                : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96),
            child: Text(
              context.l10n.ritualBreathCount(breaths),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: enabled ? null : theme.disabledColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: label,
            onPressed: enabled && breaths < kRitualMaxBreaths
                ? () => onChanged(breaths + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

/// A minus / value / plus row for the hour the evening close starts.
///
/// Shown in the user's own clock format, so a 12-hour device reads "8 PM"
/// rather than "20:00".
class _HourStepper extends StatelessWidget {
  const _HourStepper({
    required this.label,
    required this.hour,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int hour;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = formatTime(DateTime(2000, 1, 1, hour));

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
            onPressed: enabled && hour > kRitualMinEveningHour
                ? () => onChanged(hour - 1)
                : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96),
            child: Text(
              shown,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: enabled ? null : theme.disabledColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: label,
            onPressed: enabled && hour < kRitualMaxEveningHour
                ? () => onChanged(hour + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
