import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// A quiet information card used to state a limit or a caveat plainly, in the
/// same shape the Theme mode page already uses.
class SettingsNoteCard extends StatelessWidget {
  const SettingsNoteCard({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
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
