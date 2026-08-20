import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class TaskManagementHelpScreen extends StatelessWidget {
  const TaskManagementHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Lists & Day Lock')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'SreerajP ToDo organizes your tasks strictly on a day-by-day basis. '
            'Learn how the daily list, day lock protection, and terminal status locks maintain the integrity of your productivity logs.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.lock_clock_outlined,
            title: 'The Day Lock Principle',
            children: [
              HelpBullet(
                'Tasks dated prior to today are permanently read-only and cannot be modified or deleted.',
              ),
              HelpBullet(
                'This ensures historical data remains an authentic, unedited reflection of what actually occurred.',
              ),
              HelpBullet(
                'If you need to work on an incomplete task from yesterday, copy it to today’s list rather than editing the past.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.checklist_rounded,
            title: 'Task Statuses & Terminal Locks',
            children: [
              HelpBullet(
                'Tasks progress through statuses: Pending, Working, Completed, and Dropped.',
              ),
              HelpBullet(
                'Completed and Dropped are terminal statuses. Once a task reaches a terminal status, no new time segments can be started on it.',
              ),
              HelpBullet(
                'Marking an in-progress task as Completed or Dropped automatically stops any active running time segment.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.undo_rounded,
            title: 'Accidental Changes & Undo Action',
            children: [
              HelpBullet(
                'Whenever a task status is changed, a 5-second SnackBar appears with an Undo button.',
              ),
              HelpBullet(
                'A persistent Undo button is also available in the app bar to quickly reverse your last status transition.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.translate_rounded,
            title: 'Unicode NFC Normalization & Title Uniqueness',
            children: [
              HelpBullet(
                'All task titles are NFC-normalized before being written to the database.',
              ),
              HelpBullet(
                'No two tasks on the same day can share identical titles (ignoring case and whitespace).',
              ),
              HelpBullet(
                'Text direction (RTL/LTR) is dynamically detected per item for seamless multilingual support (English, Malayalam, Hindi, etc.).',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Tip: Use the date picker or swipe between days on the daily list to review past productivity or plan future days.',
          ),
        ],
      ),
    );
  }
}
