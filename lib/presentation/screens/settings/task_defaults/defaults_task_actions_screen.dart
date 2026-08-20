import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Task defaults -> Task actions.
class DefaultsTaskActionsScreen extends ConsumerWidget {
  const DefaultsTaskActionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final defaults = ref.watch(taskDefaultsProvider);
    final notifier = ref.read(taskDefaultsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.defaultsTaskActions)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: defaults.confirmComplete,
                  onChanged: notifier.setConfirmComplete,
                  title: Text(l10n.defaultsConfirmComplete),
                  subtitle: Text(l10n.defaultsConfirmCompleteDetail),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: defaults.confirmDrop,
                  onChanged: notifier.setConfirmDrop,
                  title: Text(l10n.defaultsConfirmDrop),
                  subtitle: Text(l10n.defaultsConfirmDropDetail),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: defaults.carryOverEnabled,
              onChanged: notifier.setCarryOverEnabled,
              title: Text(l10n.defaultsCarryOver),
              subtitle: Text(l10n.defaultsCarryOverDetail),
            ),
          ),
          const SizedBox(height: 16),
          // The look-back only matters once the prompt is on, so it is hidden
          // rather than shown greyed out with nothing to do.
          if (defaults.carryOverEnabled)
            SettingsChoiceList<CarryOverLookBack>(
              title: l10n.defaultsCarryOverLookBackTitle,
              selected: defaults.carryOverLookBack,
              onChanged: notifier.setCarryOverLookBack,
              choices: [
                SettingsChoice(
                  value: CarryOverLookBack.previousDay,
                  label: l10n.defaultsCarryOverPreviousDay,
                ),
                SettingsChoice(
                  value: CarryOverLookBack.lastSevenDays,
                  label: l10n.defaultsCarryOverLastSevenDays,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
