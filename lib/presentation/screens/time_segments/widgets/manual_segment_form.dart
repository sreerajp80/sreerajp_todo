import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/duration_utils.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:uuid/uuid.dart';

class ManualSegmentForm extends StatefulWidget {
  const ManualSegmentForm({
    super.key,
    required this.todoId,
    required this.todoDate,
    required this.existingSegments,
  });

  final String todoId;
  final String todoDate;
  final List<TimeSegmentEntity> existingSegments;

  @override
  State<ManualSegmentForm> createState() => _ManualSegmentFormState();
}

class _ManualSegmentFormState extends State<ManualSegmentForm> {
  static const _uuid = Uuid();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _error;

  bool get _isValid => _startTime != null && _endTime != null && _error == null;

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  DateTime _timeOfDayToDateTime(TimeOfDay t) {
    final date = parseIsoDate(widget.todoDate);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  void _validate() {
    if (_startTime == null || _endTime == null) {
      setState(() => _error = null);
      return;
    }

    final startMin = _timeOfDayToMinutes(_startTime!);
    final endMin = _timeOfDayToMinutes(_endTime!);

    if (startMin >= endMin) {
      setState(() => _error = AppStrings.startBeforeEnd);
      return;
    }

    final newStart = _timeOfDayToDateTime(_startTime!);
    final newEnd = _timeOfDayToDateTime(_endTime!);

    for (final seg in widget.existingSegments) {
      if (seg.endTime == null) continue;

      final segStart = DateTime.parse(seg.startTime);
      final segEnd = DateTime.parse(seg.endTime!);

      if (newStart.isBefore(segEnd) && newEnd.isAfter(segStart)) {
        setState(() => _error = AppStrings.segmentOverlap);
        return;
      }
    }

    setState(() => _error = null);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _validate();
    }
  }

  void _submit() {
    if (!_isValid) return;

    final startDt = _timeOfDayToDateTime(_startTime!);
    final endDt = _timeOfDayToDateTime(_endTime!);
    final durationSec = durationInSeconds(startDt, endDt);

    final segment = TimeSegmentEntity(
      id: _uuid.v4(),
      todoId: widget.todoId,
      startTime: startDt.toIso8601String(),
      endTime: endDt.toIso8601String(),
      durationSeconds: durationSec,
      manual: true,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    Navigator.of(context).pop(segment);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    String? durationPreview;
    if (_startTime != null && _endTime != null && _error == null) {
      final startMin = _timeOfDayToMinutes(_startTime!);
      final endMin = _timeOfDayToMinutes(_endTime!);
      if (endMin > startMin) {
        durationPreview = formatDuration((endMin - startMin) * 60);
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.addManualSegment,
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _TimePickerField(
                  label: AppStrings.segmentStart,
                  value: _startTime,
                  onTap: () => _pickTime(isStart: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TimePickerField(
                  label: AppStrings.segmentEnd,
                  value: _endTime,
                  onTap: () => _pickTime(isStart: false),
                ),
              ),
            ],
          ),
          if (durationPreview != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16,
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${AppStrings.segmentDuration}: $durationPreview',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.error)),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _isValid ? _submit : null,
                child: const Text(AppStrings.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayText =
        value != null ? value!.format(context) : '—:—';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.schedule),
        ),
        child: Text(
          displayText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: value != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
