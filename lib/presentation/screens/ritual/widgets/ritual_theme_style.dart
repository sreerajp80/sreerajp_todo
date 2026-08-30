import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/domain/entities/ritual_card.dart';

/// How each deck theme is drawn and named.
///
/// The icon and colour live here rather than on [RitualTheme] because the
/// domain layer is kept clear of Flutter types. The name comes from the ARB
/// files, like every other user-visible string.
extension RitualThemeStyle on RitualTheme {
  /// A small icon shown beside the theme name.
  IconData get icon => switch (this) {
    RitualTheme.dharma => Icons.balance_rounded,
    RitualTheme.karma => Icons.autorenew_rounded,
    RitualTheme.bhakti => Icons.favorite_outline_rounded,
    RitualTheme.jnana => Icons.auto_stories_outlined,
    RitualTheme.yoga => Icons.self_improvement_rounded,
    RitualTheme.ahimsa => Icons.spa_outlined,
    RitualTheme.sathya => Icons.lightbulb_outline_rounded,
    RitualTheme.vairagya => Icons.eco_outlined,
    RitualTheme.seva => Icons.volunteer_activism_outlined,
    RitualTheme.shanti => Icons.water_drop_outlined,
  };

  /// The theme's own accent, used only as a light tint behind its icon.
  ///
  /// These are fixed colours rather than colour-scheme roles: the ten themes
  /// have to stay apart from each other whatever accent the user has chosen,
  /// and a tint at low opacity reads the same in both light and dark.
  Color get accent => switch (this) {
    RitualTheme.dharma => const Color(0xFFF59E0B),
    RitualTheme.karma => const Color(0xFFEF4444),
    RitualTheme.bhakti => const Color(0xFFEC4899),
    RitualTheme.jnana => const Color(0xFF3B82F6),
    RitualTheme.yoga => const Color(0xFF06B6D4),
    RitualTheme.ahimsa => const Color(0xFF10B981),
    RitualTheme.sathya => const Color(0xFFD97706),
    RitualTheme.vairagya => const Color(0xFF8B5CF6),
    RitualTheme.seva => const Color(0xFF14B8A6),
    RitualTheme.shanti => const Color(0xFF6366F1),
  };

  /// The theme's name in the app's current language.
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RitualTheme.dharma => l10n.ritualThemeDharma,
      RitualTheme.karma => l10n.ritualThemeKarma,
      RitualTheme.bhakti => l10n.ritualThemeBhakti,
      RitualTheme.jnana => l10n.ritualThemeJnana,
      RitualTheme.yoga => l10n.ritualThemeYoga,
      RitualTheme.ahimsa => l10n.ritualThemeAhimsa,
      RitualTheme.sathya => l10n.ritualThemeSathya,
      RitualTheme.vairagya => l10n.ritualThemeVairagya,
      RitualTheme.seva => l10n.ritualThemeSeva,
      RitualTheme.shanti => l10n.ritualThemeShanti,
    };
  }
}
