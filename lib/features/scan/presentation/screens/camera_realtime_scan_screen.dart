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
      appBar: AppBar(
        title: Text(t.t('scan_camera_realtime_title')),
        backgroundColor: AppColors.leafGreen,
        foregroundColor: AppColors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
              : _buildBody(t),
    );
  }

  Widget _buildBody(AppLocalizations t) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Center(child: Text(t.t('scan_camera_init_failed')));
    }

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(controller)),
        Positioned(
          left: 12,
          right: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('scan_local_mode_badge'),
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_modelIds.isNotEmpty)
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedModelId,
                      dropdownColor: const Color(0xFF2E3A31),
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
              ],
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 18,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _latestResult == null
                      ? t.t('scan_realtime_waiting')
                      : '${_latestResult!.label} ${(100 * _latestResult!.confidence).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Model: ${_selectedModelId ?? '-'} | Format: $_lastFrameFormat | Infer: ${_lastInferLatencyMs}ms',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (_lastInferError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _lastInferError!,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _latestResult == null ? null : _openLocalResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leafGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(t.t('scan_open_result')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
