import 'dart:convert';
import 'dart:typed_data';

import '../data/scan_api.dart';
import 'models/plant_scan_result.dart';

class ScanService {
  ScanService({ScanApi? api}) : _api = api ?? ScanApi();

  final ScanApi _api;

  Future<PlantScanResult> scanPlant({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final response = await _api.scanPlant(
      imageBytes: imageBytes,
      fileName: fileName,
    );

    final result = PlantScanResult.fromApi(response);
    if (result.note.isNotEmpty) {
      return result;
    }

    return PlantScanResult(
      displayName: result.displayName,
      scientificName: result.scientificName,
      family: result.family,
      order: result.order,
      genus: result.genus,
      species: result.species,
      uses: result.uses,
      advantages: result.advantages,
      description: result.description,
      confidence: result.confidence,
      aliases: result.aliases,
      habitat: result.habitat,
      morphology: result.morphology,
      characteristics: result.characteristics,
      lightRequirement: result.lightRequirement,
      waterRequirement: result.waterRequirement,
      soilPreference: result.soilPreference,
      toxicity: result.toxicity,
      growthHabit: result.growthHabit,
      seasonality: result.seasonality,
      sourceQuality: result.sourceQuality,
      distributionAreas: result.distributionAreas,
      distributionPoints: result.distributionPoints,
      note: const JsonEncoder.withIndent('  ').convert(response),
    );
  }
}
