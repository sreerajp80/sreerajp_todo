import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';

/// Task defaults hub reached from Settings -> Task defaults. It only holds
/// links to the pages that own the actual settings.
class TaskDefaultsScreen extends StatelessWidget {
  const TaskDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTaskDefaults)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsNavCard(
              icon: Icons.add_task_rounded,
              title: l10n.defaultsNewTask,
              subtitle: l10n.defaultsNewTaskSubtitle,
              onTap: () => context.push(AppRoutes.defaultsNewTask),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.view_day_outlined,
              title: l10n.defaultsDayList,
              subtitle: l10n.defaultsDayListSubtitle,
              onTap: () => context.push(AppRoutes.defaultsDayList),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.rule_rounded,
              title: l10n.defaultsTaskActions,
              subtitle: l10n.defaultsTaskActionsSubtitle,
              onTap: () => context.push(AppRoutes.defaultsTaskActions),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.keyboard_alt_outlined,
              title: l10n.defaultsAutocomplete,
              subtitle: l10n.defaultsAutocompleteSubtitle,
              onTap: () => context.push(AppRoutes.defaultsAutocomplete),
            ),
          ],
        ),
      ),
    );
  }
}
