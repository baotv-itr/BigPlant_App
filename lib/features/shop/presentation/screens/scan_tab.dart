import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../scan/domain/scan_service.dart';
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

  Future<void> _pickAndScan(ImageSource source) async {
    if (_loading) return;

    final file = await _imagePicker.pickImage(
      source: source,
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
          builder: (_) => ScanResultScreen(imageBytes: bytes, result: result),
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
        children: [
          Text(
            t.t('scan_title'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.blackLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.t('scan_subtitle'),
            style: const TextStyle(color: AppColors.darkGrey),
          ),
          const SizedBox(height: 18),
          _scanCard(context, t),
          const SizedBox(height: 16),
          _tipsCard(context, t),
        ],
      ),
    );
  }

  Widget _scanCard(BuildContext context, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FAF5), Color(0xFFF9FDFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: _previewBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.document_scanner_rounded,
                        size: 46,
                        color: AppColors.leafGreen,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.t('scan_empty_state'),
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(_previewBytes!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : () => _pickAndScan(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.leafGreen),
                    foregroundColor: AppColors.leafGreenDark,
                    minimumSize: const Size(0, 48),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(t.t('scan_camera')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : () => _pickAndScan(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.leafGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(0, 48),
                  ),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(t.t('scan_gallery')),
                ),
              ),
            ],
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                minHeight: 5,
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: AppColors.leafGreen,
                backgroundColor: AppColors.leafMint,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tipsCard(BuildContext context, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('scan_tips_title'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('• ${t.t('scan_tip_1')}', style: const TextStyle(height: 1.35)),
          Text('• ${t.t('scan_tip_2')}', style: const TextStyle(height: 1.35)),
          Text('• ${t.t('scan_tip_3')}', style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}
