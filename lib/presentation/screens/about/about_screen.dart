import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/config/app_config.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/build_date.g.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/about/widgets/about_info_tile.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final configAsync = ref.watch(appConfigProvider);
    final config = configAsync.value ?? AppConfig.fallback;

    final detailEntries = config.details.entries
        .where((e) => e.key.trim().isNotEmpty && e.value.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.aboutLabel)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: config.appName.isNotEmpty ? config.appName : kAppName,
            subtitle: context.l10n.aboutHeadline,
            child: Text(
              config.description.isNotEmpty
                  ? config.description
                  : context.l10n.aboutSummary,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              children: [
                _AboutDetailRow(
                  icon: Icons.info_outline_rounded,
                  label: context.l10n.aboutAppVersion,
                  value: config.version,
                ),
                if (config.build.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AboutDetailRow(
                    icon: Icons.tag_rounded,
                    label: context.l10n.aboutBuildNumber,
                    value: config.build,
                  ),
                ],
                const SizedBox(height: 12),
                _AboutDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: context.l10n.aboutBuildDate,
                  value: kBuildDate,
                ),
                for (final entry in detailEntries) ...[
                  const SizedBox(height: 12),
                  _AboutDetailRow(
                    icon: _iconForDetailKey(entry.key),
                    label: entry.key,
                    value: entry.value,
                  ),
                ],
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

  IconData _iconForDetailKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('author')) return Icons.person_outline_rounded;
    if (k.contains('ai')) return Icons.auto_awesome_outlined;
    if (k.contains('ide')) return Icons.code_rounded;
    if (k.contains('license')) return Icons.description_outlined;
    return Icons.label_outline_rounded;
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
