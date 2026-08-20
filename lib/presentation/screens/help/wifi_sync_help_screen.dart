import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class WifiSyncHelpScreen extends StatelessWidget {
  const WifiSyncHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Wi-Fi P2P Device Sync')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'Transfer and synchronize your tasks, time records, and mastery flashcards directly between two devices '
            'on the same local Wi-Fi network — with zero cloud servers and zero internet traffic.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.wifi_tethering_rounded,
            title: 'How Local Wi-Fi Sync Works',
            children: [
              HelpBullet(
                'Both devices must be connected to the same local Wi-Fi network (or one device connected to the other’s hotspot).',
              ),
              HelpBullet(
                'One device acts as the Sender/Host (generating a temporary pairing code / QR code), and the other acts as the Receiver.',
              ),
              HelpBullet(
                'Data is transferred directly socket-to-socket over your local LAN, completely bypassing external servers or the internet.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.lock_outline_rounded,
            title: 'End-to-End Encryption',
            children: [
              HelpBullet(
                'Local sync connections negotiate an encrypted channel using one-time pairing credentials.',
              ),
              HelpBullet(
                'Other devices on the same Wi-Fi network cannot inspect or tamper with the transferred payload.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.merge_type_rounded,
            title: 'Sync Modes & Conflicts',
            children: [
              HelpBullet(
                'Two-Way Smart Merge: Combines tasks and segments from both devices without losing existing records.',
              ),
              HelpBullet(
                'Replace All: Replaces the target device’s data completely with an exact clone of the source device (after confirmation).',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Tip: If your Wi-Fi router blocks client-to-client traffic (client isolation), simply turn on a mobile hotspot on one phone and connect the other phone to it.',
          ),
        ],
      ),
    );
  }
}
