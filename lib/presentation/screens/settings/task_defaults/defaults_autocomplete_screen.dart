import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Task defaults -> Autocomplete.
class DefaultsAutocompleteScreen extends ConsumerWidget {
  const DefaultsAutocompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final defaults = ref.watch(taskDefaultsProvider);
    final notifier = ref.read(taskDefaultsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.defaultsAutocomplete)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: defaults.autocompleteEnabled,
              onChanged: notifier.setAutocompleteEnabled,
              title: Text(l10n.defaultsAutocompleteEnabled),
              subtitle: Text(l10n.defaultsAutocompleteEnabledDetail),
            ),
          ),
          const SizedBox(height: 16),
          // With suggestions off there is nothing to count, so the list is
          // hidden instead of shown with no effect.
          if (defaults.autocompleteEnabled)
            SettingsChoiceList<SuggestionCount>(
              title: l10n.defaultsSuggestionCountTitle,
              selected: defaults.suggestionCount,
              onChanged: notifier.setSuggestionCount,
              choices: [
                for (final count in SuggestionCount.values)
                  SettingsChoice(
                    value: count,
                    label: l10n.suggestionCountValue(count.limit),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
