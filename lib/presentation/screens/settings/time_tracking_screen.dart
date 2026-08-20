import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/settings/widgets/settings_nav_card.dart';

/// Time tracking hub reached from Settings -> Time tracking. It only holds
/// links to the pages that own the actual settings.
class TimeTrackingScreen extends StatelessWidget {
  const TimeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTimeTracking)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsNavCard(
            icon: Icons.timer_off_outlined,
            title: l10n.trackingAutoStop,
            subtitle: l10n.trackingAutoStopSubtitle,
            onTap: () => context.push(AppRoutes.autoStop),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.tune_rounded,
            title: l10n.trackingTimerBehaviour,
            subtitle: l10n.trackingTimerBehaviourSubtitle,
            onTap: () => context.push(AppRoutes.timerBehaviour),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.av_timer_rounded,
            title: l10n.trackingPomodoro,
            subtitle: l10n.trackingPomodoroSubtitle,
            onTap: () => context.push(AppRoutes.pomodoro),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.center_focus_strong_rounded,
            title: l10n.trackingFocusMode,
            subtitle: l10n.trackingFocusModeSubtitle,
            onTap: () => context.push(AppRoutes.focusMode),
          ),
          const SizedBox(height: 16),
          SettingsNavCard(
            icon: Icons.schedule_rounded,
            title: l10n.trackingTimeDisplay,
            subtitle: l10n.trackingTimeDisplaySubtitle,
            onTap: () => context.push(AppRoutes.timeDisplay),
          ),
        ],
      ),
    );
  }
}
