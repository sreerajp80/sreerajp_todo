import 'package:flutter/material.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';

/// One feature item displayed on the Features screen.
class _AppFeature {
  _AppFeature({
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
  _FeatureCategory({
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

  /// Builds the feature list in the current UI language.
  static List<_FeatureCategory> _categories(AppLocalizations l10n) => [
    _FeatureCategory(
      name: l10n.featDailyName,
      subtitle: l10n.featDailySubtitle,
      icon: Icons.checklist_rounded,
      features: [
        _AppFeature(
          title: l10n.featUnicodeTitle,
          description: l10n.featUnicodeDesc,
          icon: Icons.translate_rounded,
          highlights: [
            l10n.featUnicodeH1,
            l10n.featUnicodeH2,
            l10n.featUnicodeH3,
          ],
        ),
        _AppFeature(
          title: l10n.featDayLockTitle,
          description: l10n.featDayLockDesc,
          icon: Icons.lock_clock_outlined,
          highlights: [
            l10n.featDayLockH1,
            l10n.featDayLockH2,
            l10n.featDayLockH3,
          ],
        ),
        _AppFeature(
          title: l10n.featCalendarTitle,
          description: l10n.featCalendarDesc,
          icon: Icons.calendar_month_outlined,
          highlights: [
            l10n.featCalendarH1,
            l10n.featCalendarH2,
            l10n.featCalendarH3,
          ],
        ),
        _AppFeature(
          title: l10n.featUndoTitle,
          description: l10n.featUndoDesc,
          icon: Icons.undo_rounded,
          highlights: [l10n.featUndoH1, l10n.featUndoH2, l10n.featUndoH3],
        ),
        _AppFeature(
          title: l10n.featSearchTitle,
          description: l10n.featSearchDesc,
          icon: Icons.search_rounded,
          highlights: [l10n.featSearchH1, l10n.featSearchH2, l10n.featSearchH3],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.helpHomeTimeSection,
      subtitle: l10n.featTimeSubtitle,
      icon: Icons.timer_outlined,
      features: [
        _AppFeature(
          title: l10n.featSegmentsTitle,
          description: l10n.featSegmentsDesc,
          icon: Icons.more_time_rounded,
          highlights: [
            l10n.featSegmentsH1,
            l10n.featSegmentsH2,
            l10n.featSegmentsH3,
          ],
        ),
        _AppFeature(
          title: l10n.helpTimeTrackingSingleTitle,
          description: l10n.featSingleDesc,
          icon: Icons.play_circle_outline_rounded,
          highlights: [l10n.featSingleH1, l10n.featSingleH2, l10n.featSingleH3],
        ),
        _AppFeature(
          title: l10n.helpFocusTitle,
          description: l10n.featFocusDesc,
          icon: Icons.center_focus_strong_rounded,
          highlights: [
            l10n.featFocusH1,
            l10n.featFocusH2,
            l10n.featCustomIntervals,
          ],
        ),
        _AppFeature(
          title: l10n.featStreamTitle,
          description: l10n.featStreamDesc,
          icon: Icons.bolt_rounded,
          highlights: [l10n.featStreamH1, l10n.featStreamH2, l10n.featStreamH3],
        ),
        _AppFeature(
          title: l10n.featTerminalTitle,
          description: l10n.featTerminalDesc,
          icon: Icons.task_alt_rounded,
          highlights: [
            l10n.featTerminalH1,
            l10n.featTerminalH2,
            l10n.featTerminalH3,
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featRitualName,
      subtitle: l10n.featRitualSubtitle,
      icon: Icons.self_improvement_rounded,
      features: [
        _AppFeature(
          title: l10n.featDayOpenTitle,
          description: l10n.featDayOpenDesc,
          icon: Icons.wb_sunny_outlined,
          highlights: [
            l10n.featDayOpenH1,
            l10n.featDayOpenH2,
            l10n.featDayOpenH3,
          ],
        ),
        _AppFeature(
          title: l10n.featRitualDeckTitle,
          description: l10n.featRitualDeckDesc,
          icon: Icons.style_outlined,
          highlights: [
            l10n.featRitualDeckH1,
            l10n.featRitualDeckH2,
            l10n.featRitualDeckH3,
          ],
        ),
        _AppFeature(
          title: l10n.featEveningTitle,
          description: l10n.featEveningDesc,
          icon: Icons.nightlight_outlined,
          highlights: [
            l10n.featEveningH1,
            l10n.featEveningH2,
            l10n.featEveningH3,
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.helpHomeMasterySection,
      subtitle: l10n.featMasterySubtitle,
      icon: Icons.school_outlined,
      features: [
        _AppFeature(
          title: l10n.featSrsTitle,
          description: l10n.featSrsDesc,
          icon: Icons.psychology_outlined,
          highlights: [l10n.featSrsH1, l10n.featSrsH2, l10n.featSrsH3],
        ),
        _AppFeature(
          title: l10n.featDecksTitle,
          description: l10n.featDecksDesc,
          icon: Icons.style_outlined,
          highlights: [l10n.featDecksH1, l10n.featDecksH2, l10n.featDecksH3],
        ),
        _AppFeature(
          title: l10n.featRruleTitle,
          description: l10n.featRruleDesc,
          icon: Icons.repeat_rounded,
          highlights: [
            l10n.featRruleH1,
            l10n.featCustomIntervals,
            l10n.featRruleH3,
          ],
        ),
        _AppFeature(
          title: l10n.featCopyTitle,
          description: l10n.featCopyDesc,
          icon: Icons.copy_all_rounded,
          highlights: [l10n.featCopyH1, l10n.featCopyH2, l10n.featCopyH3],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featSyncName,
      subtitle: l10n.featSyncSubtitle,
      icon: Icons.sync_alt_rounded,
      features: [
        _AppFeature(
          title: l10n.featWifiTitle,
          description: l10n.featWifiDesc,
          icon: Icons.wifi_tethering_rounded,
          highlights: [l10n.featWifiH1, l10n.featWifiH2, l10n.featWifiH3],
        ),
        _AppFeature(
          title: l10n.featQrTitle,
          description: l10n.featQrDesc,
          icon: Icons.qr_code_scanner_rounded,
          highlights: [l10n.featQrH1, l10n.featQrH2, l10n.featQrH3],
        ),
        _AppFeature(
          title: l10n.featHandoffTitle,
          description: l10n.featHandoffDesc,
          icon: Icons.send_to_mobile_rounded,
          highlights: [
            l10n.featHandoffH1,
            l10n.featHandoffH2,
            l10n.featHandoffH3,
          ],
        ),
        _AppFeature(
          title: l10n.featOfflineTitle,
          description: l10n.featOfflineDesc,
          icon: Icons.cloud_off_rounded,
          highlights: [
            l10n.featOfflineH1,
            l10n.featOfflineH2,
            l10n.featOfflineH3,
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featPrivacyName,
      subtitle: l10n.featPrivacySubtitle,
      icon: Icons.shield_outlined,
      features: [
        _AppFeature(
          title: l10n.helpPrivacyDbTitle,
          description: l10n.featDbDesc,
          icon: Icons.key_rounded,
          highlights: [l10n.featDbH1, l10n.featDbH2, l10n.featDbH3],
        ),
        _AppFeature(
          title: l10n.helpPrivacyLockTitle,
          description: l10n.featLockDesc,
          icon: Icons.fingerprint_rounded,
          highlights: [l10n.featLockH1, l10n.featLockH2, l10n.featLockH3],
        ),
        _AppFeature(
          title: l10n.helpPrivacyShotTitle,
          description: l10n.featShotDesc,
          icon: Icons.screenshot_outlined,
          highlights: [l10n.featShotH1, l10n.featShotH2, l10n.featShotH3],
        ),
        _AppFeature(
          title: l10n.featBackupTitle,
          description: l10n.featBackupDesc,
          icon: Icons.backup_rounded,
          highlights: [l10n.featBackupH1, l10n.featBackupH2, l10n.featBackupH3],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.featCustomName,
      subtitle: l10n.featCustomSubtitle,
      icon: Icons.palette_outlined,
      features: [
        _AppFeature(
          title: l10n.featThemeTitle,
          description: l10n.featThemeDesc,
          icon: Icons.color_lens_outlined,
          highlights: [l10n.featThemeH1, l10n.featThemeH2, l10n.featThemeH3],
        ),
        _AppFeature(
          title: l10n.featTypeTitle,
          description: l10n.featTypeDesc,
          icon: Icons.text_fields_rounded,
          highlights: [l10n.featTypeH1, l10n.featTypeH2, l10n.featTypeH3],
        ),
        _AppFeature(
          title: l10n.featStatsTitle,
          description: l10n.featStatsDesc,
          icon: Icons.bar_chart_rounded,
          highlights: [l10n.featStatsH1, l10n.featStatsH2, l10n.featStatsH3],
        ),
        _AppFeature(
          title: l10n.featDefaultsTitle,
          description: l10n.featDefaultsDesc,
          icon: Icons.tune_rounded,
          highlights: [
            l10n.featDefaultsH1,
            l10n.featDefaultsH2,
            l10n.featDefaultsH3,
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsFeatures),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 20),
            for (final category in _categories(l10n)) ...[
              _buildCategoryHeader(context, category),
              const SizedBox(height: 10),
              _buildCategoryCard(context, category),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final l10n = context.l10n;
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
                    l10n.featHeaderTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.featHeaderSubtitle,
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
