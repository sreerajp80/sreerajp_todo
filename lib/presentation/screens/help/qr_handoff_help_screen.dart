import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class QrHandoffHelpScreen extends StatelessWidget {
  const QrHandoffHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Air QR & Data Handoff')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'Move tasks, time tracking summaries, and flashcards across devices without Wi-Fi, cables, or internet. '
            'Air QR uses high-density animated visual QR codes to beam data directly into the camera of another device.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Air QR Visual Beam',
            children: [
              HelpBullet(
                'Select tasks or decks and tap "Air QR Share" to produce a visual QR stream on screen.',
              ),
              HelpBullet(
                'On the receiving device, open "Air QR Scan" and point the camera at the sending screen.',
              ),
              HelpBullet(
                'The camera reassembles all data chunks in real time, validating checksums before applying imports.',
              ),
              HelpBullet(
                'Camera permission is requested only while scanning and no photo or video is ever saved to disk.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.send_to_mobile_rounded,
            title: 'Data Handoff (JSON & Markdown)',
            children: [
              HelpBullet(
                'Generate formatted Markdown summaries of your daily accomplishments for email or reports.',
              ),
              HelpBullet(
                'Export and import raw JSON representations of specific tasks for cross-platform backup and scripts.',
              ),
              HelpBullet(
                'Paste JSON bundles directly into the app on desktop or mobile for instant 1-tap import.',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Tip: Air QR is especially handy for moving a quick task or flashcard deck from your desktop screen to your phone in seconds.',
          ),
        ],
      ),
    );
  }
}
