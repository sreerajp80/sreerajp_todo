import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class RecurringTasksHelpScreen extends StatelessWidget {
  const RecurringTasksHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Tasks & Bulk Copy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'Save time by automating repetitive daily routines, weekly meetings, and habit tasks '
            'using standard RFC-5545 recurrence rules or bulk copying tasks across days.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.repeat_rounded,
            title: 'Recurrence Rules (RRule)',
            children: [
              HelpBullet(
                'Create recurring rules with flexible frequencies: Daily, Weekly (selected weekdays), Monthly, or Custom intervals.',
              ),
              HelpBullet(
                'When you view a day, the app automatically generates that day\'s recurring task instances with preset priorities and target durations.',
              ),
              HelpBullet(
                'Editing or completing a single day’s recurring instance does not affect future or past instances.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.copy_all_rounded,
            title: 'Bulk Copying Past Tasks',
            children: [
              HelpBullet(
                'From the daily list menu, tap "Copy Tasks" to open the copy assistant.',
              ),
              HelpBullet(
                'Quickly select all unfinished tasks from yesterday or a custom past date and clone them into today’s list.',
              ),
              HelpBullet(
                'Copied tasks start fresh with status Pending and zero elapsed time segments.',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Tip: Use Recurring Tasks for regular habits (like morning workouts or reviews), and Bulk Copy for ad-hoc carried-over items.',
          ),
        ],
      ),
    );
  }
}
