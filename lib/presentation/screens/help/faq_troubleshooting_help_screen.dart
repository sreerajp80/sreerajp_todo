import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class FaqTroubleshootingHelpScreen extends StatelessWidget {
  const FaqTroubleshootingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs & Troubleshooting')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'Find answers to common questions about day lock, time tracking rules, offline security, '
            'and tips for getting the most out of SreerajP ToDo.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.help_outline_rounded,
            title: 'General & Workflow',
            children: [
              HelpFaqItem(
                question: 'Why can’t I edit or delete a task from yesterday?',
                answer:
                    'SreerajP ToDo enforces the Day Lock rule: past dates are permanently read-only to preserve honest, tamper-proof productivity records. To work on an unfinished past task, tap "Copy Tasks" and copy it to today.',
              ),
              HelpFaqItem(
                question: 'Why can’t I start a timer on a completed task?',
                answer:
                    'Completed and Dropped are terminal statuses. Once a task is completed, its time record is sealed. You can reopen the task (change status back to Pending or Working) if you wish to record more time.',
              ),
              HelpFaqItem(
                question: 'How do I undo an accidental status change?',
                answer:
                    'Whenever you update a status, a 5-second SnackBar appears with an "Undo" button. You can also tap the persistent Undo icon in the top app bar.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.timer_outlined,
            title: 'Time Tracking & Timers',
            children: [
              HelpFaqItem(
                question: 'Can I run timers on two tasks simultaneously?',
                answer:
                    'No. To maintain tracking integrity, the app enforces the Single Running Timer rule. Starting a timer on any task automatically pauses/stops any running timer on another task.',
              ),
              HelpFaqItem(
                question: 'What happens if I forget to stop my timer at night?',
                answer:
                    'You can enable "Auto-stop at midnight" under Settings → Time Tracking → Auto-stop so open timers are automatically closed at day’s end without overflowing into the next morning.',
              ),
              HelpFaqItem(
                question: 'Why are very short timer taps not saved?',
                answer:
                    'Under Settings → Time Tracking → Minimum length, you can discard accidental taps under 10 or 30 seconds to keep your time segments clean.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.security_rounded,
            title: 'Privacy & Offline Guarantee',
            children: [
              HelpFaqItem(
                question: 'Is any data uploaded to cloud servers or analytics?',
                answer:
                    'Zero data is uploaded. SreerajP ToDo is 100% offline. The Android manifest contains zero internet permissions. All database tables and logs reside on your device in AES-256 encrypted storage.',
              ),
              HelpFaqItem(
                question: 'What happens if I forget my backup password?',
                answer:
                    'Because backups are strongly encrypted on-device with AES-256 and there is no cloud server or master key, a lost backup password cannot be recovered. Always store your passphrase securely.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.sync_alt_rounded,
            title: 'Sync & Device Transfer',
            children: [
              HelpFaqItem(
                question: 'How do I transfer all my tasks to a new phone?',
                answer:
                    'You have two easy options: (1) Use "Local Wi-Fi P2P Sync" to transfer directly over your home Wi-Fi, or (2) Create an encrypted Backup ZIP file under Settings → Backup and restore it on the new phone.',
              ),
              HelpFaqItem(
                question:
                    'Why is Local Wi-Fi Sync not discovering the other device?',
                answer:
                    'Ensure both devices are on the exact same Wi-Fi network. If your router has "Client Isolation" turned on, enable a portable Wi-Fi hotspot on one phone and connect the other to it.',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Need further details? Explore the individual topic guides under Help & User Guides or review your permissions under Settings → Permissions.',
          ),
        ],
      ),
    );
  }
}
