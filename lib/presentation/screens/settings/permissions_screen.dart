import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(strings.permissionsLabel)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            strings.permissionsSummary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          AppSectionCard(
            title: strings.permissionsImplicit,
            child: Column(
              children: [
                _PermissionTile(
                  icon: Icons.folder_outlined,
                  title: strings.permissionsStorageTitle,
                  body: strings.permissionsStorageBody,
                ),
                const Divider(height: 24),
                _PermissionTile(
                  icon: Icons.file_open_outlined,
                  title: strings.permissionsFilePickerTitle,
                  body: strings.permissionsFilePickerBody,
                ),
                const Divider(height: 24),
                _PermissionTile(
                  icon: Icons.schedule_outlined,
                  title: strings.permissionsSystemClockTitle,
                  body: strings.permissionsSystemClockBody,
                ),
                const Divider(height: 24),
                _PermissionTile(
                  icon: Icons.text_fields_outlined,
                  title: strings.permissionsTextProcessingTitle,
                  body: strings.permissionsTextProcessingBody,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: strings.permissionsExplicit,
            child: Text(
              strings.permissionsExplicitNone,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
