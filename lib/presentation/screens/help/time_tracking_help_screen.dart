import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class TimeTrackingHelpScreen extends StatelessWidget {
  const TimeTrackingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Tracking & Segments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'SreerajP ToDo includes a built-in time tracker that measures the real duration spent on each task. '
            'Each task records time through individual start and end intervals called Time Segments.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.timer_outlined,
            title: 'Time Segments Architecture',
            children: [
              HelpBullet(
                'Each time you start and stop the timer, a Time Segment is recorded with an exact start timestamp and end timestamp.',
              ),
              HelpBullet(
                'A task can contain multiple segments (e.g. morning work session, afternoon session). The total time is the sum of all segments.',
              ),
              HelpBullet(
                'Durations are always displayed in standard HH:MM:SS format across the entire app.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.play_circle_outline_rounded,
            title: 'Single Running Timer Rule',
            children: [
              HelpBullet(
                'At most one open time segment (running timer) can exist across the entire app at any time.',
              ),
              HelpBullet(
                'Starting a timer on a new task automatically stops any currently running timer on another task.',
              ),
              HelpBullet(
                'This single-active-timer guarantee prevents conflicting logs and inflated tracking numbers.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.bolt_rounded,
            title: 'Auto-Stop & Background Pausing',
            children: [
              HelpBullet(
                'Under Settings → Time Tracking, you can configure timers to automatically stop at midnight or at a custom hour.',
              ),
              HelpBullet(
                'You can enable "Auto-pause when leaving the app" to pause tracking if you switch to other apps.',
              ),
              HelpBullet(
                'Short accidental timer taps under a configurable threshold (e.g. 10s or 30s) can be automatically discarded.',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Tip: Tap the stopwatch icon or time badge on any task card to start tracking instantly. Tap it again to stop.',
          ),
        ],
      ),
    );
  }
}
