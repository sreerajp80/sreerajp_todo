import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sreerajp_todo/data/services/air_qr_payload_service.dart';
import 'package:sreerajp_todo/data/services/air_qr_service.dart';
import 'package:sreerajp_todo/domain/entities/air_qr_progress.dart';
import 'package:sreerajp_todo/presentation/widgets/air_qr_preview_sheet.dart';

class AirQrScanScreen extends StatefulWidget {
  const AirQrScanScreen({super.key});

  @override
  State<AirQrScanScreen> createState() => _AirQrScanScreenState();
}

class _AirQrScanScreenState extends State<AirQrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  final AirQrService _airQrService = AirQrService();
  AirQrProgress _airProgress = const AirQrProgress(status: AirQrStatus.idle);
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;

    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

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
        await _resumeAfterMessage(
          progress.errorMessage ?? 'AirQR stream reassembly failed',
        );
        _airQrService.reset();
        setState(() {
          _airProgress = const AirQrProgress(status: AirQrStatus.idle);
        });
        return;
      }

      if (progress.status == AirQrStatus.completed &&
          progress.reassembledContent != null) {
        _handling = true;
        await _controller.stop();
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
      await _controller.stop();
      await _processScannedPayload(raw);
      return;
    }

    if (!_handling && _airProgress.status == AirQrStatus.idle) {
      _handling = true;
      await _controller.stop();
      await _resumeAfterMessage('Unrecognized QR code format');
    }
  }

  Future<void> _processScannedPayload(String rawPayload) async {
    final parsed = AirQrPayloadService.parsePayload(rawPayload);

    if (parsed.type == AirQrPayloadType.unknown) {
      await _resumeAfterMessage('Could not read AirQR payload data');
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
      Navigator.of(context).pop({
        'payload': parsed,
        'decision': decision,
      });
    }
  }

  Future<void> _resumeAfterMessage(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    await _resume();
  }

  Future<void> _resume() async {
    if (!mounted) return;
    try {
      await _controller.start();
    } catch (_) {}
    _handling = false;
    setState(() {
      _airProgress = const AirQrProgress(status: AirQrStatus.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isReceiving = _airProgress.status == AirQrStatus.receiving;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          isReceiving ? 'Receiving AirQR Stream' : 'AirQR Camera Scanner',
        ),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              final on = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  on ? Icons.flash_on : Icons.flash_off,
                  color: on ? Colors.amber : Colors.white,
                ),
                tooltip: on ? 'Turn torch off' : 'Turn torch on',
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScannerError(error: error),
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
                    child: const Text(
                      'Point camera at animated AirQR stream screen',
                      style: TextStyle(color: Colors.white, fontSize: 13.5),
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
              child: Container(
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
                        Row(
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
                            Text(
                              'AirQR Stream... ${_airProgress.progressPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_airProgress.fps.toStringAsFixed(1)} FPS',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _airProgress.progressRatio,
                        backgroundColor: Colors.grey.shade800,
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Captured ${_airProgress.receivedBlockCount} of ${_airProgress.totalBlocks} blocks',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  final MobileScannerException error;

  const _ScannerError({required this.error});

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                denied ? Icons.no_photography_outlined : Icons.error_outline,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                denied
                    ? 'Camera access is needed to scan AirQR codes.\nGrant camera permission in system settings.'
                    : 'The camera could not be started.\n${error.errorDetails?.message ?? ''}',
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
