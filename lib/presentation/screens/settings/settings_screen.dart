import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLabel)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SettingsNavCard(
              icon: Icons.palette_outlined,
              title: l10n.settingsAppearance,
              subtitle: l10n.settingsAppearanceSubtitle,
              onTap: () => context.push(AppRoutes.appearance),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.stars_outlined,
              title: l10n.settingsFeatures,
              subtitle: l10n.settingsFeaturesSubtitle,
              onTap: () => context.push(AppRoutes.features),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.help_outline_rounded,
              title: l10n.settingsHelp,
              subtitle: l10n.settingsHelpSubtitle,
              onTap: () => context.push(AppRoutes.help),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.language_outlined,
              title: l10n.settingsLanguage,
              subtitle: l10n.settingsLanguageSubtitle,
              onTap: () => context.push(AppRoutes.language),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.checklist_rounded,
              title: l10n.settingsTaskDefaults,
              subtitle: l10n.settingsTaskDefaultsSubtitle,
              onTap: () => context.push(AppRoutes.taskDefaults),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.notifications_active_outlined,
              title: l10n.pendingAlertsTitle,
              subtitle: l10n.pendingAlertsSubtitle,
              onTap: () => context.push(AppRoutes.pendingAlerts),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.self_improvement_rounded,
              title: l10n.settingsRitual,
              subtitle: l10n.settingsRitualSubtitle,
              onTap: () => context.push(AppRoutes.ritualSettings),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.event_available_outlined,
              title: l10n.settingsDateTime,
              subtitle: l10n.settingsDateTimeSubtitle,
              onTap: () => context.push(AppRoutes.dateTime),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.timer_outlined,
              title: l10n.settingsTimeTracking,
              subtitle: l10n.settingsTimeTrackingSubtitle,
              onTap: () => context.push(AppRoutes.timeTracking),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.backup_rounded,
              title: l10n.backupLabel,
              subtitle: l10n.settingsBackupSubtitle,
              onTap: () => context.push(AppRoutes.backup),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.shield_outlined,
              title: l10n.settingsPermissions,
              subtitle: l10n.settingsPermissionsSubtitle,
              onTap: () => context.push(AppRoutes.permissions),
            ),
            const SizedBox(height: 16),
            SettingsNavCard(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAboutApp,
              subtitle: l10n.settingsAboutSubtitle,
              onTap: () => context.push(AppRoutes.about),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: l10n.settingsOfflineTitle,
              child: Text(l10n.settingsOfflineBody),
            ),
          ],
        ),
      ),
    );
  }
}
