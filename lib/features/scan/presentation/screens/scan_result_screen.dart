import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/plant_scan_result.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({
    required this.imageBytes,
    required this.result,
    super.key,
  });

  final Uint8List imageBytes;
  final PlantScanResult result;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasMap = result.distributionPoints.isNotEmpty;

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
                _InfoRow(label: t.t('field_common_name'), value: result.displayName),
                _InfoRow(
                  label: t.t('field_scientific_name'),
                  value: result.scientificName,
                ),
                _InfoRow(label: t.t('field_family'), value: result.family),
                _InfoRow(label: t.t('field_order'), value: result.order),
                _InfoRow(label: t.t('field_genus'), value: result.genus),
                _InfoRow(label: t.t('field_species'), value: result.species),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_description'),
            child: Text(
              _valueOrPlaceholder(result.description),
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_uses'),
            child: Text(
              _valueOrPlaceholder(result.uses),
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_advantages'),
            child: Text(
              _valueOrPlaceholder(result.advantages),
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('distribution_map'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.distributionAreas.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result.distributionAreas
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
                if (result.distributionAreas.isNotEmpty) const SizedBox(height: 10),
                if (hasMap)
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _centerPoint(result.distributionPoints),
                          initialZoom: 2.8,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.bigplant.app',
                          ),
                          MarkerLayer(
                            markers: result.distributionPoints
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
              _valueOrPlaceholder(result.note),
              style: const TextStyle(height: 1.35, color: AppColors.darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageHeader(BuildContext context, AppLocalizations t) {
    final confidence = result.confidence;
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
              imageBytes,
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
                  _valueOrPlaceholder(result.displayName),
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
                  _valueOrPlaceholder(result.scientificName),
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

  static String _valueOrPlaceholder(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
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
              ScanResultScreen._valueOrPlaceholder(value),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
