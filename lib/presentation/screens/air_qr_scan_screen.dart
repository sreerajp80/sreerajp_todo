import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/errors/exceptions.dart';
import 'package:sreerajp_todo/presentation/shared/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/domain/entities/air_qr_progress.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/air_qr_preview_sheet.dart';
import 'package:sreerajp_todo/core/logging/app_logger.dart';

/// Why the camera scanner cannot run.
enum _ScanProblem { none, permissionDenied, cameraFailed, unavailable }

/// Camera codes the `camera` plugin uses when access is refused.
const _deniedCameraCodes = {
  'CameraAccessDenied',
  'CameraAccessDeniedWithoutPrompt',
  'CameraAccessRestricted',
};

/// Scans AirQR codes with the camera.
///
/// The `camera` plugin streams frames; each frame's brightness plane goes to
/// [qrDecoderServiceProvider] (ZXing on the Android host). While one frame is
/// being decoded, new frames are skipped, so the camera never backs up.
class AirQrScanScreen extends ConsumerStatefulWidget {
  const AirQrScanScreen({super.key});

  @override
  ConsumerState<AirQrScanScreen> createState() => _AirQrScanScreenState();
}

class _AirQrScanScreenState extends ConsumerState<AirQrScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _ScanProblem _problem = _ScanProblem.none;
  bool _torchOn = false;
  bool _torchAvailable = true;

  /// True while a frame is with the decoder.
  bool _decoding = false;

  /// True while a result is being handled; frames are ignored meanwhile.
  bool _handling = false;

  final AirQrService _airQrService = AirQrService();
  AirQrProgress _airProgress = const AirQrProgress(status: AirQrStatus.idle);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controller = _controller;
      if (controller == null) return;
      // Clear the field first, so build() never paints a disposed controller.
      setState(() {
        _controller = null;
        _torchOn = false;
      });
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && _problem == _ScanProblem.none) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    // Live frames and the ZXing decoder exist on Android only.
    if (kIsWeb || !Platform.isAndroid) {
      setState(() => _problem = _ScanProblem.unavailable);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _problem = _ScanProblem.cameraFailed);
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _problem = _ScanProblem.none;
      });
      await _startStream();
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _problem = _deniedCameraCodes.contains(e.code)
            ? _ScanProblem.permissionDenied
            : _ScanProblem.cameraFailed;
      });
    } catch (e, st) {
      AppLogger.error(
        'AirQrScanScreen: camera start failed',
        error: e,
        stackTrace: st,
      );
      if (mounted) setState(() => _problem = _ScanProblem.cameraFailed);
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isStreamingImages) return;
    await controller.startImageStream(_onFrame);
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isStreamingImages) return;
    try {
      await controller.stopImageStream();
    } catch (_) {
      // Safe to ignore: the stream may already have stopped.
    }
  }

  void _onFrame(CameraImage image) {
    if (_decoding || _handling || image.planes.isEmpty) return;
    _decoding = true;

    final plane = image.planes.first;
    ref
        .read(qrDecoderServiceProvider)
        .decodeFrame(
          bytes: plane.bytes,
          width: image.width,
          height: image.height,
          rowStride: plane.bytesPerRow,
        )
        .then((text) async {
          if (text != null && mounted && !_handling) {
            await _onDetect(text.trim());
          }
        })
        .catchError((Object e) {
          if (e is QrScannerUnavailableException) {
            _stopStream();
            if (mounted) setState(() => _problem = _ScanProblem.unavailable);
          } else {
            AppLogger.debug(
              'AirQrScanScreen: frame decode failed (${e.runtimeType})',
            );
          }
        })
        .whenComplete(() => _decoding = false);
  }

  Future<void> _onDetect(String raw) async {
    if (_handling || raw.isEmpty) return;

    // Process AirQR Stream Frame
    if (raw.startsWith('AIRQR|')) {
      final progress = _airQrService.processFrameString(raw, _airProgress);
      setState(() {
        _airProgress = progress;
      });

      if (progress.status == AirQrStatus.receiving) {
        // Keep scanning frames
        return;
      }

      if (progress.status == AirQrStatus.error) {
        _handling = true;
        await _stopStream();
        _airQrService.reset();
        if (!mounted) return;
        await _resumeAfterMessage(context.l10n.airQrScanStreamFailed);
        return;
      }

      if (progress.status == AirQrStatus.completed &&
          progress.reassembledContent != null) {
        _handling = true;
        await _stopStream();
        final content = progress.reassembledContent!;
        _airQrService.reset();
        setState(() {
          _airProgress = const AirQrProgress(status: AirQrStatus.idle);
        });
        await _processScannedPayload(content);
        return;
      }
    }

    // Direct single payload scan fallback
    if (raw.startsWith(AirQrPayloadService.headerPrefix) ||
        raw.startsWith('{')) {
      _handling = true;
      await _stopStream();
      await _processScannedPayload(raw);
      return;
    }

    if (_airProgress.status == AirQrStatus.idle) {
      _handling = true;
      await _stopStream();
      if (!mounted) return;
      await _resumeAfterMessage(context.l10n.airQrScanUnrecognized);
    }
  }

  Future<void> _processScannedPayload(String rawPayload) async {
    final parsed = AirQrPayloadService.parsePayload(rawPayload);

    if (parsed.type == AirQrPayloadType.unknown) {
      if (!mounted) return;
      await _resumeAfterMessage(context.l10n.airQrPayloadFormatError);
      return;
    }

    if (!mounted) return;

    final decision = await showAirQrPreviewSheet(context, parsed);

    if (decision == null || decision == AirQrMergeDecision.cancel) {
      await _resume();
      return;
    }

    // Return the parsed payload & decision back to calling screen
    if (mounted) {
      Navigator.of(context).pop({'payload': parsed, 'decision': decision});
    }
  }

  Future<void> _resumeAfterMessage(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    await _resume();
  }

  Future<void> _resume() async {
    if (!mounted) return;
    setState(() {
      _airProgress = const AirQrProgress(status: AirQrStatus.idle);
    });
    _handling = false;
    try {
      await _startStream();
    } catch (_) {
      // Safe to ignore: the camera may have been released meanwhile.
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    final turnOn = !_torchOn;
    try {
      await controller.setFlashMode(turnOn ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = turnOn);
    } catch (_) {
      // This camera has no torch; hide the button.
      if (mounted) setState(() => _torchAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = Theme.of(context).colorScheme.primary;
    final isReceiving = _airProgress.status == AirQrStatus.receiving;
    final controller = _controller;
    final showTorch =
        _torchAvailable &&
        _problem == _ScanProblem.none &&
        controller != null &&
        controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          isReceiving ? l10n.airQrScanReceivingTitle : l10n.airQrScanTitle,
        ),
        actions: [
          if (showTorch)
            IconButton(
              icon: Icon(
                _torchOn ? Icons.flash_on : Icons.flash_off,
                color: _torchOn ? Colors.amber : Colors.white,
              ),
              tooltip: _torchOn
                  ? l10n.airQrScanTorchOff
                  : l10n.airQrScanTorchOn,
              onPressed: _toggleTorch,
            ),
        ],
      ),
      body: _problem != _ScanProblem.none
          ? _ScannerError(problem: _problem)
          : Stack(
              fit: StackFit.expand,
              children: [
                if (controller != null && controller.value.isInitialized)
                  Center(child: CameraPreview(controller))
                else
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                // Target box overlay
                IgnorePointer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isReceiving ? Colors.blue : accent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!isReceiving)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            l10n.airQrScanHint,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Stream Progress Overlay
                if (isReceiving)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 40,
                    child: _StreamProgressCard(progress: _airProgress),
                  ),
              ],
            ),
    );
  }
}

class _StreamProgressCard extends StatelessWidget {
  const _StreamProgressCard({required this.progress});

  final AirQrProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade400, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        l10n.airQrScanProgress(progress.progressPercent),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.airQrScanFps(progress.fps.toStringAsFixed(1)),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.progressRatio,
              backgroundColor: Colors.grey.shade800,
              color: Colors.blue,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.airQrScanBlocks(
              progress.receivedBlockCount,
              progress.totalBlocks,
            ),
            style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.problem});

  final _ScanProblem problem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (IconData icon, String message) = switch (problem) {
      _ScanProblem.permissionDenied => (
        Icons.no_photography_outlined,
        l10n.airQrScanPermissionDenied,
      ),
      _ScanProblem.unavailable => (
        Icons.qr_code_scanner,
        l10n.airQrScanUnavailable,
      ),
      _ => (Icons.error_outline, l10n.airQrScanCameraError),
    };
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
