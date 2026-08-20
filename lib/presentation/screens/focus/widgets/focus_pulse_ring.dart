import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The slow ambient ring behind the elapsed time in the Focus view.
///
/// It does two jobs at once:
///  * it breathes, so a glance tells the user the timer is alive;
///  * when the task has a target, the ring fills up to show how much of that
///    target is done.
///
/// With no target the ring draws a soft, always-moving arc instead, so the
/// screen never looks frozen.
class FocusPulseRing extends StatefulWidget {
  const FocusPulseRing({
    super.key,
    required this.child,
    this.progress,
    this.isRunning = true,
    this.size = 260,
  });

  /// What sits inside the ring, normally the elapsed time.
  final Widget child;

  /// How much of the target is done, from 0 to 1. Null when the task has no
  /// target.
  final double? progress;

  /// A stopped timer holds still, so a paused task looks paused.
  final bool isRunning;

  /// The width and height of the ring in logical pixels (dp).
  final double size;

  @override
  State<FocusPulseRing> createState() => _FocusPulseRingState();
}

class _FocusPulseRingState extends State<FocusPulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isRunning) _controller.repeat();
  }

  @override
  void didUpdateWidget(FocusPulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRunning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _FocusRingPainter(
              phase: _controller.value,
              progress: widget.progress,
              color: colorScheme.primary,
              trackColor: colorScheme.outlineVariant,
            ),
            child: Center(child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({
    required this.phase,
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  /// Where the breathing cycle is, from 0 to 1.
  final double phase;

  final double? progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // A full sine cycle over the whole phase, so the ring fades in and out
    // smoothly and never jumps when the cycle starts again.
    final breath = (math.sin(phase * 2 * math.pi) + 1) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = trackColor.withValues(alpha: 0.35);
    canvas.drawCircle(centre, radius, track);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = color.withValues(alpha: 0.05 + breath * 0.10);
    canvas.drawCircle(centre, radius, glow);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.85);

    const start = -math.pi / 2;
    final done = progress;
    if (done != null) {
      // Show the target progress, and never draw more than a full circle.
      final sweep = done.clamp(0.0, 1.0) * 2 * math.pi;
      if (sweep > 0) canvas.drawArc(rect, start, sweep, false, arc);
    } else {
      // No target: a short arc walks around the ring instead.
      canvas.drawArc(
        rect,
        start + phase * 2 * math.pi,
        math.pi / 3,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
