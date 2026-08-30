import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/widgets/breathing_orb.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/widgets/ritual_card_step.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/widgets/ritual_settle_step.dart';

/// Which part of the ritual is on screen.
enum RitualStep { breathe, reflect, settle, begin }

/// Ritual mode: the guided day open.
///
/// Breathe, read one card, settle the day, then begin. The middle two steps
/// can be switched off in Settings, and every step can be skipped, so the flow
/// is built from whatever is turned on rather than being a fixed four.
///
/// The ritual always runs for today. There is no date to pass in: a guided
/// start to a day that has already gone would be a strange thing to offer, and
/// past days are read-only anyway.
class RitualScreen extends ConsumerStatefulWidget {
  const RitualScreen({super.key});

  @override
  ConsumerState<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends ConsumerState<RitualScreen> {
  final String _date = todayAsIso();

  late List<RitualStep> _steps;
  int _index = 0;
  bool _breathDone = false;
  int _carried = 0;
  int _focused = 0;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(ritualProvider);
    _steps = [
      RitualStep.breathe,
      if (settings.cardStep) RitualStep.reflect,
      if (settings.settleStep) RitualStep.settle,
      RitualStep.begin,
    ];
  }

  void _next() {
    if (_index >= _steps.length - 1) {
      _finish();
      return;
    }
    setState(() => _index++);
  }

  /// Leaves the ritual for today's list.
  ///
  /// The day is marked as run whether the ritual was finished or skipped:
  /// being asked twice in one day is exactly what someone who skipped it does
  /// not want.
  Future<void> _finish() async {
    await ref.read(ritualProvider.notifier).markRun(_date);
    if (!mounted) return;
    context.go(AppRoutes.dailyListPath(_date));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final step = _steps[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ritualTitle),
        automaticallyImplyLeading: false,
        actions: [TextButton(onPressed: _finish, child: Text(l10n.ritualSkip))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(steps: _steps, current: _index),
            const Divider(height: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(step),
                  child: switch (step) {
                    RitualStep.breathe => _buildBreathe(theme),
                    RitualStep.reflect => RitualCardStep(
                      date: _date,
                      onDone: _next,
                    ),
                    RitualStep.settle => RitualSettleStep(
                      date: _date,
                      onCarried: (count) => _carried += count,
                      onFocusChanged: (count) => _focused = count,
                      onDone: _next,
                    ),
                    RitualStep.begin => _buildBegin(theme),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathe(ThemeData theme) {
    final settings = ref.watch(ritualProvider);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BreathingOrb(
                  technique: settings.technique,
                  breaths: settings.breathCount,
                  haptic: settings.haptic,
                  onFinished: () {
                    if (mounted) setState(() => _breathDone = true);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Enabled from the start, on purpose. A step that holds someone
          // against their will is not a calm way to open the day.
          FilledButton(
            onPressed: _next,
            child: Text(_breathDone ? l10n.ritualContinue : l10n.ritualSkip),
          ),
        ],
      ),
    );
  }

  Widget _buildBegin(ThemeData theme) {
    final l10n = context.l10n;
    final lines = [
      if (_carried > 0) l10n.ritualBeginCarried(_carried),
      if (_focused > 0) l10n.ritualBeginFocused(_focused),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(l10n.ritualBeginTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (lines.isEmpty)
            Text(
              l10n.ritualBeginNothing,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          else
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(line, style: theme.textTheme.bodyLarge),
              ),
          const Spacer(),
          FilledButton(onPressed: _finish, child: Text(l10n.ritualBeginAction)),
        ],
      ),
    );
  }
}

/// The row of step names across the top, with the finished ones ticked.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.current});

  final List<RitualStep> steps;
  final int current;

  String _label(BuildContext context, RitualStep step) {
    final l10n = context.l10n;
    return switch (step) {
      RitualStep.breathe => l10n.ritualStepBreathe,
      RitualStep.reflect => l10n.ritualStepReflect,
      RitualStep.settle => l10n.ritualStepSettle,
      RitualStep.begin => l10n.ritualStepBegin,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: i <= current ? colors.primary : colors.outlineVariant,
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  i < current
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 16,
                  color: i <= current ? colors.primary : colors.outlineVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _label(context, steps[i]),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: i == current ? colors.primary : colors.outline,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
