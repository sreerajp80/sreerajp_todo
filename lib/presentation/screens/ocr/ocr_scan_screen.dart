import 'dart:async';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/ocr_task_parser.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/ocr_enhance_screen.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/widgets/ocr_camera_overlay.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/widgets/ocr_result_bottom_sheet.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

/// Full-screen OCR Camera Scanner offering advanced camera controls:
/// - Real-time viewfinder with framing overlay
/// - Flash / torch control (off, torch, auto)
/// - Lens switching (rear / front)
/// - Pinch-to-zoom & 1x/2x quick zoom buttons
/// - Tap to focus and exposure metering
/// - High-resolution still capture read by on-device Tesseract OCR
/// - Gallery photo import via FilePicker
/// - Interactive task review sheet
class OcrScanScreen extends ConsumerStatefulWidget {
  const OcrScanScreen({
    super.key,
    this.date,
    this.returnResultDirectly = false,
  });

  /// Target date for the scanned task. Defaults to today.
  final String? date;

  /// If true, pops with the parsed title and description map instead of
  /// creating a task directly. Useful when invoked from the create/edit screen.
  final bool returnResultDirectly;

  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

enum _ControlMode { zoom, brightness }

class _OcrScanScreenState extends ConsumerState<OcrScanScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;

  FlashMode _flashMode = FlashMode.off;
  double _minZoom = 1.0;
  double _maxZoom = 4.0;
  double _currentZoom = 1.0;
  double _baseScale = 1.0;

  double _minExposure = -2.0;
  double _maxExposure = 2.0;
  double _exposureStep = 0.5;
  double _currentExposure = 0.0;
  bool _hasExposureControl = false;
  _ControlMode _controlMode = _ControlMode.zoom;

  Offset? _focusPoint;
  Timer? _focusTimer;
  bool _isFocusLocked = false;

  /// Wraps the preview so a tap can be normalised against the preview box
  /// rather than the whole screen. The preview is letterboxed inside a
  /// [Center], so the two differ by the size of the bars.
  final GlobalKey _previewKey = GlobalKey();

  String get _effectiveDate => widget.date ?? todayAsIso();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controller = _controller;
      if (controller == null) return;

      // Clear the field first. This runs every time the gallery picker or the
      // crop screen opens, and build() must never paint a disposed controller.
      setState(() {
        _controller = null;
        _isCameraInitialized = false;
        _focusPoint = null;
        _isFocusLocked = false;
      });
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) return;

      // The camera list is empty when permission was refused, so start over
      // rather than indexing into nothing.
      if (_cameras.isEmpty) {
        _initializeCamera();
        return;
      }
      _selectedCameraIndex = _selectedCameraIndex.clamp(0, _cameras.length - 1);
      _initializeCameraController(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No camera found on device';
          });
        }
        return;
      }

      // Default to rear camera if available
      int initialIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (initialIndex == -1) initialIndex = 0;
      _selectedCameraIndex = initialIndex;

      await _initializeCameraController(_cameras[_selectedCameraIndex]);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.code == 'CameraAccessDenied'
              ? context.l10n.ocrCameraPermissionRequired
              : e.description ?? 'Camera initialization failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    final previousController = _controller;
    final newController = CameraController(
      cameraDescription,
      // Full sensor resolution. On Android this maps to CameraX's
      // "highest available" strategy, so a 50 MP sensor captures 50 MP.
      // Detail thrown away at capture can never be enlarged back in later,
      // and thin marks like `.` `,` `:` are the first thing a small capture
      // loses. OcrCaptureDownscaler shrinks the photo once, natively, before
      // any Dart pixel work touches it.
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Stop painting the old controller *before* disposing it. Rendering a
    // disposed CameraController throws.
    if (mounted) {
      setState(() {
        _controller = null;
        _isCameraInitialized = false;
      });
    }
    await previousController?.dispose();

    if (!mounted) {
      await newController.dispose();
      return;
    }
    setState(() {
      _controller = newController;
      _isCameraInitialized = false;
    });

    try {
      await newController.initialize();
      _minZoom = await newController.getMinZoomLevel();
      _maxZoom = (await newController.getMaxZoomLevel()).clamp(1.0, 8.0);
      _currentZoom = _minZoom;
      await newController.setFlashMode(_flashMode);

      try {
        _minExposure = await newController.getMinExposureOffset();
        _maxExposure = await newController.getMaxExposureOffset();
        _exposureStep = await newController.getExposureOffsetStepSize();
        if (_exposureStep <= 0) _exposureStep = 0.5;
        _hasExposureControl = _minExposure < _maxExposure;
        _currentExposure = 0.0;
        await newController.setExposureOffset(0.0);
      } catch (_) {
        _hasExposureControl = false;
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _errorMessage = null;
        });
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.description ?? 'Failed to initialize camera';
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.torch,
      FlashMode.torch => FlashMode.auto,
      FlashMode.auto => FlashMode.off,
      _ => FlashMode.off,
    };

    try {
      await controller.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (_) {
      // Hardware flash might not be supported on this lens
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _selectedCameraIndex = nextIndex;
    // A focus point belongs to the lens that was aimed, so drop it.
    _isFocusLocked = false;
    _focusPoint = null;
    await _initializeCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _setZoom(double zoom) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final clamped = zoom.clamp(_minZoom, _maxZoom);
    try {
      await controller.setZoomLevel(clamped);
      setState(() => _currentZoom = clamped);
    } catch (_) {
      // Safe to ignore: camera hardware may not support requested zoom level.
    }
  }

  Future<void> _setExposure(double value) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final clamped = value.clamp(_minExposure, _maxExposure);
    try {
      await controller.setExposureOffset(clamped);
      setState(() => _currentExposure = clamped);
    } catch (_) {
      // Safe to ignore: camera hardware may not support exposure compensation.
    }
  }

  Future<void> _resetExposure() async {
    await _setExposure(0.0);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _currentZoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale == 1.0) return;
    _setZoom(_baseScale * details.scale);
  }

  Future<void> _onTapToFocus(TapUpDetails details) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Normalise against the preview box, not the screen. The preview is
    // letterboxed inside a Center, so dividing by the screen size shifts the
    // point by the height of the black bars and the focus lands off the page.
    final previewBox =
        _previewKey.currentContext?.findRenderObject() as RenderBox?;
    if (previewBox == null) return;

    final localOffset = previewBox.globalToLocal(details.globalPosition);
    final size = previewBox.size;
    if (size.isEmpty) return;

    // A tap on the letterbox bars falls outside the sensor's field of view.
    if (localOffset.dx < 0 ||
        localOffset.dy < 0 ||
        localOffset.dx > size.width ||
        localOffset.dy > size.height) {
      return;
    }

    final x = (localOffset.dx / size.width).clamp(0.0, 1.0);
    final y = (localOffset.dy / size.height).clamp(0.0, 1.0);

    setState(() => _focusPoint = details.localPosition);
    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _focusPoint = null);
    });

    try {
      await controller.setFocusPoint(Offset(x, y));
      await controller.setExposurePoint(Offset(x, y));
      // Hold the focus where the user put it. Continuous autofocus otherwise
      // hunts away from a flat page within a second or two.
      await controller.setFocusMode(FocusMode.locked);
      if (mounted) setState(() => _isFocusLocked = true);
    } catch (_) {
      // Not every lens supports focus points or focus locking.
    }
  }

  /// Hands focus back to the camera's continuous autofocus.
  Future<void> _unlockFocus() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setFocusMode(FocusMode.auto);
    } catch (_) {
      // Nothing to undo when the lens never accepted the lock.
    }
    if (mounted) setState(() => _isFocusLocked = false);
  }

  Future<void> _capturePhotoAndRecognize() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final file = await controller.takePicture();
      if (!mounted) return;

      final recognizedText = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => OcrEnhanceScreen(imagePath: file.path),
        ),
      );
      if (recognizedText == null || !mounted) return;

      await _handleRecognizedText(recognizedText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.ocrImageCaptureFailed(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      final path = result?.files.single.path;
      if (path == null || !mounted) return;

      final recognizedText = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => OcrEnhanceScreen(imagePath: path)),
      );
      if (recognizedText == null || !mounted) return;

      setState(() => _isProcessing = true);
      await _handleRecognizedText(recognizedText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.ocrImagePickFailed(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Turns the text the enhance screen read into a task for review.
  Future<void> _handleRecognizedText(String recognizedText) async {
    final text = recognizedText.trim();

    if (!mounted) return;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.ocrNoTextFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final parsedResult = OcrTaskParser.parse(text);

    await OcrResultBottomSheet.show(
      context: context,
      result: parsedResult,
      date: _effectiveDate,
      returnResultDirectly: widget.returnResultDirectly,
      onOpenEditor: (title, description) {
        _navigateToFullEditor(title, description);
      },
      onRetake: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _navigateToFullEditor(String title, String description) {
    Navigator.of(context).pop(); // Close bottom sheet

    if (widget.returnResultDirectly) {
      // Pop back to the calling screen with the scanned fields
      Navigator.of(context).pop({'title': title, 'description': description});
      return;
    }

    // Close OCR scanner screen so user lands cleanly on the task editor
    Navigator.of(context).pop();

    // Open full CreateEditTodoScreen pre-populated via route query parameters
    context.push(
      AppRoutes.createTodoPath(
        date: _effectiveDate,
        title: title,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or Error Message
          if (_isCameraInitialized && _controller != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onTapUp: _onTapToFocus,
              child: Center(
                child: CameraPreview(_controller!, key: _previewKey),
              ),
            )
          else
            _buildErrorOrLoadingView(),

          // Camera Viewfinder Framing Overlay
          if (_isCameraInitialized)
            OcrCameraOverlay(
              hintText: l10n.ocrScanHint,
              focusPoint: _focusPoint,
            ),

          // Top App Bar Controls
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Row(
                  children: [
                    _buildCircleButton(
                      icon: switch (_flashMode) {
                        FlashMode.torch => Icons.flash_on,
                        FlashMode.auto => Icons.flash_auto,
                        _ => Icons.flash_off,
                      },
                      tooltip: switch (_flashMode) {
                        FlashMode.torch => l10n.ocrTorchOn,
                        FlashMode.auto => l10n.ocrTorchAuto,
                        _ => l10n.ocrTorchOff,
                      },
                      onPressed: _toggleFlash,
                      isActive: _flashMode != FlashMode.off,
                    ),
                    const SizedBox(width: 8),
                    if (_cameras.length > 1) ...[
                      _buildCircleButton(
                        icon: Icons.flip_camera_ios,
                        tooltip: l10n.ocrSwitchCamera,
                        onPressed: _switchCamera,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildCircleButton(
                      icon: Icons.photo_library_outlined,
                      tooltip: l10n.ocrPickGallery,
                      onPressed: _pickImageFromGallery,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Autofocus lock indicator. Tapping it returns to continuous
          // autofocus.
          if (_isCameraInitialized && _isFocusLocked)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 64,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  key: const Key('ocr-af-lock-chip'),
                  onTap: _unlockFocus,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.defaultLightAccent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.ocrFocusLocked,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Controls: Zoom presets & Capture Shutter
          if (_isCameraInitialized)
            Positioned(
              bottom:
                  MediaQuery.paddingOf(context).bottom +
                  (MediaQuery.orientationOf(context) == Orientation.landscape
                      ? 6
                      : 24),
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Interactive Adjustment Bar (Zoom & Brightness Sliders)
                  _buildAdjustmentControls(Theme.of(context)),
                  SizedBox(
                    height:
                        MediaQuery.orientationOf(context) ==
                            Orientation.landscape
                        ? 6
                        : 14,
                  ),

                  // Shutter Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Spacer to balance gallery
                      const SizedBox(width: 48),

                      // Central Shutter Button
                      GestureDetector(
                        onTap: _isProcessing ? null : _capturePhotoAndRecognize,
                        child: Container(
                          width:
                              MediaQuery.orientationOf(context) ==
                                  Orientation.landscape
                              ? 60
                              : 78,
                          height:
                              MediaQuery.orientationOf(context) ==
                                  Orientation.landscape
                              ? 60
                              : 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width:
                                  MediaQuery.orientationOf(context) ==
                                      Orientation.landscape
                                  ? (_isProcessing ? 28 : 48)
                                  : (_isProcessing ? 36 : 64),
                              height:
                                  MediaQuery.orientationOf(context) ==
                                      Orientation.landscape
                                  ? (_isProcessing ? 28 : 48)
                                  : (_isProcessing ? 36 : 64),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isProcessing
                                    ? AppTheme.defaultLightAccent
                                    : Colors.white,
                              ),
                              child: _isProcessing
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      // Gallery shortcut button
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 32,
                        ),
                        tooltip: l10n.ocrPickGallery,
                        onPressed: _pickImageFromGallery,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Full-screen Loading indicator while extracting text
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.defaultLightAccent,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.ocrProcessing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Widget _buildAdjustmentControls(ThemeData theme) {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode switch tabs (Zoom vs Brightness)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlModeTab(
                mode: _ControlMode.zoom,
                icon: Icons.zoom_in,
                label:
                    '${l10n.ocrZoomLabel} ${_currentZoom.toStringAsFixed(1)}x',
              ),
              if (_hasExposureControl) ...[
                const SizedBox(width: 8),
                _buildControlModeTab(
                  mode: _ControlMode.brightness,
                  icon: Icons.wb_sunny_outlined,
                  label:
                      '${l10n.ocrBrightnessLabel} ${_currentExposure >= 0 ? '+' : ''}${_currentExposure.toStringAsFixed(1)} EV',
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Active slider
          if (_controlMode == _ControlMode.zoom) ...[
            Row(
              children: [
                const Icon(Icons.remove, color: Colors.white60, size: 16),
                Expanded(
                  child: Slider(
                    value: _currentZoom.clamp(_minZoom, _maxZoom),
                    min: _minZoom,
                    max: _maxZoom,
                    activeColor: AppTheme.defaultLightAccent,
                    inactiveColor: Colors.white24,
                    onChanged: _setZoom,
                  ),
                ),
                const Icon(Icons.add, color: Colors.white60, size: 16),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildZoomChip(1.0, '1x'),
                const SizedBox(width: 8),
                _buildZoomChip(2.0, '2x'),
                const SizedBox(width: 8),
                _buildZoomChip(3.0, '3x'),
                if (_maxZoom >= 5.0) ...[
                  const SizedBox(width: 8),
                  _buildZoomChip(5.0, '5x'),
                ],
              ],
            ),
          ] else if (_controlMode == _ControlMode.brightness &&
              _hasExposureControl) ...[
            Row(
              children: [
                const Icon(
                  Icons.brightness_low,
                  color: Colors.white60,
                  size: 16,
                ),
                Expanded(
                  child: Slider(
                    value: _currentExposure.clamp(_minExposure, _maxExposure),
                    min: _minExposure,
                    max: _maxExposure,
                    divisions: ((_maxExposure - _minExposure) / _exposureStep)
                        .round()
                        .clamp(4, 20),
                    activeColor: AppTheme.defaultLightAccent,
                    inactiveColor: Colors.white24,
                    onChanged: _setExposure,
                  ),
                ),
                const Icon(
                  Icons.brightness_high,
                  color: Colors.white60,
                  size: 16,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.restore,
                    color: Colors.white70,
                    size: 18,
                  ),
                  tooltip: l10n.ocrResetExposure,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: _resetExposure,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlModeTab({
    required _ControlMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _controlMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _controlMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.defaultLightAccent.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.defaultLightAccent
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.white60,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomChip(double zoomLevel, String label) {
    final isSelected = (_currentZoom - zoomLevel).abs() < 0.2;
    return GestureDetector(
      onTap: () => _setZoom(zoomLevel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.defaultLightAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.defaultLightAccent.withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildErrorOrLoadingView() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white54,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: AppTheme.defaultLightAccent),
    );
  }
}
