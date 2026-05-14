class PlantScanResult {
  PlantScanResult({
    required this.displayName,
    required this.scientificName,
    required this.family,
    required this.order,
    required this.genus,
    required this.species,
    required this.uses,
    required this.advantages,
    required this.description,
    required this.note,
    required this.distributionAreas,
    required this.distributionPoints,
    this.confidence,
    this.aliases = '',
    this.habitat = '',
    this.morphology = '',
    this.characteristics = '',
    this.lightRequirement = '',
    this.waterRequirement = '',
    this.soilPreference = '',
    this.toxicity = '',
    this.growthHabit = '',
    this.seasonality = '',
    this.sourceQuality = '',
  });

  final String displayName;
  final String scientificName;
  final String family;
  final String order;
  final String genus;
  final String species;
  final String uses;
  final String advantages;
  final String description;
  final String note;
  final List<String> distributionAreas;
  final List<PlantDistributionPoint> distributionPoints;
  final double? confidence;
  final String aliases;
  final String habitat;
  final String morphology;
  final String characteristics;
  final String lightRequirement;
  final String waterRequirement;
  final String soilPreference;
  final String toxicity;
  final String growthHabit;
  final String seasonality;
  final String sourceQuality;

  factory PlantScanResult.fromApi(Map<String, dynamic> json) {
    final payload = _toMap(
      _pickValue(json, const [
        'result',
        'data',
        'prediction',
        'plant',
        'output',
        'response',
        'res',
      ]),
    );
    final sourceCandidate = payload.isNotEmpty ? payload : json;
    final plantSource = _toMap(_pickValue(sourceCandidate, const ['plant']));
    final source = plantSource.isNotEmpty ? plantSource : sourceCandidate;

    final points = _parseDistributionPoints(
      _pickValue(source, const [
        'distribution_points',
        'locations',
        'coordinates',
        'map_points',
        'distribution',
      ]),
    );

    final areas = _parseStringList(
      _pickValue(source, const [
        'distribution_areas',
        'distribution',
        'regions',
      ]),
    );

    final noteRaw = _pickValue(source, const ['note', 'notes', 'raw', 'debug']);

    return PlantScanResult(
      displayName: _stringOrEmpty(
        _pickValue(source, const [
          'name',
          'label',
          'plant_name',
          'common_name',
        ]),
      ),
      scientificName: _stringOrEmpty(
        _pickValue(source, const ['scientific_name', 'binomial_name']),
      ),
      family: _stringOrEmpty(_pickValue(source, const ['family', 'ho'])),
      order: _stringOrEmpty(
        _pickValue(source, const ['taxonomic_order', 'order', 'bo']),
      ),
      genus: _stringOrEmpty(_pickValue(source, const ['genus', 'chi'])),
      species: _stringOrEmpty(_pickValue(source, const ['species', 'loai'])),
      uses: _stringOrEmpty(
        _pickValue(source, const ['uses', 'utility', 'cong_dung']),
      ),
      advantages: _stringOrEmpty(
        _pickValue(source, const ['advantages', 'benefits', 'uu_diem']),
      ),
      description: _stringOrEmpty(
        _pickValue(source, const [
          'description',
          'desc',
          'summary',
          'detail',
          'information',
        ]),
      ),
      confidence: _asDouble(
        _pickValue(source, const ['confidence', 'score', 'probability']),
      ),
      aliases: _stringOrEmpty(
        _pickValue(source, const [
          'aliases',
          'alias',
          'synonyms',
          'other_names',
          'ten_khac',
        ]),
      ),
      habitat: _stringOrEmpty(
        _pickValue(source, const [
          'habitat',
          'environment',
          'native_habitat',
          'moi_truong_song',
        ]),
      ),
      morphology: _stringOrEmpty(
        _pickValue(source, const [
          'morphology',
          'appearance',
          'plant_form',
          'dac_diem_hinh_thai',
        ]),
      ),
      characteristics: _stringOrEmpty(
        _pickValue(source, const [
          'characteristics',
          'traits',
          'features',
          'dac_diem',
        ]),
      ),
      lightRequirement: _stringOrEmpty(
        _pickValue(source, const [
          'light',
          'light_requirement',
          'sunlight',
          'anh_sang',
        ]),
      ),
      waterRequirement: _stringOrEmpty(
        _pickValue(source, const [
          'water',
          'water_requirement',
          'watering',
          'nuoc',
        ]),
      ),
      soilPreference: _stringOrEmpty(
        _pickValue(source, const [
          'soil',
          'soil_preference',
          'soil_type',
          'dat_trong',
        ]),
      ),
      toxicity: _stringOrEmpty(
        _pickValue(source, const [
          'toxicity',
          'toxicity_level',
          'pet_safety',
          'doc_tinh',
        ]),
      ),
      growthHabit: _stringOrEmpty(
        _pickValue(source, const [
          'growth_habit',
          'growth',
          'habit',
          'dang_sinh_truong',
        ]),
      ),
      seasonality: _stringOrEmpty(
        _pickValue(source, const [
          'seasonality',
          'season',
          'blooming_season',
          'mua_vu',
        ]),
      ),
      sourceQuality: _stringOrEmpty(
        _pickValue(source, const [
          'source_quality',
          'data_quality',
          'reference_quality',
          'do_tin_cay',
        ]),
      ),
      note: _stringOrEmpty(noteRaw),
      distributionAreas: areas,
      distributionPoints: points,
    );
  }

  static dynamic _pickValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key) && source[key] != null) {
        return source[key];
      }
    }
    return null;
  }

  static Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static String _stringOrEmpty(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw.trim();
    if (raw is List) {
      return raw.whereType<String>().map((e) => e.trim()).join(', ');
    }
    return raw.toString().trim();
  }

  static double? _asDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) {
      final cleaned = raw.trim();
      if (cleaned.isEmpty) return const [];
      return [cleaned];
    }
    if (raw is List) {
      return raw
          .map((item) {
            if (item is Map) {
              final map = item.map(
                (key, value) => MapEntry(key.toString(), value),
              );
              return _stringOrEmpty(
                map['label'] ?? map['name'] ?? map['value'],
              );
            }
            return item.toString().trim();
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [raw.toString()];
  }

  static List<PlantDistributionPoint> _parseDistributionPoints(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) {
            if (item is! Map) return null;
            final map = item.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            final lat = _asDouble(map['lat'] ?? map['latitude']);
            final lng = _asDouble(map['lng'] ?? map['lon'] ?? map['longitude']);
            if (lat == null || lng == null) return null;
            return PlantDistributionPoint(
              lat: lat,
              lng: lng,
              label: _stringOrEmpty(map['label'] ?? map['name']),
            );
          })
          .whereType<PlantDistributionPoint>()
          .toList();
    }

    if (raw is Map) {
      final map = raw.map((key, value) => MapEntry(key.toString(), value));
      final nested = map['coordinates'] ?? map['points'];
      return _parseDistributionPoints(nested);
    }

    return const [];
  }
}

class PlantDistributionPoint {
  const PlantDistributionPoint({
    required this.lat,
    required this.lng,
    required this.label,
  });

  final double lat;
  final double lng;
  final String label;
}
