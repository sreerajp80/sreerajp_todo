import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/task_default_rules.dart';

/// Two small number boxes for the target time of a task.
///
/// Hours and minutes rather than a clock picker, because a target is a length
/// and not a time of day. Both at zero means "no target", which is how null is
/// entered and cleared.
class TargetTimeField extends StatefulWidget {
  const TargetTimeField({
    super.key,
    required this.targetSeconds,
    required this.onChanged,
    this.enabled = true,
  });

  /// The current target, or null when there is none.
  final int? targetSeconds;

  /// Called with the new target, or null when both boxes reach zero.
  final ValueChanged<int?> onChanged;

  /// False on a day-locked task, where the boxes are shown but read-only.
  final bool enabled;

  @override
  State<TargetTimeField> createState() => _TargetTimeFieldState();
}

class _TargetTimeFieldState extends State<TargetTimeField> {
  late final TextEditingController _hours;
  late final TextEditingController _minutes;

  @override
  void initState() {
    super.initState();
    final split = splitTargetSeconds(widget.targetSeconds);
    _hours = TextEditingController(text: split.hours.toString());
    _minutes = TextEditingController(text: split.minutes.toString());
  }

  @override
  void didUpdateWidget(TargetTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only follow the parent when the value really changed elsewhere, so
    // typing is never interrupted by a rebuild.
    if (widget.targetSeconds == oldWidget.targetSeconds) return;
    final split = splitTargetSeconds(widget.targetSeconds);
    if (_read(_hours) != split.hours) {
      _hours.text = split.hours.toString();
    }
    if (_read(_minutes) != split.minutes) {
      _minutes.text = split.minutes.toString();
    }
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  static int _read(TextEditingController controller) =>
      int.tryParse(controller.text.trim()) ?? 0;

  void _emit() {
    // Minutes are allowed past 59 so "90" can simply be typed; it is folded
    // into hours the next time the field is rebuilt from its value.
    widget.onChanged(
      joinTargetSeconds(hours: _read(_hours), minutes: _read(_minutes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBox(
                context: context,
                controller: _hours,
                label: l10n.targetHoursLabel,
                suffix: 'h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBox(
                context: context,
                controller: _minutes,
                label: l10n.targetMinutesLabel,
                suffix: 'm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.targetTimeHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBox({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            suffixText: suffix,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}
