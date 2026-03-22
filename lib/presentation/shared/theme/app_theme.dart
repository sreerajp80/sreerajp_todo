import 'package:flutter/material.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF1565C0);
  static const _lightSurface = Color(0xFFF7F9FC);
  static const _darkSurface = Color(0xFF0F1722);
  static const _lightOutline = Color(0xFFB8C3D1);
  static const _darkOutline = Color(0xFF415062);

  static final light = _buildTheme(Brightness.light);
  static final dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      surface: isDark ? _darkSurface : _lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        outline: isDark ? _darkOutline : _lightOutline,
        outlineVariant: (isDark ? _darkOutline : _lightOutline).withValues(
          alpha: 0.45,
        ),
      ),
      scaffoldBackgroundColor: scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        backgroundColor: Color(0xFF1D2939),
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: Color(0xFFFFD54F),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF17212B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant;
          return TextStyle(fontWeight: FontWeight.w600, color: color);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        minVerticalPadding: 8,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
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
        isDark ? const Color(0xFFBDBDBD) : const Color(0xFF757575),
      TodoStatus.completed =>
        isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
      TodoStatus.dropped =>
        isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
      TodoStatus.ported =>
        isDark ? const Color(0xFFFFCA28) : const Color(0xFFFF8F00),
    };
  }
}
