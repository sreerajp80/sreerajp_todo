import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';

/// Date & time hub reached from Settings -> Date & time. It only holds links
/// to the pages that own the actual settings.
class DateTimeScreen extends StatelessWidget {
  const DateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDateTime)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsNavCard(
            icon: Icons.calendar_view_week_rounded,
            title: l10n.dateTimeWeekStart,
            subtitle: l10n.dateTimeWeekStartSubtitle,
            onTap: () => context.push(AppRoutes.weekStart),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.schedule_rounded,
            title: l10n.dateTimeClock,
            subtitle: l10n.dateTimeClockSubtitle,
            onTap: () => context.push(AppRoutes.clockFormat),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.event_note_rounded,
            title: l10n.dateTimeDateFormat,
            subtitle: l10n.dateTimeDateFormatSubtitle,
            onTap: () => context.push(AppRoutes.dateFormat),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.nightlight_round,
            title: l10n.dateTimeDayStart,
            subtitle: l10n.dateTimeDayStartSubtitle,
            onTap: () => context.push(AppRoutes.dayStart),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.work_history_outlined,
            title: l10n.dateTimeWorkingDays,
            subtitle: l10n.dateTimeWorkingDaysSubtitle,
            onTap: () => context.push(AppRoutes.workingDays),
          ),
        ],
      ),
    );
  }
}
