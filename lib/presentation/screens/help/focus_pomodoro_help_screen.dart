import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

class FocusPomodoroHelpScreen extends StatelessWidget {
  const FocusPomodoroHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpFocusTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            HelpIntro(l10n.helpFocusIntro),
            const SizedBox(height: 24),
            HelpSection(
              icon: Icons.center_focus_strong_rounded,
              title: l10n.helpFocusScreenTitle,
              children: [
                HelpBullet(l10n.helpFocusScreen1),
                HelpBullet(l10n.helpFocusScreen2),
                HelpBullet(l10n.helpFocusScreen3),
              ],
            ),
            HelpSection(
              icon: Icons.hourglass_top_rounded,
              title: l10n.helpFocusPomodoroTitle,
              children: [
                HelpBullet(l10n.helpFocusPomodoro1),
                HelpBullet(l10n.helpFocusPomodoro2),
                HelpBullet(l10n.helpFocusPomodoro3),
              ],
            ),
            const SizedBox(height: 8),
            HelpFooter(l10n.helpFocusTip),
          ],
        ),
      ),
    );
  }
}
