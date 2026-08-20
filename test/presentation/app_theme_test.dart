import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

/// Contrast ratio between two opaque colours, as defined by WCAG.
double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

double _lightness(Color color) => HSLColor.fromColor(color).lightness;

void main() {
  group('AppTheme', () {
    test('uses the built-in page background in both modes', () {
      expect(AppTheme.light().scaffoldBackgroundColor, const Color(0xFFF0F4FB));
      expect(AppTheme.dark().scaffoldBackgroundColor, const Color(0xFF0E1724));
    });

    test('cards stay visibly apart from the page background', () {
      final light = AppTheme.light();
      expect(
        light.cardTheme.color!.toARGB32(),
        isNot(light.scaffoldBackgroundColor.toARGB32()),
        reason: 'light card must differ from the background',
      );

      final dark = AppTheme.dark();
      expect(
        _lightness(dark.cardTheme.color!),
        greaterThan(_lightness(dark.scaffoldBackgroundColor)),
        reason: 'dark card must be lighter than the background',
      );
    });

    test('body text keeps a readable contrast on cards', () {
      for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
        expect(
          _contrast(theme.colorScheme.onSurface, theme.cardTheme.color!),
          greaterThan(4.5),
        );
      }
    });

    test('a picked accent becomes the primary colour', () {
      const accent = Color(0xFF0D9488);

      expect(AppTheme.light(accent: accent).colorScheme.primary, accent);
      expect(AppTheme.dark(accent: accent).colorScheme.primary, accent);
    });

    test('falls back to the default accent when none is picked', () {
      expect(AppTheme.light().colorScheme.primary, AppTheme.defaultLightAccent);
      expect(AppTheme.dark().colorScheme.primary, AppTheme.defaultDarkAccent);
    });
  });
}
