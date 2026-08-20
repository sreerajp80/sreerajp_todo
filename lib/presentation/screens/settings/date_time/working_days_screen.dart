import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_format_rules.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_note_card.dart';
import 'package:sreerajp_todo/presentation/shared/date_time_labels.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Date & time -> Working days.
class WorkingDaysScreen extends ConsumerWidget {
  const WorkingDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(dateTimeSettingsProvider);
    final notifier = ref.read(dateTimeSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dateTimeWorkingDays)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: l10n.workingDaysTitle,
            subtitle: l10n.workingDaysSubtitle,
            child: Column(
              children: [
                for (final weekday in kAllWeekdays)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.workingDays.contains(weekday),
                    onChanged: (value) =>
                        notifier.toggleWorkingDay(weekday, value),
                    title: Text(weekdayName(weekday)),
                  ),
              ],
            ),
          ),
          if (settings.workingDays.isEmpty) ...[
            const SizedBox(height: 16),
            SettingsNoteCard(
              icon: Icons.warning_amber_rounded,
              text: l10n.workingDaysNoneWarning,
            ),
          ],
          const SizedBox(height: 16),
          AppSectionCard(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: notifier.resetWorkingDays,
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(l10n.workingDaysReset),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
