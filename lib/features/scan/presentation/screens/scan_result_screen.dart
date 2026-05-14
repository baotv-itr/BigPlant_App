import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/scan_service.dart';
import '../../domain/models/plant_scan_result.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({
    required this.imageBytes,
    required this.result,
    this.fetchDetailsFromApi = false,
    this.detailFetchFileName = 'camera_scan.jpg',
    this.inferenceFramework,
    super.key,
  });

  final Uint8List imageBytes;
  final PlantScanResult result;
  final bool fetchDetailsFromApi;
  final String detailFetchFileName;
  final String? inferenceFramework;

  static String valueOrPlaceholder(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final FlutterTts _tts = FlutterTts();
  final ScanService _scanService = ScanService();

  bool _isSpeaking = false;
  bool _ttsReady = false;
  bool _fetchingDetails = false;
  String? _fetchError;
  PlantScanResult? _fetchedDetails;

  @override
  void initState() {
    super.initState();
    _initTts();
    if (widget.fetchDetailsFromApi) {
      _fetchDetailsFromApi();
    }
  }

  PlantScanResult get _contentResult => _fetchedDetails ?? widget.result;

  String get _frameworkLabel {
    final explicit = widget.inferenceFramework?.trim() ?? '';
    if (explicit.isNotEmpty) return explicit;
    return widget.fetchDetailsFromApi ? 'Onnx Runtime' : 'TensorRT';
  }

  Future<void> _fetchDetailsFromApi() async {
    setState(() {
      _fetchingDetails = true;
      _fetchError = null;
    });
    try {
      final apiResult = await _scanService.scanPlant(
        imageBytes: widget.imageBytes,
        fileName: widget.detailFetchFileName,
      );
      if (!mounted) return;
      setState(() {
        _fetchedDetails = apiResult;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchingDetails = false;
        });
      }
    }
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
    final content = _contentResult;
    final identityRows = <MapEntry<String, String>>[
      MapEntry(t.t('field_common_name'), content.displayName),
      MapEntry(t.t('field_scientific_name'), content.scientificName),
      MapEntry(t.t('field_family'), content.family),
      MapEntry(t.t('field_order'), content.order),
      MapEntry(t.t('field_genus'), content.genus),
      MapEntry(t.t('field_species'), content.species),
    ];
    final profileRows = _detailRows([
      MapEntry(t.t('field_aliases'), content.aliases),
      MapEntry(t.t('field_habitat'), content.habitat),
      MapEntry(t.t('field_morphology'), content.morphology),
      MapEntry(t.t('field_characteristics'), content.characteristics),
    ]);
    final careRows = _detailRows([
      MapEntry(t.t('field_light'), content.lightRequirement),
      MapEntry(t.t('field_water'), content.waterRequirement),
      MapEntry(t.t('field_soil'), content.soilPreference),
      MapEntry(t.t('field_toxicity'), content.toxicity),
      MapEntry(t.t('field_growth_habit'), content.growthHabit),
      MapEntry(t.t('field_seasonality'), content.seasonality),
      MapEntry(t.t('field_source_quality'), content.sourceQuality),
    ]);
    final overviewTags = _buildOverviewTags(context, t, content);

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
          _imageHeader(context, t, content),
          const SizedBox(height: 14),
          if (_fetchingDetails)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(
                minHeight: 4,
                borderRadius: BorderRadius.circular(99),
                color: AppColors.leafGreen,
                backgroundColor: AppColors.leafMint,
              ),
            ),
          if (_fetchError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD8A8)),
                ),
                child: Text(
                  _fetchError!,
                    style: const TextStyle(color: Color(0xFF8A4B00)),
                  ),
                ),
              ),
          if (overviewTags.isNotEmpty) ...[
            _sectionCard(
              title: t.t('scan_result_overview'),
              child: Wrap(spacing: 8, runSpacing: 8, children: overviewTags),
            ),
            const SizedBox(height: 12),
          ],
          _sectionCard(
            title: t.t('plant_identity'),
            child: Column(
              children: identityRows
                  .map((row) => _InfoRow(label: row.key, value: row.value))
                  .toList(),
            ),
          ),
          if (profileRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionCard(
              title: t.t('plant_profile'),
              child: Column(
                children: profileRows
                    .map((row) => _InfoRow(label: row.key, value: row.value))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_description'),
            child: _buildNarrativeText(content.description),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_uses'),
            child: _buildNarrativeText(content.uses),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_advantages'),
            child: _buildNarrativeText(content.advantages),
          ),
          if (careRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionCard(
              title: t.t('care_requirements'),
              child: Column(
                children: careRows
                    .map((row) => _InfoRow(label: row.key, value: row.value))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildDistributionSection(context, t, content),
          const SizedBox(height: 12),
          _sectionCard(
            title: t.t('field_note'),
            child: SelectableText(
              ScanResultScreen.valueOrPlaceholder(content.note),
              style: const TextStyle(height: 1.45, color: AppColors.darkGrey),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleRead(context),
        backgroundColor: AppColors.leafGreen,
        foregroundColor: AppColors.white,
        child: Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
      ),
    );
  }

  List<MapEntry<String, String>> _detailRows(List<MapEntry<String, String>> rows) {
    return rows.where((row) => row.value.trim().isNotEmpty).toList();
  }

  List<Widget> _buildOverviewTags(
    BuildContext context,
    AppLocalizations t,
    PlantScanResult content,
  ) {
    final tags = <Widget>[];

    void addTag(String label) {
      final text = label.trim();
      if (text.isEmpty) return;
      tags.add(_buildOverviewTagChip(context, text));
    }

    addTag(content.scientificName);
    if (content.family.trim().isNotEmpty) {
      addTag('${t.t('field_family')}: ${content.family}');
    }
    if (content.genus.trim().isNotEmpty) {
      addTag('${t.t('field_genus')}: ${content.genus}');
    }
    if (content.growthHabit.trim().isNotEmpty) {
      addTag('${t.t('field_growth_habit')}: ${content.growthHabit}');
    }
    if (content.sourceQuality.trim().isNotEmpty) {
      addTag('${t.t('field_source_quality')}: ${content.sourceQuality}');
    }
    if (content.distributionPoints.isNotEmpty) {
      addTag(
        '${t.t('distribution_points')}: ${content.distributionPoints.length}',
      );
    }
    if (content.distributionAreas.isNotEmpty) {
      addTag(
        '${t.t('distribution_regions')}: ${content.distributionAreas.length}',
      );
    }

    return tags;
  }

  Widget _buildOverviewTagChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.leafGreenSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.leafGreenDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildNarrativeText(String value) {
    return Text(
      ScanResultScreen.valueOrPlaceholder(value),
      style: const TextStyle(height: 1.55, color: AppColors.blackLight),
    );
  }

  Widget _buildDistributionSection(
    BuildContext context,
    AppLocalizations t,
    PlantScanResult content,
  ) {
    final hasMap = content.distributionPoints.isNotEmpty;
    final hasDistributionDetails =
        hasMap || content.distributionAreas.isNotEmpty;
    final distributionItemCount = hasMap
        ? content.distributionPoints.length
        : content.distributionAreas.length;

    return _sectionCard(
      title: t.t('distribution_map'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDistributionDetails)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildOverviewTagChip(
                    context,
                    hasMap
                        ? '${t.t('distribution_points')}: ${content.distributionPoints.length}'
                        : '${t.t('distribution_regions')}: ${content.distributionAreas.length}',
                  ),
                  if (content.distributionAreas.isNotEmpty)
                    _buildOverviewTagChip(
                      context,
                      '${t.t('distribution_regions')}: ${content.distributionAreas.length}',
                    ),
                ],
              ),
            ),
          if (hasMap)
            SizedBox(
              height: 230,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    _buildDistributionMap(
                      points: content.distributionPoints,
                      initialZoom: 2.8,
                      onTap: () => _openExpandedMap(context),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.t('distribution_sheet_summary'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: AppColors.blackLight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$distributionItemCount ${t.t('distribution_location').toLowerCase()}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.darkGrey),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => _openExpandedMap(context),
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.open_in_full_rounded,
                                    color: AppColors.blackLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    t.t('distribution_not_available'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.darkGrey),
                  ),
                ),
              ),
            ),
          if (hasDistributionDetails) ...[
            const SizedBox(height: 10),
            if (hasMap)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openExpandedMap(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.leafGreenDark,
                    side: const BorderSide(color: AppColors.cardBorder),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: Text(t.t('distribution_view_map')),
                ),
              ),
            if (hasMap) const SizedBox(height: 10),
            _buildDetailAction(
              context: context,
              label: t.t('distribution_view_details'),
              count: distributionItemCount,
              onTap: () => _showDistributionDetails(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailAction({
    required BuildContext context,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.leafGreenSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.leafMint),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.list_alt_rounded,
                size: 20,
                color: AppColors.leafGreenDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.leafGreenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.leafGreenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: AppColors.leafGreenDark,
              ),
            ],
          ),
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

    final content = _contentResult;
    addLine(t.t('field_common_name'), content.displayName);
    addLine(t.t('field_scientific_name'), content.scientificName);
    addLine(t.t('field_family'), content.family);
    addLine(t.t('field_order'), content.order);
    addLine(t.t('field_genus'), content.genus);
    addLine(t.t('field_species'), content.species);
    addLine(t.t('field_description'), content.description);
    addLine(t.t('field_uses'), content.uses);
    addLine(t.t('field_advantages'), content.advantages);

    if (content.distributionAreas.isNotEmpty) {
      addLine(
        t.t('distribution_map'),
        content.distributionAreas.join(', '),
      );
    }

    return lines.join(' ');
  }

  Widget _imageHeader(
    BuildContext context,
    AppLocalizations t,
    PlantScanResult content,
  ) {
    final confidence = content.confidence;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(
                  widget.imageBytes,
                  width: 108,
                  height: 108,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.leafGreenSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${t.t('scan_framework_badge')}: $_frameworkLabel',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.leafGreenDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_fetchingDetails)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              t.t('scan_fast_analysis'),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ScanResultScreen.valueOrPlaceholder(content.displayName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.blackLight,
                        fontSize: 26,
                      ),
                    ),
                    if (content.scientificName.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        content.scientificName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      confidence == null
                          ? t.t('confidence_unknown')
                          : '${t.t('confidence')}: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.blackLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: confidence == null
                            ? 0.18
                            : confidence.clamp(0.0, 1.0).toDouble(),
                        minHeight: 7,
                        color: AppColors.leafGreen,
                        backgroundColor: AppColors.leafMint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.blackLight,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDistributionMap({
    required List<PlantDistributionPoint> points,
    required double initialZoom,
    VoidCallback? onTap,
  }) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _centerPoint(points),
        initialZoom: initialZoom,
        onTap: onTap == null ? null : (_, _) => onTap(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bigplant.app',
        ),
        MarkerLayer(
          markers: points
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
    );
  }

  Future<void> _openExpandedMap(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final content = _contentResult;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenDistributionMapScreen(
          title: t.t('distribution_map'),
          points: content.distributionPoints,
          areas: content.distributionAreas,
          onOpenDetails: _showDistributionDetails,
        ),
      ),
    );
  }

  Future<void> _showDistributionDetails(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final content = _contentResult;
    final pointItems = content.distributionPoints;
    final areaItems = content.distributionAreas;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var showingPoints = pointItems.isNotEmpty;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final showingList = showingPoints ? pointItems : areaItems;
            final currentCount = showingList.length;

            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SizedBox(
                  height: MediaQuery.of(sheetContext).size.height * 0.74,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.t('distribution_detail_title'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blackLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.t('distribution_sheet_summary'),
                                    style: const TextStyle(
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.leafGreenSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$currentCount',
                                style: const TextStyle(
                                  color: AppColors.leafGreenDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        if (pointItems.isNotEmpty && areaItems.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: Text(t.t('distribution_points')),
                                selected: showingPoints,
                                onSelected: (_) => setSheetState(() {
                                  showingPoints = true;
                                }),
                              ),
                              ChoiceChip(
                                label: Text(t.t('distribution_regions')),
                                selected: !showingPoints,
                                onSelected: (_) => setSheetState(() {
                                  showingPoints = false;
                                }),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        Expanded(
                          child: ListView.separated(
                            itemCount: showingList.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (_, index) {
                              if (showingPoints) {
                                final point = pointItems[index];
                                final title = point.label.trim().isEmpty
                                    ? '${t.t('distribution_location')} ${index + 1}'
                                    : point.label;
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppColors.leafGreenSoft,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.place_rounded,
                                          color: AppColors.leafGreenDark,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                color: AppColors.blackLight,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${point.lat.toStringAsFixed(4)}, ${point.lng.toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                color: AppColors.darkGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final area = areaItems[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.leafGreenSoft,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.location_city_rounded,
                                        color: AppColors.leafGreenDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        area,
                                        style: const TextStyle(
                                          color: AppColors.blackLight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  LatLng _centerPoint(List<PlantDistributionPoint> points) {
    if (points.isEmpty) return const LatLng(16.0471, 108.2068);
    final latAvg =
        points.fold<double>(0, (sum, item) => sum + item.lat) / points.length;
    final lngAvg =
        points.fold<double>(0, (sum, item) => sum + item.lng) / points.length;
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.leafGreenDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ScanResultScreen.valueOrPlaceholder(value),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.blackLight,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenDistributionMapScreen extends StatefulWidget {
  const _FullscreenDistributionMapScreen({
    required this.title,
    required this.points,
    required this.areas,
    required this.onOpenDetails,
  });

  final String title;
  final List<PlantDistributionPoint> points;
  final List<String> areas;
  final Future<void> Function(BuildContext context) onOpenDetails;

  @override
  State<_FullscreenDistributionMapScreen> createState() =>
      _FullscreenDistributionMapScreenState();
}

class _FullscreenDistributionMapScreenState
    extends State<_FullscreenDistributionMapScreen> {
  final MapController _mapController = MapController();

  LatLng get _center {
    if (widget.points.isEmpty) return const LatLng(16.0471, 108.2068);
    final latAvg = widget.points.fold<double>(
          0,
          (sum, item) => sum + item.lat,
        ) /
        widget.points.length;
    final lngAvg = widget.points.fold<double>(
          0,
          (sum, item) => sum + item.lng,
        ) /
        widget.points.length;
    return LatLng(latAvg, lngAvg);
  }

  void _recenter() {
    _mapController.move(_center, widget.points.isEmpty ? 2.8 : 4.0);
  }

  void _locateFirstPoint() {
    if (widget.points.isEmpty) {
      _recenter();
      return;
    }
    final first = widget.points.first;
    _mapController.move(LatLng(first.lat, first.lng), 5.2);
  }

  void _showLayersHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map layers follow the configured Flutter map source.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locationCount = widget.points.isNotEmpty
        ? widget.points.length
        : widget.areas.length;

    return Scaffold(
      backgroundColor: AppColors.blackLight,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _center, initialZoom: 4.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bigplant.app',
                ),
                MarkerLayer(
                  markers: widget.points
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
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: AppColors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.blackLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: AppColors.blackLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leafGreenSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$locationCount',
                                  style: const TextStyle(
                                    color: AppColors.leafGreenDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MapActionButton(
                          icon: Icons.layers_outlined,
                          label: t.t('distribution_layers'),
                          onTap: () => _showLayersHint(context),
                        ),
                        const SizedBox(height: 10),
                        _MapActionButton(
                          icon: Icons.tune_rounded,
                          label: t.t('distribution_filter'),
                          onTap: () => widget.onOpenDetails(context),
                        ),
                        const SizedBox(height: 10),
                        _MapActionButton(
                          icon: Icons.center_focus_strong_rounded,
                          label: t.t('distribution_recenter'),
                          onTap: _recenter,
                        ),
                        const SizedBox(height: 10),
                        _MapActionButton(
                          icon: Icons.my_location_rounded,
                          label: t.t('distribution_locate'),
                          onTap: _locateFirstPoint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.t('distribution_sheet_summary'),
                          style: const TextStyle(
                            color: AppColors.blackLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MapSummaryPill(
                              label:
                                  '${t.t('distribution_points')}: ${widget.points.length}',
                            ),
                            _MapSummaryPill(
                              label:
                                  '${t.t('distribution_regions')}: ${widget.areas.length}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onOpenDetails(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.leafGreen,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.list_alt_rounded),
                            label: Text(t.t('distribution_view_details')),
                          ),
                        ),
                      ],
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

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.blackLight),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.blackLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapSummaryPill extends StatelessWidget {
  const _MapSummaryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.leafGreenSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.leafGreenDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
