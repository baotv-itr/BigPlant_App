import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/plant_scan_result.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({
    required this.imageBytes,
    required this.result,
    super.key,
  });

  final Uint8List imageBytes;
  final PlantScanResult result;

  static String valueOrPlaceholder(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      _ttsReady = true;
    } on MissingPluginException {
      _ttsReady = false;
    } on PlatformException {
      _ttsReady = false;
    }

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    _tts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasMap = widget.result.distributionPoints.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      appBar: AppBar(
        title: Text(t.t('scan_result_title')),
        backgroundColor: AppColors.leafGreen,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _imageHeader(context, t),
          const SizedBox(height: 14),
          _sectionCard(
            title: t.t('plant_identity'),
            child: Column(
              children: [
                _InfoRow(label: t.t('field_common_name'), value: widget.result.displayName),
                _InfoRow(
                  label: t.t('field_scientific_name'),
                  value: widget.result.scientificName,
                ),
                _InfoRow(label: t.t('field_family'), value: widget.result.family),
                _InfoRow(label: t.t('field_order'), value: widget.result.order),
                _InfoRow(label: t.t('field_genus'), value: widget.result.genus),
                _InfoRow(label: t.t('field_species'), value: widget.result.species),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_description'),
            child: Text(
              ScanResultScreen.valueOrPlaceholder(widget.result.description),
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_uses'),
            child: Text(
              ScanResultScreen.valueOrPlaceholder(widget.result.uses),
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_advantages'),
            child: Text(
              ScanResultScreen.valueOrPlaceholder(widget.result.advantages),
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('distribution_map'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.result.distributionAreas.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.result.distributionAreas
                        .map(
                          (area) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.leafGreenSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(area),
                          ),
                        )
                        .toList(),
                  ),
                if (widget.result.distributionAreas.isNotEmpty) const SizedBox(height: 10),
                if (hasMap)
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _centerPoint(widget.result.distributionPoints),
                          initialZoom: 2.8,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.bigplant.app',
                          ),
                          MarkerLayer(
                            markers: widget.result.distributionPoints
                                .map(
                                  (point) => Marker(
                                    point: LatLng(point.lat, point.lng),
                                    width: 38,
                                    height: 38,
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.leafGreenDark,
                                      size: 32,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBF9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Text(
                        t.t('distribution_not_available'),
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_note'),
            child: Text(
              ScanResultScreen.valueOrPlaceholder(widget.result.note),
              style: const TextStyle(height: 1.35, color: AppColors.darkGrey),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleRead(context),
        backgroundColor: AppColors.leafGreen,
        foregroundColor: AppColors.white,
        child: Icon(
          _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
        ),
      ),
    );
  }

  Future<void> _toggleRead(BuildContext context) async {
    if (!_ttsReady) {
      _showTtsUnavailable(context);
      return;
    }

    if (_isSpeaking) {
      await _tts.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      return;
    }

    final text = _buildReadText(context);
    if (text.isEmpty) return;

    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode.toLowerCase();
    try {
      await _tts.setLanguage(languageCode == 'vi' ? 'vi-VN' : 'en-US');
    } on MissingPluginException {
      if (!context.mounted) return;
      _ttsReady = false;
      _showTtsUnavailable(context);
      return;
    } on PlatformException {
      if (!context.mounted) return;
      _showTtsUnavailable(context);
      return;
    }

    int speakResult;
    try {
      speakResult = await _tts.speak(text);
    } on MissingPluginException {
      if (!context.mounted) return;
      _ttsReady = false;
      _showTtsUnavailable(context);
      return;
    } on PlatformException {
      if (!context.mounted) return;
      _showTtsUnavailable(context);
      return;
    }

    if (!mounted) return;
    if (speakResult == 1) {
      setState(() => _isSpeaking = true);
    }
  }

  void _showTtsUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text-to-speech is unavailable. Please restart the app.'),
      ),
    );
  }

  String _buildReadText(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lines = <String>[];

    void addLine(String label, String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      lines.add('$label: $trimmed.');
    }

    addLine(t.t('field_common_name'), widget.result.displayName);
    addLine(t.t('field_scientific_name'), widget.result.scientificName);
    addLine(t.t('field_family'), widget.result.family);
    addLine(t.t('field_order'), widget.result.order);
    addLine(t.t('field_genus'), widget.result.genus);
    addLine(t.t('field_species'), widget.result.species);
    addLine(t.t('field_description'), widget.result.description);
    addLine(t.t('field_uses'), widget.result.uses);
    addLine(t.t('field_advantages'), widget.result.advantages);

    if (widget.result.distributionAreas.isNotEmpty) {
      addLine(
        t.t('distribution_map'),
        widget.result.distributionAreas.join(', '),
      );
    }

    return lines.join(' ');
  }

  Widget _imageHeader(BuildContext context, AppLocalizations t) {
    final confidence = widget.result.confidence;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              widget.imageBytes,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ScanResultScreen.valueOrPlaceholder(widget.result.displayName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ScanResultScreen.valueOrPlaceholder(widget.result.scientificName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.leafGreenSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    confidence == null
                        ? t.t('confidence_unknown')
                        : '${t.t('confidence')}: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppColors.leafGreenDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.blackLight,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  LatLng _centerPoint(List<PlantDistributionPoint> points) {
    if (points.isEmpty) return const LatLng(16.0471, 108.2068);
    final latAvg = points.fold<double>(0, (sum, item) => sum + item.lat) / points.length;
    final lngAvg = points.fold<double>(0, (sum, item) => sum + item.lng) / points.length;
    return LatLng(latAvg, lngAvg);
  }

}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ScanResultScreen.valueOrPlaceholder(value),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
