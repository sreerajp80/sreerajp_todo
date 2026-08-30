import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class FocusPomodoroHelpScreen extends StatelessWidget {
  const FocusPomodoroHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Mode & Pomodoro')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: const [
            HelpIntro(
              'Focus Mode provides a distraction-free full-screen environment for deep work sessions, '
              'coupled with customizable Pomodoro intervals and target duration countdowns.',
            ),
            SizedBox(height: 24),
            HelpSection(
              icon: Icons.center_focus_strong_rounded,
              title: 'Full-Screen Focus Mode',
              children: [
                HelpBullet(
                  'Open Focus Mode from any task details menu to immerse in a clean, distraction-free screen.',
                ),
                HelpBullet(
                  'Focus Mode displays a large elapsed or countdown timer, target progress ring, and quick pause/resume controls.',
                ),
                HelpBullet(
                  'Keep-screen-awake mode keeps your display active while your focus timer is running.',
                ),
              ],
            ),
            HelpSection(
              icon: Icons.hourglass_top_rounded,
              title: 'Pomodoro Technique',
              children: [
                HelpBullet(
                  'Customize your focus work duration (e.g. 25 minutes) and break intervals (e.g. 5 minutes) under Settings → Time Tracking → Pomodoro.',
                ),
                HelpBullet(
                  'Audio and haptic vibrations signal the end of work intervals and break periods.',
                ),
                HelpBullet(
                  'All focus sessions seamlessly record standard Time Segments under the parent task.',
                ),
              ],
            ),
            SizedBox(height: 8),
            HelpFooter(
              'Tip: Target durations can be configured when creating or editing a task to automatically calculate your remaining focus time.',
            ),
          ],
        ),
      ),
    );
  }
}
