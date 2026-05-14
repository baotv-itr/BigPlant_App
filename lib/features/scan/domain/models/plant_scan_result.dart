class PlantScanResult {
  PlantScanResult({
    required this.displayName,
    required this.scientificName,
    required this.scientificNameSearch,
    required this.commonName,
    required this.family,
    required this.order,
    required this.genus,
    required this.species,
    required this.taxonomicStatus,
    required this.uses,
    required this.advantages,
    required this.description,
    required this.toxicityWarning,
    required this.safetyNotes,
    required this.evidenceLevel,
    required this.source,
    required this.note,
    required this.distributionAreas,
    required this.distributionPoints,
    this.confidence,
  });

  final String displayName;
  final String scientificName;
  final String scientificNameSearch;
  final String commonName;
  final String family;
  final String order;
  final String genus;
  final String species;
  final String taxonomicStatus;
  final String uses;
  final String advantages;
  final String description;
  final String toxicityWarning;
  final String safetyNotes;
  final String evidenceLevel;
  final String source;
  final String note;
  final List<String> distributionAreas;
  final List<PlantDistributionPoint> distributionPoints;
  final double? confidence;

  List<String> get sourceTokens => source
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  String sourceForField(String fieldKey) {
    final tokens = sourceTokens;
    if (tokens.isEmpty) return '';

    final orderedFields = <MapEntry<String, String>>[
      MapEntry('scientific_name', scientificName),
      MapEntry('scientific_name_search', scientificNameSearch),
      MapEntry('common_name', commonName),
      MapEntry('family', family),
      MapEntry('taxonomic_order', order),
      MapEntry('genus', genus),
      MapEntry('species', species),
      MapEntry('taxonomic_status', taxonomicStatus),
      MapEntry('uses', uses),
      MapEntry('advantages', advantages),
      MapEntry('description', description),
      MapEntry('toxicity_warning', toxicityWarning),
      MapEntry('safety_notes', safetyNotes),
      MapEntry('evidence_level', evidenceLevel),
    ];

    var tokenIndex = 0;
    for (final entry in orderedFields) {
      if (entry.value.trim().isEmpty) continue;
      if (tokenIndex >= tokens.length) break;
      if (entry.key == fieldKey) {
        return tokens[tokenIndex];
      }
      tokenIndex++;
    }

    return '';
  }

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
          'common_name',
          'name',
          'label',
          'plant_name',
          'scientific_name',
        ]),
      ),
      scientificName: _stringOrEmpty(
        _pickValue(source, const ['scientific_name', 'binomial_name', 'name']),
      ),
      scientificNameSearch: _stringOrEmpty(
        _pickValue(source, const ['scientific_name_search', 'name_search']),
      ),
      commonName: _stringOrEmpty(
        _pickValue(source, const ['common_name', 'plant_name', 'label']),
      ),
      family: _stringOrEmpty(_pickValue(source, const ['family', 'ho'])),
      order: _stringOrEmpty(
        _pickValue(source, const ['taxonomic_order', 'order', 'bo']),
      ),
      genus: _stringOrEmpty(_pickValue(source, const ['genus', 'chi'])),
      species: _stringOrEmpty(_pickValue(source, const ['species', 'loai'])),
      taxonomicStatus: _stringOrEmpty(
        _pickValue(source, const ['taxonomic_status', 'status']),
      ),
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
      toxicityWarning: _stringOrEmpty(
        _pickValue(source, const ['toxicity_warning', 'toxicity_warning_text']),
      ),
      safetyNotes: _stringOrEmpty(
        _pickValue(source, const ['safety_notes', 'safety_note']),
      ),
      evidenceLevel: _stringOrEmpty(
        _pickValue(source, const ['evidence_level', 'evidence']),
      ),
      source: _stringOrEmpty(_pickValue(source, const ['source'])),
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
