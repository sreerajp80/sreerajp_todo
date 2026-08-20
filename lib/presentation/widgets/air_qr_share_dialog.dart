import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/services/air_qr_payload_service.dart';
import 'package:sreerajp_todo/data/services/air_qr_service.dart';
import 'package:sreerajp_todo/domain/entities/air_qr_frame.dart';

/// Shows an animated AirQR stream dialog for sharing todos or backups air-gapped.
Future<void> showAirQrShareDialog(
  BuildContext context, {
  required String title,
  List<TodoEntity>? todos,
  Map<String, dynamic>? backupMap,
  String date = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AirQrShareDialog(
      title: title,
      todos: todos,
      backupMap: backupMap,
      date: date,
    ),
  );
}

class AirQrShareDialog extends StatefulWidget {
  final String title;
  final List<TodoEntity>? todos;
  final Map<String, dynamic>? backupMap;
  final String date;

  const AirQrShareDialog({
    super.key,
    required this.title,
    this.todos,
    this.backupMap,
    this.date = '',
  });

  @override
  State<AirQrShareDialog> createState() => _AirQrShareDialogState();
}

class _AirQrShareDialogState extends State<AirQrShareDialog> {
  late List<AirQrFrame> _frames;
  int _currentIndex = 0;
  bool _isPlaying = true;
  int _targetFps = 10;
  Timer? _streamTimer;

  @override
  void initState() {
    super.initState();
    _prepareFrames();
    _startStreaming();
  }

  void _prepareFrames() {
    final String payload;
    if (widget.backupMap != null) {
      payload = AirQrPayloadService.encodeBackup(widget.backupMap!);
    } else if (widget.todos != null && widget.todos!.isNotEmpty) {
      payload = AirQrPayloadService.encodeTasks(
        widget.todos!,
        date: widget.date,
      );
    } else {
      payload = '';
    }

    _frames = AirQrService.encodePayload(payload);
  }

  void _startStreaming() {
    _streamTimer?.cancel();
    if (!_isPlaying || _frames.isEmpty) return;

    final intervalMs = (1000 / _targetFps).round();
    _streamTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _frames.length;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startStreaming();
    } else {
      _streamTimer?.cancel();
    }
  }

  void _changeFps(int newFps) {
    setState(() {
      _targetFps = newFps;
    });
    if (_isPlaying) {
      _startStreaming();
    }
  }

  int get _totalBlocks => _frames.isEmpty ? 0 : _frames.first.totalBlocks;
  int get _payloadSizeBytes => _totalBlocks * AirQrService.defaultBlockSize;
  double get _payloadSizeKb => _payloadSizeBytes / 1024;

  String get _estimatedTimeLabel {
    if (_totalBlocks == 0 || _targetFps <= 0) return '0s';
    final totalSec = (_totalBlocks / _targetFps).ceil();
    if (totalSec < 60) {
      return '~${totalSec}s';
    }
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return secs > 0 ? '~$mins m $secs s' : '~$mins m';
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }

  Widget _buildPayloadEstimateBanner(ThemeData theme) {
    final isBackup = widget.backupMap != null;
    final isLarge = _payloadSizeKb >= 300;
    final sizeFormatted = _payloadSizeKb < 1
        ? '$_payloadSizeBytes B'
        : '${_payloadSizeKb.toStringAsFixed(1)} KB';

    final Color bannerColor = isLarge
        ? Colors.amber.shade50
        : (isBackup
              ? Colors.blue.shade50
              : theme.colorScheme.surfaceContainerHighest);
    final Color borderColor = isLarge
        ? Colors.amber.shade400
        : (isBackup ? Colors.blue.shade300 : theme.colorScheme.outlineVariant);
    final Color iconColor = isLarge
        ? Colors.amber.shade900
        : (isBackup
              ? Colors.blue.shade800
              : theme.colorScheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLarge ? Icons.warning_amber_rounded : Icons.info_outline,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Est. scan time: $_estimatedTimeLabel ($sizeFormatted)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          if (isBackup && isLarge) ...[
            const SizedBox(height: 4),
            Text(
              'Large database detected. Camera sync may take time. For faster transfer, Encrypted File Backup (.zip) is recommended.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.amber.shade900,
              ),
            ),
          ] else if (isBackup) ...[
            const SizedBox(height: 2),
            Text(
              'Full app backup ready for optical sync. Hold target phone camera steady.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_frames.isEmpty) {
      return AlertDialog(
        title: Text(widget.title),
        content: const Text('Could not generate AirQR stream payload.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final currentFrame = _frames[_currentIndex];
    final frameTypeLabel = currentFrame.isParity
        ? 'Fountain Parity'
        : 'Systematic Block';

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sensors, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'AirQR Optical Stream (${_frames.length} frames)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPayloadEstimateBanner(theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox.square(
                dimension: 230,
                child: QrImageView(
                  data: currentFrame.toQrString(),
                  size: 230,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (_, _) =>
                      const Center(child: Text('Frame rendering error')),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Frame ${_currentIndex + 1} / ${_frames.length} • $frameTypeLabel',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                  iconSize: 32,
                  color: theme.colorScheme.primary,
                  onPressed: _togglePlayPause,
                  tooltip: _isPlaying ? 'Pause stream' : 'Resume stream',
                ),
                for (final fps in [5, 10, 15, 20, 25])
                  ChoiceChip(
                    label: Text('${fps}FPS'),
                    selected: _targetFps == fps,
                    onSelected: (_) => _changeFps(fps),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
