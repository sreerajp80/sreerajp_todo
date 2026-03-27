import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/constants/build_date.g.dart';
import 'package:sreerajp_todo/presentation/screens/about/widgets/about_info_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.about.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: AppStrings.appName,
            subtitle: AppStrings.about.headline,
            child: Text(
              AppStrings.about.summary,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              children: [
                _AboutDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.about.author,
                  value: AppStrings.about.authorName,
                ),
                const SizedBox(height: 12),
                _AboutDetailRow(
                  icon: Icons.auto_awesome_outlined,
                  label: AppStrings.about.aiAssisted,
                  value: AppStrings.about.aiModels,
                ),
                const SizedBox(height: 12),
                _AboutDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: AppStrings.about.buildDate,
                  value: kBuildDate,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.about.madeWithLoveIn,
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
                  title: AppStrings.about.localOnlyTitle,
                  body: AppStrings.about.localOnlyBody,
                ),
                const SizedBox(height: 16),
                AboutInfoTile(
                  icon: Icons.key_rounded,
                  title: AppStrings.about.backupTitle,
                  body: AppStrings.about.backupBody,
                ),
                const SizedBox(height: 16),
                AboutInfoTile(
                  icon: Icons.translate_rounded,
                  title: AppStrings.about.unicodeTitle,
                  body: AppStrings.about.unicodeBody,
                ),
                const SizedBox(height: 16),
                AboutInfoTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: AppStrings.about.navigationTitle,
                  body: AppStrings.about.navigationBody,
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
