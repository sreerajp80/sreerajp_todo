import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/todo_sort_option.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Task defaults -> Day list.
class DefaultsDayListScreen extends ConsumerWidget {
  const DefaultsDayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final defaults = ref.watch(taskDefaultsProvider);
    final notifier = ref.read(taskDefaultsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.defaultsDayList)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsChoiceList<TodoSortOption>(
            title: l10n.defaultsSortTitle,
            subtitle: l10n.defaultsSortSubtitle,
            selected: defaults.sortOption,
            onChanged: notifier.setSortOption,
            choices: [
              for (final option in TodoSortOption.values)
                SettingsChoice(
                  value: option,
                  label: sortOptionName(l10n, option),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: defaults.rememberLastSort,
              onChanged: notifier.setRememberLastSort,
              title: Text(l10n.defaultsRememberSort),
              subtitle: Text(l10n.defaultsRememberSortDetail),
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: defaults.showCompleted,
                  onChanged: notifier.setShowCompleted,
                  title: Text(l10n.defaultsShowCompleted),
                  subtitle: Text(l10n.defaultsShowCompletedDetail),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: defaults.showDropped,
                  onChanged: notifier.setShowDropped,
                  title: Text(l10n.defaultsShowDropped),
                  subtitle: Text(l10n.defaultsShowDroppedDetail),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: defaults.sinkFinished,
                  onChanged: notifier.setSinkFinished,
                  title: Text(l10n.defaultsSinkFinished),
                  subtitle: Text(l10n.defaultsSinkFinishedDetail),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Off by default. Turning it on is what leads to the microphone
          // being asked for, so a fresh install never sees that prompt.
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: defaults.voiceInputEnabled,
                  onChanged: notifier.setVoiceInputEnabled,
                  title: Text(l10n.voiceInputSetting),
                  subtitle: Text(l10n.voiceInputSettingDetail),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.voiceInputTypingNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
