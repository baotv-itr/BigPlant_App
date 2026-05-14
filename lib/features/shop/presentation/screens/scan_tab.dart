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
            inferenceFramework: 'FloraEngine v1.0',
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
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, Color(0x14BEEAD1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(text: t.t('scan_intro_title_line_1')),
                  TextSpan(
                    text: '\n${t.t('scan_intro_title_line_2')}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.secondary,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _PreviewCard(
              previewBytes: _previewBytes,
              idleMessage: t.t('scan_camera_hint'),
            ),
            const SizedBox(height: 24),
            _ActionButton(
              label: t.t('scan_primary_action'),
              icon: Icons.photo_camera,
              filled: true,
              onPressed: _loading ? null : _openRealtimeCamera,
            ),
            const SizedBox(height: 16),
            _ActionButton(
              label: t.t('scan_secondary_action'),
              icon: Icons.photo_library,
              filled: false,
              onPressed: _loading ? null : _pickAndScanFromGallery,
            ),
            if (_loading) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryFixed,
                ),
              ),
            ],
            const SizedBox(height: 40),
            _TipsCard(
              title: t.t('scan_tips_title'),
              items: [
                _TipItem(
                  icon: Icons.wb_sunny,
                  title: t.t('scan_tip_light_title'),
                  body: t.t('scan_tip_light_body'),
                ),
                _TipItem(
                  icon: Icons.filter_center_focus,
                  title: t.t('scan_tip_focus_title'),
                  body: t.t('scan_tip_focus_body'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.previewBytes, required this.idleMessage});

  final Uint8List? previewBytes;
  final String idleMessage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (previewBytes != null)
                Image.memory(previewBytes!, fit: BoxFit.cover)
              else ...[
                Positioned(
                  top: -48,
                  right: -48,
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: const BoxDecoration(
                      color: Color(0x4DB1F0CE),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -64,
                  bottom: -64,
                  child: Container(
                    width: 224,
                    height: 224,
                    decoration: const BoxDecoration(
                      color: Color(0x40BEEAD1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                _ViewfinderFrame(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.energy_savings_leaf,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          idleMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 4,
                  color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.33,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryFixed, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewfinderFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CornerMarker(top: true, left: true),
                _CornerMarker(top: true, left: false),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CornerMarker(top: false, left: true),
                _CornerMarker(top: false, left: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerMarker extends StatelessWidget {
  const _CornerMarker({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(12) : Radius.zero,
          topRight: top && !left ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(12) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(12) : Radius.zero,
        ),
        border: Border(
          top: top ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          left: left ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          right: !left ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          bottom: !top ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size.fromHeight(56),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: AppColors.primary.withValues(alpha: 0.15),
          )
        : OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLowest,
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(56),
            side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Text(label),
      ],
    );

    return filled
        ? ElevatedButton(onPressed: onPressed, style: style, child: child)
        : OutlinedButton(onPressed: onPressed, style: style, child: child);
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.title, required this.items});

  final String title;
  final List<_TipItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < items.length; i++) ...[
            _TipRow(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.item});

  final _TipItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipItem {
  const _TipItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
