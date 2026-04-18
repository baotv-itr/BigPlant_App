class LocalModelCatalog {
  const LocalModelCatalog({
    required this.defaultModel,
    required this.cameraMode,
    required this.galleryMode,
    required this.models,
  });

  final String defaultModel;
  final String cameraMode;
  final String galleryMode;
  final Map<String, LocalModelEntry> models;

  factory LocalModelCatalog.fromJson(Map<String, dynamic> json) {
    final modelsRaw = json['models'];
    final models = <String, LocalModelEntry>{};

    if (modelsRaw is Map) {
      for (final entry in modelsRaw.entries) {
        final value = entry.value;
        if (value is! Map) continue;
        final normalized = value.map(
          (key, item) => MapEntry(key.toString(), item),
        );
        models[entry.key.toString()] = LocalModelEntry.fromJson(normalized);
      }
    }

    return LocalModelCatalog(
      defaultModel: (json['default_model'] ?? '').toString(),
      cameraMode: (json['camera_mode'] ?? '').toString(),
      galleryMode: (json['gallery_mode'] ?? '').toString(),
      models: models,
    );
  }
}

class LocalModelEntry {
  const LocalModelEntry({
    required this.displayName,
    required this.configPath,
    required this.labelsPath,
    required this.onnxPath,
    required this.supportsCameraRealtime,
    required this.numClasses,
  });

  final String displayName;
  final String configPath;
  final String labelsPath;
  final String onnxPath;
  final bool supportsCameraRealtime;
  final int numClasses;

  factory LocalModelEntry.fromJson(Map<String, dynamic> json) {
    return LocalModelEntry(
      displayName: (json['display_name'] ?? '').toString(),
      configPath: (json['config_path'] ?? '').toString(),
      labelsPath: (json['labels_path'] ?? '').toString(),
      onnxPath: (json['onnx_path'] ?? '').toString(),
      supportsCameraRealtime: json['supports_camera_realtime'] == true,
      numClasses: _toInt(json['num_classes']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class LocalModelConfig {
  const LocalModelConfig({
    required this.modelId,
    required this.preprocessMode,
    required this.twoPassDefault,
    required this.inputNames,
    required this.outputNames,
    required this.imageSize,
    required this.organPriorSize,
  });

  final String modelId;
  final String preprocessMode;
  final bool twoPassDefault;
  final List<String> inputNames;
  final List<String> outputNames;
  final int imageSize;
  final int organPriorSize;

  bool get requiresOrganPrior => organPriorSize > 0;

  factory LocalModelConfig.fromJson(Map<String, dynamic> json) {
    final runtimeRaw = json['runtime'];
    final ioRaw = json['io'];
    final runtime = runtimeRaw is Map
        ? runtimeRaw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
    final io = ioRaw is Map
        ? ioRaw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final inputs = _parseNames(io['inputs']);
    final outputs = _parseNames(io['outputs']);
    final imageSize = _parseImageSize(io['inputs']);
    final organSize = _parseOrganPriorSize(io['inputs']);

    return LocalModelConfig(
      modelId: (json['model_id'] ?? '').toString(),
      preprocessMode: (runtime['preprocess_mode'] ?? 'raw_01').toString(),
      twoPassDefault: runtime['two_pass_default'] == true,
      inputNames: inputs,
      outputNames: outputs,
      imageSize: imageSize,
      organPriorSize: organSize,
    );
  }

  static List<String> _parseNames(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              (item['name']?.toString().trim() ?? '').trim(),
        )
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static int _parseImageSize(dynamic raw) {
    if (raw is! List) return 224;
    for (final item in raw) {
      if (item is! Map) continue;
      final name = item['name']?.toString();
      if (name != 'image') continue;
      final shape = item['shape'];
      if (shape is List && shape.length >= 4) {
        final h = _toInt(shape[2]);
        final w = _toInt(shape[3]);
        if (h > 0 && w > 0) return h;
      }
    }
    return 224;
  }

  static int _parseOrganPriorSize(dynamic raw) {
    if (raw is! List) return 0;
    for (final item in raw) {
      if (item is! Map) continue;
      final name = item['name']?.toString();
      if (name != 'organ_prior') continue;
      final shape = item['shape'];
      if (shape is List && shape.length >= 2) {
        return _toInt(shape[1]);
      }
    }
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
