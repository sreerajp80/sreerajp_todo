import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

/// "Help" hub reached from Settings -> Help.
/// Lists in-app help topics grouped into intuitive categories.
class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settingsHelp)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 20),

            _buildSectionHeader(
              context,
              l10n.helpHomeTaskSection,
              Icons.checklist_rounded,
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.calendar_month_outlined,
              title: l10n.helpTaskMgmtTitle,
              subtitle: l10n.helpHomeTaskMgmtSubtitle,
              onTap: () => context.push(AppRoutes.helpTaskManagement),
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.repeat_rounded,
              title: l10n.helpRecurringTitle,
              subtitle: l10n.helpHomeRecurringSubtitle,
              onTap: () => context.push(AppRoutes.helpRecurringTasks),
            ),
            const SizedBox(height: 22),

            _buildSectionHeader(
              context,
              l10n.helpHomeTimeSection,
              Icons.timer_outlined,
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.more_time_rounded,
              title: l10n.helpTimeTrackingTitle,
              subtitle: l10n.helpHomeTimeTrackingSubtitle,
              onTap: () => context.push(AppRoutes.helpTimeTracking),
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.center_focus_strong_rounded,
              title: l10n.helpFocusTitle,
              subtitle: l10n.helpHomeFocusSubtitle,
              onTap: () => context.push(AppRoutes.helpFocus),
            ),
            const SizedBox(height: 22),

            _buildSectionHeader(
              context,
              l10n.helpHomeMasterySection,
              Icons.school_outlined,
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.psychology_outlined,
              title: l10n.helpMasteryTitle,
              subtitle: l10n.helpHomeMasterySubtitle,
              onTap: () => context.push(AppRoutes.helpMasteryDeck),
            ),
            const SizedBox(height: 22),

            _buildSectionHeader(
              context,
              l10n.helpHomeSyncSection,
              Icons.sync_alt_rounded,
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.wifi_tethering_rounded,
              title: l10n.helpWifiTitle,
              subtitle: l10n.helpHomeWifiSubtitle,
              onTap: () => context.push(AppRoutes.helpWifiSync),
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.qr_code_scanner_rounded,
              title: l10n.helpHomeQrTitle,
              subtitle: l10n.helpHomeQrSubtitle,
              onTap: () => context.push(AppRoutes.helpQrHandoff),
            ),
            const SizedBox(height: 22),

            _buildSectionHeader(
              context,
              l10n.helpHomePrivacySection,
              Icons.shield_outlined,
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.security_rounded,
              title: l10n.helpPrivacyTitle,
              subtitle: l10n.helpHomePrivacySubtitle,
              onTap: () => context.push(AppRoutes.helpPrivacySecurity),
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.backup_rounded,
              title: l10n.helpBackupTitle,
              subtitle: l10n.helpHomeBackupSubtitle,
              onTap: () => context.push(AppRoutes.helpBackup),
            ),
            const SizedBox(height: 22),

            _buildSectionHeader(
              context,
              l10n.helpHomeFaqSection,
              Icons.question_answer_outlined,
            ),
            const SizedBox(height: 10),
            HelpTopicCard(
              icon: Icons.help_outline_rounded,
              title: l10n.helpHomeFaqTitle,
              subtitle: l10n.helpHomeFaqSubtitle,
              onTap: () => context.push(AppRoutes.helpFaq),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.12),
              colorScheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_center_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.helpHomeHeaderTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpHomeHeaderSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
