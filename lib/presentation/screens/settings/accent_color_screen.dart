import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_section_card.dart';

/// Accent colour picker with presets, a colour wheel and a live preview.
///
/// The colour is stored separately for light mode and dark mode, so the page
/// always edits the accent of the theme that is showing right now.
class AccentColorScreen extends ConsumerStatefulWidget {
  const AccentColorScreen({super.key});

  @override
  ConsumerState<AccentColorScreen> createState() => _AccentColorScreenState();
}

class _AccentColorScreenState extends ConsumerState<AccentColorScreen> {
  HSVColor? _hsv;
  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (brightness == _lastBrightness) return;
    _lastBrightness = brightness;
    _hsv = HSVColor.fromColor(_currentAccent(brightness));
  }

  Color _currentAccent(Brightness brightness) {
    final appearance = ref.read(appearanceProvider);
    return appearance.accentFor(brightness) ?? _defaultAccent(brightness);
  }

  Color _defaultAccent(Brightness brightness) => brightness == Brightness.dark
      ? AppTheme.defaultDarkAccent
      : AppTheme.defaultLightAccent;

  void _apply(HSVColor hsv) {
    setState(() => _hsv = hsv);
    ref
        .read(appearanceProvider.notifier)
        .setAccentFor(Theme.of(context).brightness, hsv.toColor());
  }

  void _reset() {
    final brightness = Theme.of(context).brightness;
    ref.read(appearanceProvider.notifier).resetAccentFor(brightness);
    setState(() => _hsv = HSVColor.fromColor(_defaultAccent(brightness)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hsv = _hsv ?? HSVColor.fromColor(_defaultAccent(theme.brightness));
    final selected = hsv.toColor();
    final onAccent = AppTheme.contrastOn(selected);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceAccentColor)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            title: l10n.accentLivePreview,
            subtitle: isDark
                ? l10n.accentAppliesToDark
                : l10n.accentAppliesToLight,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: selected.withValues(alpha: 0.42),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.palette_outlined, color: onAccent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.accentSampleText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: onAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: l10n.accentPresets,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final color in AppTheme.presetAccents)
                  _PresetSwatch(
                    color: color,
                    selected: color.toARGB32() == selected.toARGB32(),
                    onTap: () => _apply(HSVColor.fromColor(color)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: l10n.accentCustomWheel,
            child: Column(
              children: [
                Center(
                  child: _HueWheel(
                    size: 248,
                    hsv: hsv,
                    onChanged: (hue, saturation) =>
                        _apply(hsv.withHue(hue).withSaturation(saturation)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.brightness_6_outlined, size: 20),
                    Expanded(
                      child: Slider(
                        value: hsv.value,
                        onChanged: (value) =>
                            _apply(hsv.withValue(value.clamp(0.05, 1.0))),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(
                      isDark ? l10n.accentResetDark : l10n.accentResetLight,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.accentContrastNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One round preset colour button.
class _PresetSwatch extends StatelessWidget {
  const _PresetSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: selected
            ? Icon(Icons.check, color: AppTheme.contrastOn(color), size: 22)
            : null,
      ),
    );
  }
}

/// Hue and saturation wheel. The angle picks the hue, the distance from the
/// centre picks the saturation.
class _HueWheel extends StatelessWidget {
  const _HueWheel({
    required this.size,
    required this.hsv,
    required this.onChanged,
  });

  final double size;
  final HSVColor hsv;
  final void Function(double hue, double saturation) onChanged;

  void _handle(Offset local) {
    final radius = size / 2;
    final centre = Offset(radius, radius);
    final vector = local - centre;
    final saturation = (vector.distance / radius).clamp(0.0, 1.0);
    var degrees = vector.direction * 180 / math.pi;
    if (degrees < 0) degrees += 360;
    onChanged(degrees, saturation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _handle(details.localPosition),
      onPanUpdate: (details) => _handle(details.localPosition),
      child: CustomPaint(size: Size.square(size), painter: _WheelPainter(hsv)),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final centre = Offset(radius, radius);

    final hueColors = <Color>[
      for (var i = 0; i <= 360; i += 30)
        HSVColor.fromAHSV(1, i % 360.0, 1, 1).toColor(),
    ];
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: hueColors,
      ).createShader(Rect.fromCircle(center: centre, radius: radius));
    canvas.drawCircle(centre, radius, sweep);

    final saturationPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: centre, radius: radius));
    canvas.drawCircle(centre, radius, saturationPaint);

    if (hsv.value < 1) {
      final dim = Paint()
        ..color = Colors.black.withValues(alpha: 1 - hsv.value);
      canvas.drawCircle(centre, radius, dim);
    }

    final angle = hsv.hue * math.pi / 180;
    final distance = hsv.saturation * radius;
    final thumb =
        centre + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
    canvas.drawCircle(
      thumb,
      11,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(thumb, 8, Paint()..color = hsv.toColor());
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => oldDelegate.hsv != hsv;
}
