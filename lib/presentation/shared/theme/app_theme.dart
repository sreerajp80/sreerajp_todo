import 'package:flutter/material.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF3B66B0);
  static const _lightBackground = Color(0xFFF0F4FB);
  static const _lightSurface = Color(0xFFFBFCFF);
  static const _darkBackground = Color(0xFF0E1724);
  static const _darkSurface = Color(0xFF152233);
  static const _lightOutline = Color(0xFFB6C3D6);
  static const _darkOutline = Color(0xFF465A74);

  /// The default accent colour of the light theme.
  static const Color defaultLightAccent = Color(0xFF355FA8);

  /// The default accent colour of the dark theme.
  static const Color defaultDarkAccent = Color(0xFF9BBAFF);

  /// Quick-pick accent colours offered on the Accent Color screen.
  static const List<Color> presetAccents = <Color>[
    Color(0xFF355FA8), // app blue
    Color(0xFF0D9488), // teal
    Color(0xFF3B82F6), // bright blue
    Color(0xFF7C8AFF), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFFF97316), // orange
    Color(0xFF10B981), // green
  ];

  /// Black or white, whichever reads better on top of [background].
  static Color contrastOn(Color background) {
    final lum = background.computeLuminance();
    final contrastWithBlack = (lum + 0.05) / 0.05;
    final contrastWithWhite = 1.05 / (lum + 0.05);
    return contrastWithBlack >= contrastWithWhite ? Colors.black : Colors.white;
  }

  /// The light theme, optionally re-tinted with [accent] (the highlight
  /// colour), using [fontFamily].
  static ThemeData light({Color? accent, String? fontFamily}) =>
      _buildTheme(Brightness.light, accent: accent, fontFamily: fontFamily);

  /// The dark theme, optionally re-tinted with [accent] (the highlight
  /// colour), using [fontFamily].
  static ThemeData dark({Color? accent, String? fontFamily}) =>
      _buildTheme(Brightness.dark, accent: accent, fontFamily: fontFamily);

  /// Returns [color] with its lightness moved to [lightness] (0..1).
  static Color _withLightness(Color color, double lightness) =>
      HSLColor.fromColor(
        color,
      ).withLightness(lightness.clamp(0.0, 1.0)).toColor();

  static ThemeData _buildTheme(
    Brightness brightness, {
    Color? accent,
    String? fontFamily,
  }) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? _darkBackground : _lightBackground;
    final surfaceColor = isDark ? _darkSurface : _lightSurface;
    final cardColor = isDark
        ? const Color(0xFF1F3355)
        : Colors.white.withValues(alpha: 0.94);
    final outlineColor = isDark ? _darkOutline : _lightOutline;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: accent ?? _seedColor,
      brightness: brightness,
    );
    final primary = accent ?? (isDark ? defaultDarkAccent : defaultLightAccent);
    final usesCustomAccent = accent != null;
    final scheme = baseScheme.copyWith(
      primary: primary,
      onPrimary: contrastOn(primary),
      primaryContainer: usesCustomAccent
          ? _withLightness(primary, isDark ? 0.22 : 0.88)
          : (isDark ? const Color(0xFF243A5B) : const Color(0xFFD9E5FF)),
      onPrimaryContainer: usesCustomAccent
          ? _withLightness(primary, isDark ? 0.92 : 0.20)
          : (isDark ? const Color(0xFFE1E9FF) : const Color(0xFF18315C)),
      secondary: usesCustomAccent
          ? _withLightness(primary, isDark ? 0.78 : 0.44)
          : (isDark ? const Color(0xFFB9C9E9) : const Color(0xFF516B95)),
      secondaryContainer: usesCustomAccent
          ? _withLightness(primary, isDark ? 0.18 : 0.92)
          : (isDark ? const Color(0xFF203047) : const Color(0xFFE3EBF9)),
      onSecondaryContainer: usesCustomAccent
          ? _withLightness(primary, isDark ? 0.90 : 0.24)
          : (isDark ? const Color(0xFFE0EBFF) : const Color(0xFF25344C)),
      surface: surfaceColor,
      outline: outlineColor,
      outlineVariant: outlineColor.withValues(alpha: isDark ? 0.56 : 0.42),
      shadow: Colors.black.withValues(alpha: isDark ? 0.42 : 0.12),
    );
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseTheme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.3),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.35),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      canvasColor: scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.96),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shadowColor: scheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: isDark
              ? const BorderSide(color: Color(0xFF3A5472), width: 1)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
          fontSize: 18,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        actionOverflowThreshold: 1.0,
        showCloseIcon: true,
        backgroundColor: Color(0xFF1D2939),
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: Color(0xFFFFD54F),
        closeIconColor: Colors.white70,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: buttonPadding,
          elevation: 4,
          shadowColor: scheme.primary.withValues(alpha: 0.28),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: isDark ? 0.08 : 0.98),
          foregroundColor: scheme.onSurface,
          padding: buttonPadding,
          elevation: 4,
          shadowColor: scheme.shadow,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          padding: buttonPadding,
          elevation: 1,
          shadowColor: scheme.shadow,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return Colors.white.withValues(alpha: isDark ? 0.04 : 0.82);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurfaceVariant;
          }),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        height: 78,
        elevation: 12,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant;
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            overflow: TextOverflow.ellipsis,
            height: 1.15,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        highlightElevation: 10,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: BorderRadius.circular(999),
        ),
        dividerColor: scheme.outlineVariant,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        minVerticalPadding: 8,
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: Colors.white.withValues(alpha: isDark ? 0.06 : 0.84),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return isDark ? const Color(0xFFB6C4D7) : const Color(0xFFDEE6F3);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.outlineVariant;
        }),
      ),
    );
  }

  static Color statusColor(ThemeData theme, TodoStatus status) {
    return statusColorForBrightness(theme.brightness, status);
  }

  static Color statusColorForBrightness(
    Brightness brightness,
    TodoStatus status,
  ) {
    final isDark = brightness == Brightness.dark;
    return switch (status) {
      TodoStatus.pending =>
        isDark ? const Color(0xFFD4D8E0) : const Color(0xFF687181),
      TodoStatus.working =>
        isDark ? const Color(0xFF7CC7FF) : const Color(0xFF2478C8),
      TodoStatus.completed =>
        isDark ? const Color(0xFF73D18A) : const Color(0xFF2E7D46),
      TodoStatus.dropped =>
        isDark ? const Color(0xFFFF8A84) : const Color(0xFFD64545),
      TodoStatus.ported =>
        isDark ? const Color(0xFFFFC66C) : const Color(0xFFE88B1E),
    };
  }
}
