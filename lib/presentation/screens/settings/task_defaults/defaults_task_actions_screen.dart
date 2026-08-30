import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: defaults.autoCarryOverEnabled,
                    onChanged: notifier.setAutoCarryOverEnabled,
                    title: Text(l10n.defaultsAutoCarryOver),
                    subtitle: Text(l10n.defaultsAutoCarryOverDetail),
                  ),
                  if (!defaults.autoCarryOverEnabled) ...[
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: defaults.carryOverEnabled,
                      onChanged: notifier.setCarryOverEnabled,
                      title: Text(l10n.defaultsCarryOver),
                      subtitle: Text(l10n.defaultsCarryOverDetail),
                    ),
                  ],
                ],
              ),
            ),
            if (defaults.autoCarryOverEnabled || defaults.carryOverEnabled) ...[
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.defaultsCarryOverLookBackTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            defaults.carryOverLookBackDays == 1
                                ? '1 day (Yesterday)'
                                : '${defaults.carryOverLookBackDays} days',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: defaults.carryOverLookBackDays.toDouble(),
                      min: kMinCarryOverLookBackDays.toDouble(),
                      max: kMaxCarryOverLookBackDays.toDouble(),
                      divisions:
                          kMaxCarryOverLookBackDays - kMinCarryOverLookBackDays,
                      label: '${defaults.carryOverLookBackDays} days',
                      onChanged: (val) =>
                          notifier.setCarryOverLookBackDays(val.round()),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in CarryOverLookBack.values)
                          ChoiceChip(
                            label: Text(
                              preset == CarryOverLookBack.previousDay
                                  ? '1d (Yesterday)'
                                  : '${preset.days}d',
                            ),
                            selected:
                                defaults.carryOverLookBackDays == preset.days,
                            onSelected: (selected) {
                              if (selected) {
                                notifier.setCarryOverLookBack(preset);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
