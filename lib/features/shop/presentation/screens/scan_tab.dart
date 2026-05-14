import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../scan/domain/scan_service.dart';
import '../../../scan/presentation/screens/camera_realtime_scan_screen.dart';
import '../../../scan/presentation/screens/scan_result_screen.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final ImagePicker _imagePicker = ImagePicker();
  final ScanService _scanService = ScanService();

  Uint8List? _previewBytes;
  bool _loading = false;

  Future<void> _pickAndScanFromGallery() async {
    if (_loading) return;

    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (file == null) return;

    setState(() => _loading = true);

    try {
      final bytes = await file.readAsBytes();
      setState(() => _previewBytes = bytes);

      final result = await _scanService.scanPlant(
        imageBytes: bytes,
        fileName: file.name.isEmpty ? 'plant_scan.jpg' : file.name,
      );
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            imageBytes: bytes,
            result: result,
            inferenceFramework: 'TensorRT',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openRealtimeCamera() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraRealtimeScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF2FBF6), Color(0xFFF9FCFA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          children: [
            Text(
              t.t('scan_title'),
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.blackLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.t('scan_subtitle'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _signalChip(
                  label: t.t('scan_fast_analysis'),
                  icon: Icons.bolt_rounded,
                ),
                _signalChip(
                  label: t.t('scan_topk_badge'),
                  icon: Icons.analytics_rounded,
                ),
                _signalChip(
                  label: t.t('scan_natural_light_badge'),
                  icon: Icons.wb_sunny_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _scanCard(context, t),
            const SizedBox(height: 16),
            _tipsCard(context, t),
          ],
        ),
      ),
    );
  }

  Widget _scanCard(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 256,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFF1FBF5), Color(0xFFF7FBF9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_previewBytes != null)
                    Image.memory(_previewBytes!, fit: BoxFit.cover)
                  else
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.center_focus_strong_rounded,
                              size: 34,
                              color: AppColors.leafGreen,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            t.t('scan_preview_title'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 22,
                              color: AppColors.blackLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.t('scan_preview_subtitle'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: AppColors.leafGreenDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _previewBytes == null
                                    ? t.t('scan_fast_analysis')
                                    : t.t('scan_latest_capture'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.leafGreenDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _previewBytes == null
                            ? t.t('scan_empty_state')
                            : t.t('scan_preview_subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _featurePill(
                context,
                icon: Icons.speed_rounded,
                label: t.t('scan_fast_analysis'),
              ),
              _featurePill(
                context,
                icon: Icons.track_changes_rounded,
                label: t.t('scan_topk_badge'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _openRealtimeCamera,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.leafGreen),
                    foregroundColor: AppColors.leafGreenDark,
                    minimumSize: const Size(0, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(t.t('scan_camera')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _pickAndScanFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.leafGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(0, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(t.t('scan_gallery')),
                ),
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.t('scan_scanning_progress_title'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.blackLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      minHeight: 6,
                      color: AppColors.leafGreen,
                      backgroundColor: AppColors.leafMint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.t('scan_scanning_progress_body'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tipsCard(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.leafGreenSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppColors.leafGreenDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.t('scan_tips_title'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.leafGreenDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.t('scan_natural_light_badge'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _tipRow(context, index: 1, message: t.t('scan_tip_1')),
          const SizedBox(height: 10),
          _tipRow(context, index: 2, message: t.t('scan_tip_2')),
          const SizedBox(height: 10),
          _tipRow(context, index: 3, message: t.t('scan_tip_3')),
        ],
      ),
    );
  }

  Widget _signalChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.leafGreenDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.leafGreenDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.leafGreenSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.leafGreenDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.leafGreenDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(
    BuildContext context, {
    required int index,
    required String message,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$index',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.leafGreenDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.blackLight,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
