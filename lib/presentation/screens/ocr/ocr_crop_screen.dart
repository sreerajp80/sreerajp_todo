import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/presentation/screens/ocr/utils/ocr_image_filter.dart';
import 'package:sreerajp_todo/presentation/shared/theme/app_theme.dart';

/// Professional post-capture document editor and cropper.
///
/// Features:
/// - Live 90° Clockwise and Counter-Clockwise image rotation with instant preview.
/// - Document enhancement filter presets: Original, Magic B&W, Grayscale, Brighten.
/// - Fine-tuning sliders for manual Brightness (-50 to +50) and Contrast (0.5x to 2.5x).
/// - 1x / 1.5x / 2x zoom toggle for inspecting small handwriting and details.
/// - 8-point interactive cropping with rule-of-thirds framing guides.
/// - Fully responsive in both portrait and landscape device orientations.
/// - Lossless high-resolution pixel export for Google ML Kit OCR text extraction.
class OcrCropScreen extends StatefulWidget {
  const OcrCropScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<OcrCropScreen> createState() => _OcrCropScreenState();
}

enum _ActiveHandle {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
  inside,
}

enum _EditorTab {
  crop,
  filters,
  tune,
}

class _OcrCropScreenState extends State<OcrCropScreen> {
  ui.Image? _decodedImage;
  bool _isLoading = true;
  bool _isCropping = false;
  String? _errorMessage;

  // Normalized crop rectangle [0.0, 1.0] relative to original image
  Rect _cropRect = const Rect.fromLTWH(0.08, 0.15, 0.84, 0.65);
  _ActiveHandle _activeHandle = _ActiveHandle.none;
  Offset? _lastPanPos;
  int _rotationQuarterTurns = 0;

  // Editor Tabs & Adjustments
  _EditorTab _activeTab = _EditorTab.crop;
  OcrFilterMode _filterMode = OcrFilterMode.original;
  double _brightness = 0.0; // -50.0 to +50.0
  double _contrast = 1.0; // 0.5 to 2.5
  double _zoomFactor = 1.0; // 1.0, 1.5, 2.0

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _decodedImage?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      if (mounted) {
        setState(() {
          _decodedImage = image;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load image: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<double> get _activeColorMatrix {
    if (_brightness != 0.0 || _contrast != 1.0) {
      return OcrImageFilter.generateMatrix(
        brightness: _brightness,
        contrast: _contrast,
        isGrayscale: _filterMode == OcrFilterMode.documentBw ||
            _filterMode == OcrFilterMode.grayscale,
      );
    }
    return OcrImageFilter.matrixForMode(_filterMode);
  }

  ColorFilter? get _activeColorFilter {
    if (_brightness == 0.0 &&
        _contrast == 1.0 &&
        _filterMode == OcrFilterMode.original) {
      return null;
    }
    return ColorFilter.matrix(_activeColorMatrix);
  }

  Future<void> _rotateClockwise() async {
    await _rotateByAngle(math.pi / 2, isCw: true);
  }

  Future<void> _rotateCounterClockwise() async {
    await _rotateByAngle(-math.pi / 2, isCw: false);
  }

  Future<void> _rotateByAngle(double angleRadians, {required bool isCw}) async {
    final image = _decodedImage;
    if (image == null || _isCropping || _isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final newW = image.height;
      final newH = image.width;

      if (isCw) {
        canvas.translate(newW.toDouble(), 0);
      } else {
        canvas.translate(0, newH.toDouble());
      }
      canvas.rotate(angleRadians);
      canvas.drawImage(
        image,
        Offset.zero,
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final rotatedImage = await picture.toImage(newW, newH);

      image.dispose();
      _rotationQuarterTurns = (_rotationQuarterTurns + (isCw ? 1 : 3)) % 4;

      if (mounted) {
        setState(() {
          _decodedImage = rotatedImage;
          _cropRect = const Rect.fromLTWH(0.08, 0.15, 0.84, 0.65);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to rotate image: $e')));
      }
    }
  }

  void _resetCrop() {
    setState(() {
      _cropRect = const Rect.fromLTWH(0.08, 0.15, 0.84, 0.65);
    });
    HapticFeedback.selectionClick();
  }

  void _resetAdjustments() {
    setState(() {
      _filterMode = OcrFilterMode.original;
      _brightness = 0.0;
      _contrast = 1.0;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _confirmCrop() async {
    final image = _decodedImage;
    if (image == null || _isCropping) return;

    setState(() => _isCropping = true);
    HapticFeedback.mediumImpact();

    try {
      final pixelWidth = image.width.toDouble();
      final pixelHeight = image.height.toDouble();

      // Calculate exact pixel source rect on full resolution image
      final srcX = (_cropRect.left * pixelWidth).clamp(0.0, pixelWidth);
      final srcY = (_cropRect.top * pixelHeight).clamp(0.0, pixelHeight);
      final srcW = (_cropRect.width * pixelWidth).clamp(
        10.0,
        pixelWidth - srcX,
      );
      final srcH = (_cropRect.height * pixelHeight).clamp(
        10.0,
        pixelHeight - srcY,
      );

      final sourceRect = Rect.fromLTWH(srcX, srcY, srcW, srcH);
      final destRect = Rect.fromLTWH(0, 0, sourceRect.width, sourceRect.height);

      // Render lossless crop directly from source pixels with applied filter
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = _activeColorFilter;

      canvas.drawImageRect(image, sourceRect, destRect, paint);
      final picture = recorder.endRecording();

      final targetW = sourceRect.width.round().clamp(1, image.width);
      final targetH = sourceRect.height.round().clamp(1, image.height);
      final croppedImage = await picture.toImage(targetW, targetH);

      final byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to encode cropped image');
      }

      final croppedBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/ocr_crop_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(croppedBytes, flush: true);

      if (mounted) {
        Navigator.of(context).pop(outputPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cropping failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  Future<void> _useFullImage() async {
    final isUntouched = _rotationQuarterTurns == 0 &&
        _filterMode == OcrFilterMode.original &&
        _brightness == 0.0 &&
        _contrast == 1.0;

    if (isUntouched) {
      Navigator.of(context).pop(widget.imagePath);
      return;
    }

    final image = _decodedImage;
    if (image == null) return;

    setState(() => _isCropping = true);
    HapticFeedback.mediumImpact();

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = _activeColorFilter;

      canvas.drawImage(image, Offset.zero, paint);
      final picture = recorder.endRecording();
      final processedImage = await picture.toImage(image.width, image.height);

      final byteData = await processedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        if (mounted) Navigator.of(context).pop(widget.imagePath);
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/ocr_full_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      if (mounted) {
        Navigator.of(context).pop(outputPath);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop(widget.imagePath);
      }
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.ocrCropTitle),
        actions: [
          // Zoom toggle button (1x / 1.5x / 2x)
          TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _zoomFactor = switch (_zoomFactor) {
                  1.0 => 1.5,
                  1.5 => 2.0,
                  _ => 1.0,
                };
              });
            },
            icon: const Icon(Icons.zoom_in, size: 18, color: Colors.white70),
            label: Text(
              '${_zoomFactor}x',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.ocrResetFilter,
            onPressed: (_isLoading || _isCropping) ? null : _resetAdjustments,
          ),
        ],
      ),
      body: _buildBody(theme),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.defaultLightAccent),
      );
    }

    if (_errorMessage != null || _decodedImage == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage ?? 'Image not available',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Column(
      children: [
        // Guidance hint banner (portrait only to save vertical space in landscape)
        if (!isLandscape)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.crop, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    context.l10n.ocrCropHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

        // Interactive Cropper Viewport
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildCropArea(constraints);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCropArea(BoxConstraints constraints) {
    final image = _decodedImage!;
    final availableW = constraints.maxWidth;
    final availableH = constraints.maxHeight;

    final imageAspect = image.width / image.height;
    final screenAspect = availableW / availableH;

    double baseW, baseH;
    if (imageAspect > screenAspect) {
      baseW = availableW;
      baseH = availableW / imageAspect;
    } else {
      baseH = availableH;
      baseW = availableH * imageAspect;
    }

    final displayW = baseW * _zoomFactor;
    final displayH = baseH * _zoomFactor;

    final leftOffset = (availableW - displayW) / 2;
    final topOffset = (availableH - displayH) / 2;
    final imageRect = Rect.fromLTWH(leftOffset, topOffset, displayW, displayH);

    final screenCropRect = Rect.fromLTRB(
      imageRect.left + _cropRect.left * imageRect.width,
      imageRect.top + _cropRect.top * imageRect.height,
      imageRect.left + _cropRect.right * imageRect.width,
      imageRect.top + _cropRect.bottom * imageRect.height,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        _lastPanPos = details.localPosition;
        _activeHandle = _hitTestHandle(details.localPosition, screenCropRect);
      },
      onPanUpdate: (details) {
        if (_lastPanPos == null || _activeHandle == _ActiveHandle.none) return;
        final delta = details.localPosition - _lastPanPos!;
        _lastPanPos = details.localPosition;

        final normDeltaX = delta.dx / imageRect.width;
        final normDeltaY = delta.dy / imageRect.height;

        setState(() {
          _updateCropRect(normDeltaX, normDeltaY);
        });
      },
      onPanEnd: (_) {
        _activeHandle = _ActiveHandle.none;
        _lastPanPos = null;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Underlying photo with applied color filter - USING RawImage!
          Center(
            child: SizedBox(
              width: displayW,
              height: displayH,
              child: ColorFiltered(
                colorFilter: _activeColorFilter ??
                    const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.dst,
                    ),
                child: RawImage(
                  image: _decodedImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Custom Painted Crop Overlay
          Positioned.fromRect(
            rect: Rect.fromLTWH(0, 0, availableW, availableH),
            child: CustomPaint(
              painter: _CropOverlayPainter(
                imageRect: imageRect,
                cropRect: screenCropRect,
                accentColor: AppTheme.defaultLightAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ActiveHandle _hitTestHandle(Offset pos, Rect rect) {
    const handleHitRadius = 30.0;

    if ((pos - rect.topLeft).distance <= handleHitRadius) {
      return _ActiveHandle.topLeft;
    }
    if ((pos - rect.topRight).distance <= handleHitRadius) {
      return _ActiveHandle.topRight;
    }
    if ((pos - rect.bottomLeft).distance <= handleHitRadius) {
      return _ActiveHandle.bottomLeft;
    }
    if ((pos - rect.bottomRight).distance <= handleHitRadius) {
      return _ActiveHandle.bottomRight;
    }

    if ((pos.dy - rect.top).abs() <= handleHitRadius &&
        pos.dx >= rect.left &&
        pos.dx <= rect.right) {
      return _ActiveHandle.top;
    }
    if ((pos.dy - rect.bottom).abs() <= handleHitRadius &&
        pos.dx >= rect.left &&
        pos.dx <= rect.right) {
      return _ActiveHandle.bottom;
    }
    if ((pos.dx - rect.left).abs() <= handleHitRadius &&
        pos.dy >= rect.top &&
        pos.dy <= rect.bottom) {
      return _ActiveHandle.left;
    }
    if ((pos.dx - rect.right).abs() <= handleHitRadius &&
        pos.dy >= rect.top &&
        pos.dy <= rect.bottom) {
      return _ActiveHandle.right;
    }

    if (rect.contains(pos)) {
      return _ActiveHandle.inside;
    }

    return _ActiveHandle.none;
  }

  void _updateCropRect(double dx, double dy) {
    const minSize = 0.06;
    double l = _cropRect.left;
    double t = _cropRect.top;
    double r = _cropRect.right;
    double b = _cropRect.bottom;

    switch (_activeHandle) {
      case _ActiveHandle.topLeft:
        l = (l + dx).clamp(0.0, r - minSize);
        t = (t + dy).clamp(0.0, b - minSize);
      case _ActiveHandle.topRight:
        r = (r + dx).clamp(l + minSize, 1.0);
        t = (t + dy).clamp(0.0, b - minSize);
      case _ActiveHandle.bottomLeft:
        l = (l + dx).clamp(0.0, r - minSize);
        b = (b + dy).clamp(t + minSize, 1.0);
      case _ActiveHandle.bottomRight:
        r = (r + dx).clamp(l + minSize, 1.0);
        b = (b + dy).clamp(t + minSize, 1.0);
      case _ActiveHandle.top:
        t = (t + dy).clamp(0.0, b - minSize);
      case _ActiveHandle.bottom:
        b = (b + dy).clamp(t + minSize, 1.0);
      case _ActiveHandle.left:
        l = (l + dx).clamp(0.0, r - minSize);
      case _ActiveHandle.right:
        r = (r + dx).clamp(l + minSize, 1.0);
      case _ActiveHandle.inside:
        final w = r - l;
        final h = b - t;
        l = (l + dx).clamp(0.0, 1.0 - w);
        t = (t + dy).clamp(0.0, 1.0 - h);
        r = l + w;
        b = t + h;
      case _ActiveHandle.none:
        break;
    }

    _cropRect = Rect.fromLTRB(l, t, r, b);
  }

  Widget _buildBottomBar(ThemeData theme) {
    final l10n = context.l10n;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: const Color(0xFF141416),
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        isLandscape ? 8 : (bottomPadding + 10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmented Tab Selector (Crop & Rotate, Filters, Fine Tune)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabPill(
                label: l10n.ocrTabCrop,
                icon: Icons.crop_rotate,
                isActive: _activeTab == _EditorTab.crop,
                onTap: () => setState(() => _activeTab = _EditorTab.crop),
              ),
              const SizedBox(width: 8),
              _buildTabPill(
                label: l10n.ocrTabFilters,
                icon: Icons.auto_fix_high,
                isActive: _activeTab == _EditorTab.filters,
                onTap: () => setState(() => _activeTab = _EditorTab.filters),
              ),
              const SizedBox(width: 8),
              _buildTabPill(
                label: l10n.ocrTabTune,
                icon: Icons.tune,
                isActive: _activeTab == _EditorTab.tune,
                onTap: () => setState(() => _activeTab = _EditorTab.tune),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Active Tab Panel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (_activeTab) {
              _EditorTab.crop => _buildCropRotatePanel(l10n),
              _EditorTab.filters => _buildFiltersPanel(l10n),
              _EditorTab.tune => _buildTunePanel(l10n),
            },
          ),
          const SizedBox(height: 12),

          // Primary Scan Action Bar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (_isLoading || _isCropping) ? null : _useFullImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.ocrCropFullImage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: isLandscape ? 1 : 2,
                child: FilledButton.icon(
                  onPressed: (_isLoading || _isCropping) ? null : _confirmCrop,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: AppTheme.defaultLightAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isCropping
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.document_scanner, size: 20),
                  label: Text(
                    l10n.ocrCropConfirm,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.defaultLightAccent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppTheme.defaultLightAccent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppTheme.defaultLightAccent : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropRotatePanel(dynamic l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rotate Left (CCW)
          OutlinedButton.icon(
            onPressed:
                (_isLoading || _isCropping) ? null : _rotateCounterClockwise,
            icon: const Icon(Icons.rotate_left, size: 18),
            label: Text(l10n.ocrRotateCcw),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),

          // Rotate Right (CW)
          OutlinedButton.icon(
            onPressed: (_isLoading || _isCropping) ? null : _rotateClockwise,
            icon: const Icon(Icons.rotate_right, size: 18),
            label: Text(l10n.ocrRotateCw),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),

          // Reset Crop
          OutlinedButton.icon(
            onPressed: (_isLoading || _isCropping) ? null : _resetCrop,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(l10n.ocrResetFilter),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel(dynamic l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip(
            label: l10n.ocrFilterOriginal,
            icon: Icons.image_outlined,
            isSelected: _filterMode == OcrFilterMode.original,
            onTap: () => setState(() => _filterMode = OcrFilterMode.original),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.ocrFilterBw,
            icon: Icons.contrast,
            isSelected: _filterMode == OcrFilterMode.documentBw,
            onTap: () => setState(() => _filterMode = OcrFilterMode.documentBw),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.ocrFilterGrayscale,
            icon: Icons.filter_b_and_w,
            isSelected: _filterMode == OcrFilterMode.grayscale,
            onTap: () => setState(() => _filterMode = OcrFilterMode.grayscale),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.ocrFilterBrighten,
            icon: Icons.brightness_6_outlined,
            isSelected: _filterMode == OcrFilterMode.brighten,
            onTap: () => setState(() => _filterMode = OcrFilterMode.brighten),
          ),
        ],
      ),
    );
  }

  Widget _buildTunePanel(dynamic l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brightness Slider
        Row(
          children: [
            const Icon(Icons.brightness_medium, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: Text(
                l10n.ocrBrightnessLabel,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  activeTrackColor: AppTheme.defaultLightAccent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _brightness,
                  min: -50.0,
                  max: 50.0,
                  onChanged: (v) => setState(() => _brightness = v),
                ),
              ),
            ),
            Text(
              '${_brightness.round()}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),

        // Contrast Slider
        Row(
          children: [
            const Icon(Icons.contrast, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: Text(
                l10n.ocrContrastLabel,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  activeTrackColor: AppTheme.defaultLightAccent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _contrast,
                  min: 0.5,
                  max: 2.5,
                  onChanged: (v) => setState(() => _contrast = v),
                ),
              ),
            ),
            Text(
              _contrast.toStringAsFixed(1),
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.defaultLightAccent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.defaultLightAccent : Colors.white24,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.defaultLightAccent : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({
    required this.imageRect,
    required this.cropRect,
    required this.accentColor,
  });

  final Rect imageRect;
  final Rect cropRect;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Darken everything outside image + outside crop rect
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cropPath = Path()..addRect(cropRect);
    final maskPath = Path.combine(PathOperation.difference, bgPath, cropPath);

    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, maskPaint);

    // 2. Crop border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(cropRect, borderPaint);

    // 3. Rule of thirds guide lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final thirdW = cropRect.width / 3;
    final thirdH = cropRect.height / 3;

    canvas.drawLine(
      Offset(cropRect.left + thirdW, cropRect.top),
      Offset(cropRect.left + thirdW, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + 2 * thirdW, cropRect.top),
      Offset(cropRect.left + 2 * thirdW, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdH),
      Offset(cropRect.right, cropRect.top + thirdH),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + 2 * thirdH),
      Offset(cropRect.right, cropRect.top + 2 * thirdH),
      gridPaint,
    );

    // 4. Heavy corner handles
    final handlePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLength = 22.0;

    // TL
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft + const Offset(cornerLength, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft + const Offset(0, cornerLength),
      handlePaint,
    );
    // TR
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight - const Offset(cornerLength, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight + const Offset(0, cornerLength),
      handlePaint,
    );
    // BL
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft + const Offset(cornerLength, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft - const Offset(0, cornerLength),
      handlePaint,
    );
    // BR
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight - const Offset(cornerLength, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight - const Offset(0, cornerLength),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect ||
      oldDelegate.imageRect != imageRect ||
      oldDelegate.accentColor != accentColor;
}
