import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/pending_todos_alert_sheet.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_choice_list.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Settings -> Pending Task Alerts.
class PendingAlertsScreen extends ConsumerWidget {
  const PendingAlertsScreen({super.key});

  Future<void> _pickDayStartTime(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );
    if (picked == null || !context.mounted) return;
    await ref
        .read(pendingAlertSettingsProvider.notifier)
        .setDayStartTime(picked.hour, picked.minute);
  }

  Future<void> _previewAlert(BuildContext context, WidgetRef ref) async {
    final payload = await ref.read(pendingAlertPayloadProvider.future);
    if (!context.mounted) return;
    await PendingTodosAlertSheet.showPayload(context, payload);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(pendingAlertSettingsProvider);
    final notifier = ref.read(pendingAlertSettingsProvider.notifier);
    final on = settings.enabled;

    final formattedDayStartTime = formatTime(
      DateTime(2000, 1, 1, settings.dayStartHour, settings.dayStartMinute),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pendingAlertsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Master switch
            AppSectionCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: settings.enabled,
                onChanged: notifier.setEnabled,
                title: Text(l10n.pendingAlertsEnabled),
                subtitle: Text(l10n.pendingAlertsEnabledDetail),
              ),
            ),
            const SizedBox(height: 16),

            // Day start alert
            AppSectionCard(
              title: l10n.pendingAlertsDayStart,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.dayStartAlertEnabled,
                    onChanged: on ? notifier.setDayStartAlertEnabled : null,
                    title: Text(l10n.pendingAlertsDayStart),
                    subtitle: Text(l10n.pendingAlertsDayStartDetail),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: on && settings.dayStartAlertEnabled,
                    leading: const Icon(Icons.access_time_rounded),
                    title: Text(l10n.pendingAlertsDayStartTime),
                    trailing: Text(
                      formattedDayStartTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: (on && settings.dayStartAlertEnabled)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).disabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: (on && settings.dayStartAlertEnabled)
                        ? () => _pickDayStartTime(
                            context,
                            ref,
                            settings.dayStartHour,
                            settings.dayStartMinute,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interval Choice List
            SettingsChoiceList<int>(
              title: l10n.pendingAlertsInterval,
              subtitle: l10n.pendingAlertsIntervalDetail,
              selected: settings.intervalMinutes,
              onChanged: (val) {
                if (on) notifier.setIntervalMinutes(val);
              },
              choices: [
                SettingsChoice(value: 0, label: l10n.pendingAlertsIntervalOff),
                SettingsChoice(value: 30, label: l10n.pendingAlertsInterval30m),
                SettingsChoice(value: 60, label: l10n.pendingAlertsInterval1h),
                SettingsChoice(value: 120, label: l10n.pendingAlertsInterval2h),
                SettingsChoice(value: 180, label: l10n.pendingAlertsInterval3h),
                SettingsChoice(value: 240, label: l10n.pendingAlertsInterval4h),
              ],
            ),
            const SizedBox(height: 16),

            // Haptic Feedback
            AppSectionCard(
              title: l10n.pendingAlertsHaptic,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: settings.haptic,
                onChanged: on ? notifier.setHaptic : null,
                title: Text(l10n.pendingAlertsHaptic),
                subtitle: Text(l10n.pendingAlertsHapticDetail),
              ),
            ),
            const SizedBox(height: 24),

            // Preview Button
            FilledButton.tonalIcon(
              onPressed: () => _previewAlert(context, ref),
              icon: const Icon(Icons.preview_rounded),
              label: Text(l10n.pendingAlertsPreview),
            ),
          ],
        ),
      ),
    );
  }
}
