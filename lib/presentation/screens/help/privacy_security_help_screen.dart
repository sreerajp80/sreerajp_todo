import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class PrivacySecurityHelpScreen extends StatelessWidget {
  const PrivacySecurityHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security, App Lock & Encryption')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: const [
            HelpIntro(
              'SreerajP ToDo is built from the ground up with a privacy-first, zero-trust offline architecture. '
              'Your personal productivity data is strongly encrypted and protected by multiple layers of security.',
            ),
            SizedBox(height: 24),
            HelpSection(
              icon: Icons.key_rounded,
              title: 'SQLCipher AES-256 Database Encryption',
              children: [
                HelpBullet(
                  'The live SQLite database is fully encrypted with 256-bit AES cipher (SQLCipher).',
                ),
                HelpBullet(
                  'The database master encryption key is derived securely and stored in device-protected hardware storage (Android Keystore / OS keychain).',
                ),
                HelpBullet(
                  'Even if someone copies the raw database file from your device storage, it cannot be read without the key.',
                ),
              ],
            ),
            HelpSection(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric & App PIN Lock',
              children: [
                HelpBullet(
                  'Protect access to the app using your device’s fingerprint, face unlock, or a custom App PIN.',
                ),
                HelpBullet(
                  'Configure auto-lock timers (Immediately, 1 minute, 5 minutes) to secure the app when switching away.',
                ),
              ],
            ),
            HelpSection(
              icon: Icons.screenshot_outlined,
              title: 'Screenshot Guard Defense',
              children: [
                HelpBullet(
                  'Under Settings → Security, enable Screenshot Guard to block screenshots and screen recordings.',
                ),
                HelpBullet(
                  'Screenshot Guard also hides the app screen preview in Android’s Recent Apps switcher for complete visual privacy.',
                ),
              ],
            ),
            HelpSection(
              icon: Icons.cloud_off_rounded,
              title: 'Zero Network Guarantee',
              children: [
                HelpBullet(
                  'The app does not declare the INTERNET permission in AndroidManifest.xml.',
                ),
                HelpBullet(
                  'Zero telemetry, zero third-party cloud SDKs, zero crash tracking, and zero advertising.',
                ),
              ],
            ),
            SizedBox(height: 8),
            HelpFooter(
              'Tip: Keep your device lock (fingerprint/PIN) active on your phone for maximum hardware-backed cryptographic protection.',
            ),
          ],
        ),
      ),
    );
  }
}
