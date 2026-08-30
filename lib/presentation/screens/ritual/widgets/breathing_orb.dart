import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/ritual_rules.dart';

/// The slow circle of the first ritual step.
///
/// Ported from SreerajP Journal Vault, with two changes: the phase labels come
/// from the ARB files rather than being English in the source, and the run is
/// driven by [BreathTechnique.phases] instead of a chain of switches, so a
/// rhythm with no hold simply has fewer phases in its list.
///
/// It is a plain [AnimationController] and a one-second [Timer]. No package,
/// no asset, no sound.
class BreathingOrb extends StatefulWidget {
  const BreathingOrb({
    super.key,
    required this.technique,
    required this.breaths,
    required this.haptic,
    this.onFinished,
  });

  /// The rhythm to follow.
  final BreathTechnique technique;

  /// How many whole breaths to run.
  final int breaths;

  /// When true, a short buzz marks each change of phase, so the eyes can stay
  /// closed. Uses [HapticFeedback], exactly as the focus pulse does.
  final bool haptic;

  /// Called once, when the last breath ends.
  final VoidCallback? onFinished;

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.technique.inhaleSeconds),
  );

  Timer? _tick;
  int _breath = 1;
  int _phaseIndex = 0;
  int _secondsLeft = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startPhase();
  }

  @override
  void didUpdateWidget(covariant BreathingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Changing the rhythm or the count from Settings while the step is on
    // screen starts it again rather than leaving it half in the old shape.
    if (oldWidget.technique != widget.technique ||
        oldWidget.breaths != widget.breaths) {
      _tick?.cancel();
      _controller.reset();
      _breath = 1;
      _phaseIndex = 0;
      _finished = false;
      _startPhase();
    }
  }

  List<(BreathPhase, int)> get _phases => widget.technique.phases;

  void _startPhase() {
    final (phase, seconds) = _phases[_phaseIndex];

    if (phase.isExpanding) {
      _controller.duration = Duration(seconds: seconds);
      _controller.forward(from: 0);
    } else if (phase.isContracting) {
      _controller.duration = Duration(seconds: seconds);
      _controller.reverse(from: 1);
    } else {
      // A hold: the circle stays where the last phase left it.
      _controller.value = _phases[_phaseIndex - 1].$1.isExpanding ? 1.0 : 0.0;
    }

    if (widget.haptic) unawaited(HapticFeedback.selectionClick());

    setState(() => _secondsLeft = seconds);

    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
        return;
      }
      timer.cancel();
      _advance();
    });
  }

  void _advance() {
    if (!mounted) return;

    if (_phaseIndex < _phases.length - 1) {
      _phaseIndex++;
      _startPhase();
      return;
    }

    if (_breath < widget.breaths) {
      setState(() {
        _breath++;
        _phaseIndex = 0;
      });
      _startPhase();
      return;
    }

    setState(() => _finished = true);
    if (widget.haptic) unawaited(HapticFeedback.mediumImpact());
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _phaseLabel(BreathPhase phase) => switch (phase) {
    BreathPhase.inhale => context.l10n.ritualBreathIn,
    BreathPhase.holdIn => context.l10n.ritualBreathHold,
    BreathPhase.exhale => context.l10n.ritualBreathOut,
    BreathPhase.holdOut => context.l10n.ritualBreathRest,
  };

  String _phaseHint(BreathPhase phase) => switch (phase) {
    BreathPhase.inhale => context.l10n.ritualBreathInHint,
    BreathPhase.holdIn => context.l10n.ritualBreathHoldHint,
    BreathPhase.exhale => context.l10n.ritualBreathOutHint,
    BreathPhase.holdOut => context.l10n.ritualBreathRestHint,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_finished) {
      return Semantics(
        label: l10n.ritualBreathFinished,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer.withValues(alpha: 0.5),
                border: Border.all(color: colors.primary, width: 2),
              ),
              child: Icon(Icons.check_rounded, size: 56, color: colors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.ritualBreathFinished,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      );
    }

    final (phase, _) = _phases[_phaseIndex];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // The circle never shrinks to nothing: 0.7 to 1.0 reads as breathing,
        // while 0 to 1 reads as a loading spinner.
        final scale = 0.7 + (_controller.value * 0.3);

        return Semantics(
          label: '${_phaseLabel(phase)}, $_secondsLeft',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.ritualBreathProgress(_breath, widget.breaths),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.outline,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220 * scale,
                      height: 220 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(alpha: 0.08 * scale),
                      ),
                    ),
                    Container(
                      width: 180 * scale,
                      height: 180 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primaryContainer.withValues(
                          alpha: 0.35 * scale,
                        ),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceContainerHighest,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _phaseLabel(phase),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_secondsLeft',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _phaseHint(phase),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
