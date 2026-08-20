import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

/// "Help" hub reached from Settings -> Help.
/// Lists in-app help topics grouped into intuitive categories.
class HelpHomeScreen extends StatelessWidget {
  const HelpHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & User Guides')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 20),

          _buildSectionHeader(
            context,
            'Task Management & Workflow',
            Icons.checklist_rounded,
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.calendar_month_outlined,
            title: 'Daily Lists & Day Lock',
            subtitle:
                'How the daily timeline, day-lock immutability, and terminal status locks protect your records.',
            onTap: () => context.push(AppRoutes.helpTaskManagement),
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.repeat_rounded,
            title: 'Recurring Tasks & Bulk Copy',
            subtitle:
                'Setting up automated recurrence rules (daily, weekly, monthly) and bulk copying past tasks.',
            onTap: () => context.push(AppRoutes.helpRecurringTasks),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Time Tracking & Focus',
            Icons.timer_outlined,
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.more_time_rounded,
            title: 'Time Tracking & Segments',
            subtitle:
                'How multi-segment logging, target durations, and the single running timer rule work.',
            onTap: () => context.push(AppRoutes.helpTimeTracking),
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.center_focus_strong_rounded,
            title: 'Focus Mode & Pomodoro',
            subtitle:
                'Using the distraction-free focus screen, Pomodoro countdowns, and auto-stop safeguards.',
            onTap: () => context.push(AppRoutes.helpFocus),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Mastery Deck & Spaced Repetition',
            Icons.school_outlined,
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.psychology_outlined,
            title: 'Mastery Deck & Flashcards',
            subtitle:
                'How card decks, spaced repetition review intervals, and mastery scoring operate.',
            onTap: () => context.push(AppRoutes.helpMasteryDeck),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Sync & Offline Transfer',
            Icons.sync_alt_rounded,
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.wifi_tethering_rounded,
            title: 'Local Wi-Fi P2P Device Sync',
            subtitle:
                'Direct device-to-device synchronization over local Wi-Fi with end-to-end encryption and zero cloud.',
            onTap: () => context.push(AppRoutes.helpWifiSync),
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Air QR Scanner & Data Handoff',
            subtitle:
                'Transferring tasks and decks offline via visual animated QR code streams and clipboard handoff.',
            onTap: () => context.push(AppRoutes.helpQrHandoff),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Privacy, Security & Backups',
            Icons.shield_outlined,
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.security_rounded,
            title: 'Security, App Lock & Encryption',
            subtitle:
                'SQLCipher AES-256 database encryption, biometric authentication, and screenshot guard.',
            onTap: () => context.push(AppRoutes.helpPrivacySecurity),
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.backup_rounded,
            title: 'Encrypted Backup & Restore',
            subtitle:
                'Creating password-protected ZIP backup files, safety practices, and full restore steps.',
            onTap: () => context.push(AppRoutes.helpBackup),
          ),
          const SizedBox(height: 22),

          _buildSectionHeader(
            context,
            'Frequently Asked Questions',
            Icons.question_answer_outlined,
          ),
          const SizedBox(height: 10),
          HelpTopicCard(
            icon: Icons.help_outline_rounded,
            title: 'FAQs & Troubleshooting Guide',
            subtitle:
                'Direct answers to common questions about day lock, offline operation, and database safety.',
            onTap: () => context.push(AppRoutes.helpFaq),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
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
                    'Help Center & Knowledge Base',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse in-depth guides, rules, and solutions for all features of SreerajP ToDo.',
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
