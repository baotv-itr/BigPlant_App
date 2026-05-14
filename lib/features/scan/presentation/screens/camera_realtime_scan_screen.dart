import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/local_onnx_scan_service.dart';
import '../../domain/models/plant_scan_result.dart';
import 'scan_result_screen.dart';

class CameraRealtimeScanScreen extends StatefulWidget {
  const CameraRealtimeScanScreen({super.key});

  @override
  State<CameraRealtimeScanScreen> createState() => _CameraRealtimeScanScreenState();
}

class _CameraRealtimeScanScreenState extends State<CameraRealtimeScanScreen> {
  final LocalOnnxScanService _localService = LocalOnnxScanService.instance;
  static const String _preferredRealtimeModelId = 'mobilenetv3large_segformer';

  CameraController? _controller;
  List<String> _modelIds = const [];
  String? _selectedModelId;

  bool _loading = true;
  bool _inferBusy = false;
  bool _isScanningEnabled = false;
  String? _error;
  LocalInferenceResult? _latestResult;
  Uint8List? _latestFrameJpeg;

  DateTime _lastInferAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _consecutiveInferFailures = 0;
  String? _lastInferError;
  String _lastFrameFormat = '-';
  int _lastInferLatencyMs = 0;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initAll() async {
    try {
      final ids = await _localService.availableRealtimeModelIds();
      final selected = await _localService.getSelectedModelId();

      final cameras = await availableCameras();
      final back = cameras.where((c) => c.lensDirection == CameraLensDirection.back).toList();
      final camera = (back.isNotEmpty ? back.first : cameras.first);

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();

      await controller.startImageStream(_onFrame);
      if (!mounted) return;

      setState(() {
        _modelIds = ids;
        _selectedModelId = _pickInitialModelId(ids, selected);
        _controller = controller;
        _loading = false;
        _isScanningEnabled = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onFrame(CameraImage cameraImage) async {
    if (!mounted || !_isScanningEnabled || _inferBusy || _selectedModelId == null) {
      return;
    }
    _lastFrameFormat = cameraImage.format.group.name;

    final now = DateTime.now();
    if (now.difference(_lastInferAt).inMilliseconds < 500) return;

    _inferBusy = true;
    _lastInferAt = now;
    final sw = Stopwatch()..start();
    try {
      final converted = _convertCameraImage(cameraImage);
      if (converted == null) {
        _setInferError(
          'Unsupported camera format: ${cameraImage.format.group.name} (planes=${cameraImage.planes.length})',
        );
        return;
      }
      _latestFrameJpeg = Uint8List.fromList(img.encodeJpg(converted, quality: 85));

      final result = await _localService.inferImage(
        converted,
        modelId: _selectedModelId,
        topK: 5,
      );
      if (!mounted) return;
      setState(() {
        _latestResult = result;
        _lastInferError = null;
        _lastInferLatencyMs = sw.elapsedMilliseconds;
      });
      _consecutiveInferFailures = 0;
    } catch (e, st) {
      debugPrint('Local realtime inference failed: $e');
      debugPrint('$st');
      _setInferError(e.toString());
      await _fallbackToPreferredModelIfNeeded();
    } finally {
      _inferBusy = false;
    }
  }

  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBgra8888(image);
    }
    if (image.format.group == ImageFormatGroup.nv21) {
      return _convertNv21(image);
    }
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYuv420(image);
    }
    return null;
  }

  img.Image _convertBgra8888(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final output = img.Image(width: width, height: height);
    final bytes = image.planes[0].bytes;
    var offset = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final b = bytes[offset];
        final g = bytes[offset + 1];
        final r = bytes[offset + 2];
        output.setPixelRgba(x, y, r, g, b, 255);
        offset += 4;
      }
    }
    return output;
  }

  img.Image _convertYuv420(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final output = img.Image(width: width, height: height);

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (var y = 0; y < height; y++) {
      final yRow = y * yRowStride;
      final uvRow = (y >> 1) * uvRowStride;

      for (var x = 0; x < width; x++) {
        final yValue = yBytes[yRow + x];
        final uvOffset = uvRow + (x >> 1) * uvPixelStride;
        final uValue = uBytes[uvOffset];
        final vValue = vBytes[uvOffset];

        final r = (yValue + 1.402 * (vValue - 128)).round();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round();
        final b = (yValue + 1.772 * (uValue - 128)).round();

        output.setPixelRgba(
          x,
          y,
          _clamp8(r),
          _clamp8(g),
          _clamp8(b),
          255,
        );
      }
    }

    return output;
  }

  img.Image? _convertNv21(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final width = image.width;
    final height = image.height;
    final yuvBytes = image.planes[0].bytes;
    final frameSize = width * height;
    if (yuvBytes.length < frameSize) return null;

    final output = img.Image(width: width, height: height);
    for (var y = 0; y < height; y++) {
      final yOffset = y * width;
      final uvRowOffset = frameSize + (y >> 1) * width;
      for (var x = 0; x < width; x++) {
        final yValue = yuvBytes[yOffset + x];
        final uvIndex = uvRowOffset + (x & ~1);
        if (uvIndex + 1 >= yuvBytes.length) continue;
        final vValue = yuvBytes[uvIndex];
        final uValue = yuvBytes[uvIndex + 1];

        final r = (yValue + 1.402 * (vValue - 128)).round();
        final g =
            (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
                .round();
        final b = (yValue + 1.772 * (uValue - 128)).round();

        output.setPixelRgba(
          x,
          y,
          _clamp8(r),
          _clamp8(g),
          _clamp8(b),
          255,
        );
      }
    }
    return output;
  }

  int _clamp8(int value) {
    return math.min(255, math.max(0, value));
  }

  String? _pickInitialModelId(List<String> ids, String selected) {
    if (ids.isEmpty) return null;
    if (ids.contains(selected)) return selected;
    if (ids.contains(_preferredRealtimeModelId)) return _preferredRealtimeModelId;
    return ids.first;
  }

  void _setInferError(String message) {
    _consecutiveInferFailures++;
    if (!mounted) return;
    setState(() {
      _lastInferError = message;
    });
  }

  Future<void> _fallbackToPreferredModelIfNeeded() async {
    if (_consecutiveInferFailures < 3) return;
    if (_selectedModelId == _preferredRealtimeModelId) return;
    if (!_modelIds.contains(_preferredRealtimeModelId)) return;

    await _localService.setSelectedModelId(_preferredRealtimeModelId);
    if (!mounted) return;
    setState(() {
      _selectedModelId = _preferredRealtimeModelId;
      _latestResult = null;
      _lastInferError =
          'Auto switched to $_preferredRealtimeModelId after repeated failures';
    });
    _consecutiveInferFailures = 0;
  }

  Future<void> _changeModel(String modelId) async {
    await _localService.setSelectedModelId(modelId);
    if (!mounted) return;
    setState(() {
      _selectedModelId = modelId;
      _latestResult = null;
    });
  }

  Future<void> _openLocalResult() async {
    final prediction = _latestResult;
    final jpeg = _latestFrameJpeg;
    if (prediction == null || jpeg == null) return;
    const detailFetchFileName = 'camera_realtime.jpg';

    _pauseScanning();

    final topkText = prediction.topPredictions
        .map(
          (item) => '${item.classIndex}: ${item.label} (${(item.confidence * 100).toStringAsFixed(1)}%)',
        )
        .join('\n');

    final result = PlantScanResult(
      displayName: prediction.label,
      scientificName: '',
      family: '',
      order: '',
      genus: '',
      species: '',
      uses: '',
      advantages: '',
      description: '',
      confidence: prediction.confidence,
      distributionAreas: const [],
      distributionPoints: const [],
      note: 'Local ONNX model: ${prediction.modelId}\nTop-5:\n$topkText',
    );

    await Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ScanResultScreen(
              imageBytes: jpeg,
              result: result,
              fetchDetailsFromApi: true,
              detailFetchFileName: detailFetchFileName,
              inferenceFramework: 'Onnx Runtime',
            ),
          ),
        )
        .whenComplete(_resumeScanning);
  }

  void _pauseScanning() {
    if (!mounted) return;
    setState(() {
      _isScanningEnabled = false;
    });
  }

  void _resumeScanning() {
    if (!mounted) return;
    setState(() {
      _isScanningEnabled = true;
      _lastInferError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.white),
                  const SizedBox(height: 16),
                  Text(
                    t.t('scan_camera_realtime_title'),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.blackLight),
                      ),
                    ),
                  ),
                )
              : _buildBody(t),
    );
  }

  Widget _buildBody(AppLocalizations t) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Text(
          t.t('scan_camera_init_failed'),
          style: const TextStyle(color: AppColors.white),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(controller)),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.42),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0, 0.35, 1],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: IgnorePointer(child: _buildGuideFrame(t))),
        _buildTopOverlay(context, t),
        _buildBottomOverlay(context, t),
      ],
    );
  }

  Widget _buildTopOverlay(BuildContext context, AppLocalizations t) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.black.withValues(alpha: 0.34),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _cameraPill(
                        icon: Icons.eco_rounded,
                        label: t.t('scan_live_analysis'),
                        accent: AppColors.leafMint,
                      ),
                      _cameraPill(
                        icon: Icons.memory_rounded,
                        label: t.t('scan_local_mode_badge'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.t('scan_local_model'),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_inferBusy)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.leafGreen.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_modelIds.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedModelId,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF213228),
                          borderRadius: BorderRadius.circular(20),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          items: _modelIds
                              .map(
                                (id) => DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(id),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            _changeModel(value);
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    t.t('scan_target_hint'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(BuildContext context, AppLocalizations t) {
    final latest = _latestResult;
    final confidence = latest?.confidence ?? 0.0;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latest == null ? t.t('scan_realtime_waiting') : latest.label,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            latest == null
                                ? t.t('scan_center_guide')
                                : t.t('scan_prediction_ready'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (latest != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.leafGreen.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${(confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: latest == null
                            ? null
                            : confidence.clamp(0.0, 1.0).toDouble(),
                        minHeight: 6,
                        color: AppColors.leafMint,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _cameraMetaChip('Model', _selectedModelId ?? '-'),
                    _cameraMetaChip('Format', _lastFrameFormat),
                    _cameraMetaChip('Infer', '${_lastInferLatencyMs}ms'),
                  ],
                ),
                if (_lastInferError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B3A00).withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _lastInferError!,
                      style: const TextStyle(
                        color: Color(0xFFFFD79A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: latest == null ? null : _openLocalResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leafGreen,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(t.t('scan_open_result')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideFrame(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 250,
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                  ),
                ),
                _guideCorner(
                  alignment: Alignment.topLeft,
                  border: const Border(
                    top: BorderSide(color: AppColors.white, width: 4),
                    left: BorderSide(color: AppColors.white, width: 4),
                  ),
                ),
                _guideCorner(
                  alignment: Alignment.topRight,
                  border: const Border(
                    top: BorderSide(color: AppColors.white, width: 4),
                    right: BorderSide(color: AppColors.white, width: 4),
                  ),
                ),
                _guideCorner(
                  alignment: Alignment.bottomLeft,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.white, width: 4),
                    left: BorderSide(color: AppColors.white, width: 4),
                  ),
                ),
                _guideCorner(
                  alignment: Alignment.bottomRight,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.white, width: 4),
                    right: BorderSide(color: AppColors.white, width: 4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              t.t('scan_center_guide'),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideCorner({required Alignment alignment, required Border border}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(border: border),
      ),
    );
  }

  Widget _cameraPill({
    required IconData icon,
    required String label,
    Color accent = AppColors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraMetaChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
