import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const strings = AppStrings.permissions;

    return Scaffold(
      appBar: AppBar(title: Text(strings.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            strings.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          AppSectionCard(
            title: strings.implicit,
            child: Column(
              children: [
                _PermissionTile(
                  icon: Icons.folder_outlined,
                  title: strings.storageTitle,
                  body: strings.storageBody,
                ),
                const Divider(height: 24),
                _PermissionTile(
                  icon: Icons.file_open_outlined,
                  title: strings.filePickerTitle,
                  body: strings.filePickerBody,
                ),
                const Divider(height: 24),
                _PermissionTile(
                  icon: Icons.schedule_outlined,
                  title: strings.systemClockTitle,
                  body: strings.systemClockBody,
                ),
                const Divider(height: 24),
                _PermissionTile(
                  icon: Icons.text_fields_outlined,
                  title: strings.textProcessingTitle,
                  body: strings.textProcessingBody,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: strings.explicit,
            child: Text(
              strings.explicitNone,
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
