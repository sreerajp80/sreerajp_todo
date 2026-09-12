import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

/// Interactive framing guide overlay rendered on top of the camera preview.
///
/// Shows a dark translucent mask with a document scan cutout, high-contrast
/// corner reticles, visual section guidance for task name and description,
/// and an animated focus reticle when the user taps to focus.
class OcrCameraOverlay extends StatelessWidget {
  const OcrCameraOverlay({super.key, required this.hintText, this.focusPoint});

  final String hintText;
  final Offset? focusPoint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    // Dynamic scan window dimensions (around 85% width, 55% height)
    final scanWidth = size.width * 0.86;
    final scanHeight = size.height * 0.48;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.44),
      width: scanWidth,
      height: scanHeight,
    );

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Darkened cutout mask
          CustomPaint(
            size: Size.infinite,
            painter: _CutoutMaskPainter(
              scanRect: scanRect,
              overlayColor: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          // Corner reticles and inner guide divisions
          Positioned.fromRect(
            rect: scanRect,
            child: _ScanFrameGuide(theme: theme),
          ),

          // Top guidance pill
          Positioned(
            top: MediaQuery.paddingOf(context).top + 60,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.document_scanner_outlined,
                      color: AppTheme.defaultLightAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        hintText,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Animated tap-to-focus ring
          if (focusPoint != null)
            Positioned(
              left: focusPoint!.dx - 32,
              top: focusPoint!.dy - 32,
              child: const _FocusRing(),
            ),
        ],
      ),
    );
  }
}

class _ScanFrameGuide extends StatelessWidget {
  const _ScanFrameGuide({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor = theme.colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Outer rounded container with subtle border
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
        ),

        // Corner brackets (TL, TR, BL, BR)
        CustomPaint(
          size: Size.infinite,
          painter: _CornerBracketsPainter(color: borderColor),
        ),

        // Interior layout hints: Task Name section and Description section
        Column(
          children: [
            // Upper box for Task Name (Line 1)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '1. Task Name',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Subtle separator line hint
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'space / # / ---',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),

            // Lower box for Description
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '2. Description (all remaining text)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  const _CornerBracketsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    const radius = 16.0;

    // Top-Left
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      )
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(
        Offset(radius, size.height),
        radius: const Radius.circular(radius),
      )
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(
        Offset(size.width, size.height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CutoutMaskPainter extends CustomPainter {
  const _CutoutMaskPainter({
    required this.scanRect,
    required this.overlayColor,
  });

  final Rect scanRect;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)));

    final maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CutoutMaskPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect ||
      oldDelegate.overlayColor != overlayColor;
}

class _FocusRing extends StatefulWidget {
  const _FocusRing();

  @override
  State<_FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<_FocusRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.defaultLightAccent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.defaultLightAccent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
