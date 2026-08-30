import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';
import 'package:sreerajp_todo/data/models/todo_priority.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/task_default_labels.dart';

/// Settings -> Task defaults -> New task.
class DefaultsNewTaskScreen extends ConsumerWidget {
  const DefaultsNewTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final defaults = ref.watch(taskDefaultsProvider);
    final notifier = ref.read(taskDefaultsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.defaultsNewTask)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsChoiceList<NewTaskStatus>(
              title: l10n.defaultsStatusTitle,
              subtitle: l10n.defaultsStatusSubtitle,
              selected: defaults.newTaskStatus,
              onChanged: notifier.setNewTaskStatus,
              choices: [
                SettingsChoice(
                  value: NewTaskStatus.pending,
                  label: l10n.statusPending,
                  detail: l10n.defaultsStatusPendingDetail,
                ),
                SettingsChoice(
                  value: NewTaskStatus.working,
                  label: l10n.statusWorking,
                  detail: l10n.defaultsStatusWorkingDetail,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsChoiceList<TodoPriority>(
              title: l10n.defaultsPriorityTitle,
              subtitle: l10n.defaultsPrioritySubtitle,
              selected: defaults.priority,
              onChanged: notifier.setPriority,
              choices: [
                for (final priority in TodoPriority.values)
                  SettingsChoice(
                    value: priority,
                    label: priorityName(l10n, priority),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsChoiceList<DefaultTargetTime>(
              title: l10n.defaultsTargetTitle,
              subtitle: l10n.defaultsTargetSubtitle,
              selected: defaults.targetTime,
              onChanged: notifier.setTargetTime,
              choices: [
                for (final target in DefaultTargetTime.values)
                  SettingsChoice(
                    value: target,
                    label: defaultTargetName(l10n, target),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
