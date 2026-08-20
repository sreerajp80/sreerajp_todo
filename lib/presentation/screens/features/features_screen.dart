import 'package:flutter/material.dart';

/// One feature item displayed on the Features screen.
class _AppFeature {
  const _AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.highlights,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> highlights;
}

/// A category grouping related features.
class _FeatureCategory {
  const _FeatureCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.features,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final List<_AppFeature> features;
}

/// Lists all features of SreerajP ToDo, grouped by category with visual cards.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  static const List<_FeatureCategory> _categories = [
    _FeatureCategory(
      name: 'Daily Tasks & Workflow',
      subtitle:
          'Fast planning, day lock protection, Unicode normalization, and undo',
      icon: Icons.checklist_rounded,
      features: [
        _AppFeature(
          title: 'Unicode First & Multi-Script Normalization',
          description:
              'NFC normalizes all task titles for exact uniqueness and detects text direction dynamically for English, Malayalam, Hindi, and more.',
          icon: Icons.translate_rounded,
          highlights: ['NFC Unicode', 'Multi-script text', 'RTL & LTR'],
        ),
        _AppFeature(
          title: 'Day Lock Safeguard',
          description:
              'Strict day-level immutability locks past days against retroactive modifications to preserve historical record integrity.',
          icon: Icons.lock_clock_outlined,
          highlights: [
            'Historical lock',
            'Immutable past',
            'Read-only records',
          ],
        ),
        _AppFeature(
          title: 'Daily List & Calendar Navigation',
          description:
              'Fast day-by-day task planning with visual calendar picker, quick-jump to Today, and date swipe navigation.',
          icon: Icons.calendar_month_outlined,
          highlights: ['Calendar picker', 'Today jump', 'Fast navigation'],
        ),
        _AppFeature(
          title: 'Instant Undo & Reversible Actions',
          description:
              '5-second undo toast with persistent app bar undo button for task completions, drops, and status updates.',
          icon: Icons.undo_rounded,
          highlights: [
            '5-second undo',
            'Persistent button',
            'Safe transitions',
          ],
        ),
        _AppFeature(
          title: 'Full-Text Search & Filters',
          description:
              'Instant search across all your tasks, descriptions, and historical logs by status, priority, and date ranges.',
          icon: Icons.search_rounded,
          highlights: ['Full-text search', 'Status filters', 'Date ranges'],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Time Tracking & Focus',
      subtitle:
          'Stopwatch timers, single running timer rule, and Pomodoro focus',
      icon: Icons.timer_outlined,
      features: [
        _AppFeature(
          title: 'Multi-Segment Time Tracking',
          description:
              'Measure exact time spent on any task across multiple sessions with live second-by-second precision and target progress.',
          icon: Icons.more_time_rounded,
          highlights: [
            'Multiple segments',
            'Stopwatch timer',
            'HH:MM:SS format',
          ],
        ),
        _AppFeature(
          title: 'Single Running Timer Rule',
          description:
              'Guarantees at most one active running timer at any given moment across the entire app to maintain tracking integrity.',
          icon: Icons.play_circle_outline_rounded,
          highlights: [
            'One active timer',
            'Auto-pause previous',
            'Accurate metrics',
          ],
        ),
        _AppFeature(
          title: 'Focus Mode & Pomodoro',
          description:
              'Distraction-free full-screen focus screen with custom work and break countdown timers.',
          icon: Icons.center_focus_strong_rounded,
          highlights: [
            'Pomodoro timer',
            'Full-screen focus',
            'Custom intervals',
          ],
        ),
        _AppFeature(
          title: 'Live Dynamic Timer Stream',
          description:
              'Second-by-second live timer updates with optimized rendering that consumes minimal battery and never lags.',
          icon: Icons.bolt_rounded,
          highlights: ['StreamProvider', 'Zero UI lag', 'Battery efficient'],
        ),
        _AppFeature(
          title: 'Terminal Status Time Lock',
          description:
              'Completed and dropped tasks automatically stop active timers and prevent new segment additions.',
          icon: Icons.task_alt_rounded,
          highlights: [
            'Auto-stop on finish',
            'Terminal lock',
            'Protected logs',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Mastery Deck & Spaced Repetition',
      subtitle: 'Flashcards, spaced repetition retention, and recurring habits',
      icon: Icons.school_outlined,
      features: [
        _AppFeature(
          title: 'Spaced Repetition Flashcards',
          description:
              'Convert daily learnings and study notes into flashcards with optimized spaced repetition review scheduling.',
          icon: Icons.psychology_outlined,
          highlights: [
            'Spaced repetition',
            'Retention intervals',
            'Confidence rating',
          ],
        ),
        _AppFeature(
          title: 'Decks & Mastery Levels',
          description:
              'Organize flashcards into custom decks and track your mastery score progression from Novice to Master.',
          icon: Icons.style_outlined,
          highlights: ['Custom decks', 'Mastery scoring', 'Streak tracking'],
        ),
        _AppFeature(
          title: 'Recurring Tasks & RRule Engine',
          description:
              'Automate daily, weekly, monthly, or interval-based task generation with the standard RFC-5545 RRule engine.',
          icon: Icons.repeat_rounded,
          highlights: [
            'RRule standard',
            'Custom intervals',
            'Automated generation',
          ],
        ),
        _AppFeature(
          title: 'Bulk Task Copying',
          description:
              'Easily copy unfinished or selected tasks from past days into today\'s list with 1 tap.',
          icon: Icons.copy_all_rounded,
          highlights: [
            '1-tap copying',
            'Select multiple',
            'Carry over unfinished',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Offline Sync & Air QR Transfer',
      subtitle: 'Local Wi-Fi P2P sync, Air QR visual beam, and data handoff',
      icon: Icons.sync_alt_rounded,
      features: [
        _AppFeature(
          title: 'Encrypted Local Wi-Fi P2P Sync',
          description:
              'Direct device-to-device synchronization over your local Wi-Fi with end-to-end encryption and zero cloud servers.',
          icon: Icons.wifi_tethering_rounded,
          highlights: [
            '100% Local Wi-Fi',
            'Zero cloud',
            'End-to-end encrypted',
          ],
        ),
        _AppFeature(
          title: 'Air QR Task Beam & Scanner',
          description:
              'Transfer individual tasks, time logs, and decks between devices via visual animated QR code streams.',
          icon: Icons.qr_code_scanner_rounded,
          highlights: [
            'Visual QR stream',
            'Camera scanner',
            'Zero network needed',
          ],
        ),
        _AppFeature(
          title: 'Offline Data Handoff',
          description:
              'Export and import formatted task bundles, JSON, and Markdown summaries via clipboard or local files.',
          icon: Icons.send_to_mobile_rounded,
          highlights: ['JSON & Markdown', 'Clipboard handoff', 'Portable data'],
        ),
        _AppFeature(
          title: '100% Offline Operational Guarantee',
          description:
              'Absolute privacy with zero network packages, zero cloud SDKs, zero analytics, and no INTERNET permission.',
          icon: Icons.cloud_off_rounded,
          highlights: [
            'Zero network',
            'Zero analytics',
            'No INTERNET permission',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Privacy, Security & Storage',
      subtitle: 'SQLCipher AES-256 database, app lock, and encrypted backups',
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: 'SQLCipher AES-256 Database Encryption',
          description:
              'All tasks, time records, and settings are encrypted at rest with hardware-backed SQLCipher encryption.',
          icon: Icons.key_rounded,
          highlights: [
            'SQLCipher AES-256',
            'Device-derived key',
            'Encrypted at rest',
          ],
        ),
        _AppFeature(
          title: 'Biometric & App PIN Lock',
          description:
              'Lock your tasks and settings with fingerprint, face unlock, or a custom app PIN.',
          icon: Icons.fingerprint_rounded,
          highlights: [
            'Fingerprint & Face unlock',
            'App PIN fallback',
            'Auto-lock timer',
          ],
        ),
        _AppFeature(
          title: 'Screenshot Guard Defense',
          description:
              'Prevents screen captures and hides app window previews in the Android recent apps switcher.',
          icon: Icons.screenshot_outlined,
          highlights: [
            'Screenshot blocking',
            'Recent apps shield',
            'Privacy protection',
          ],
        ),
        _AppFeature(
          title: 'Password-Protected Encrypted Backups',
          description:
              'Export and restore encrypted ZIP backup archives protected with AES-256 user passphrases.',
          icon: Icons.backup_rounded,
          highlights: [
            'AES-256 ZIP',
            'User passphrase',
            'Safe portable backups',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Customization & Analytics',
      subtitle: 'Themes, Malayalam typography, charts, and defaults',
      icon: Icons.palette_outlined,
      features: [
        _AppFeature(
          title: 'Light, Dark & Accent Palettes',
          description:
              'Support for light, dark, and OLED themes with 8 vibrant curated accent color presets.',
          icon: Icons.color_lens_outlined,
          highlights: [
            'Light & Dark themes',
            'Vibrant accents',
            'OLED styling',
          ],
        ),
        _AppFeature(
          title: 'Typography & Text Scaling',
          description:
              'Choose from Manjari, Anek Malayalam, Noto Sans, or system fonts with dynamic text scaling.',
          icon: Icons.text_fields_rounded,
          highlights: [
            'Malayalam fonts',
            'Dynamic scaling',
            'Readable typography',
          ],
        ),
        _AppFeature(
          title: 'Productivity Statistics & Charts',
          description:
              'Interactive charts and tables showing completion ratios, time distribution, and daily trends.',
          icon: Icons.bar_chart_rounded,
          highlights: [
            'fl_chart graphs',
            'Time distribution',
            'Completion trends',
          ],
        ),
        _AppFeature(
          title: 'Task Defaults & Time Display',
          description:
              'Configure default priorities, target durations, week start day, working days, and time formats.',
          icon: Icons.tune_rounded,
          highlights: [
            'Custom defaults',
            'Flexible formats',
            'Tailored workflow',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 20),
          for (final category in _categories) ...[
            _buildCategoryHeader(context, category),
            const SizedBox(height: 10),
            _buildCategoryCard(context, category),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.12),
              colorScheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SreerajP ToDo Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore every productivity tool, time tracker, and offline safeguard designed for you.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, _FeatureCategory category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                category.name.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            category.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _FeatureCategory category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < category.features.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            _buildFeatureTile(context, category.features[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, _AppFeature feature) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (feature.highlights.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: feature.highlights.map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          h,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
