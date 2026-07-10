import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_version.g.dart';
import 'package:sreerajp_todo/core/constants/build_date.g.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/about/widgets/about_info_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.aboutLabel)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: kAppName,
            subtitle: context.l10n.aboutHeadline,
            child: Text(
              context.l10n.aboutSummary,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              children: [
                _AboutDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.aboutAuthor,
                  value: context.l10n.aboutAuthorName,
                ),
                const SizedBox(height: 12),
                _AboutDetailRow(
                  icon: Icons.auto_awesome_outlined,
                  label: context.l10n.aboutAiAssisted,
                  value: context.l10n.aboutAiModels,
                ),
                const SizedBox(height: 12),
                _AboutDetailRow(
                  icon: Icons.info_outline_rounded,
                  label: context.l10n.aboutAppVersion,
                  value: kAppVersion,
                ),
                const SizedBox(height: 12),
                _AboutDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: context.l10n.aboutBuildDate,
                  value: kBuildDate,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.aboutMadeWithLoveIn,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              children: [
                AboutInfoTile(
                  icon: Icons.lock_outline_rounded,
                  title: context.l10n.aboutLocalOnlyTitle,
                  body: context.l10n.aboutLocalOnlyBody,
                ),
                const SizedBox(height: 16),
                AboutInfoTile(
                  icon: Icons.key_rounded,
                  title: context.l10n.aboutBackupTitle,
                  body: context.l10n.aboutBackupBody,
                ),
                const SizedBox(height: 16),
                AboutInfoTile(
                  icon: Icons.translate_rounded,
                  title: context.l10n.aboutUnicodeTitle,
                  body: context.l10n.aboutUnicodeBody,
                ),
                const SizedBox(height: 16),
                AboutInfoTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: context.l10n.aboutNavigationTitle,
                  body: context.l10n.aboutNavigationBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutDetailRow extends StatelessWidget {
  const _AboutDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
