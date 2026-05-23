enum ShopProductType { plant, pot, accessory, service }

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.sortOrder,
    this.productCount,
  });

  final Object id;
  final String name;
  final String slug;
  final String description;
  final bool isActive;
  final int sortOrder;
  final int? productCount;

  factory ProductCategory.fromApi(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? json['_id'] ?? '',
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      description: _asString(json['description']),
      isActive: _asBool(json['is_active'], fallback: true),
      sortOrder: _asInt(json['sort_order']),
      productCount: json['product_count'] == null
          ? null
          : _asInt(json['product_count']),
    );
  }
}

class ProductInventory {
  const ProductInventory({
    required this.availableQty,
    required this.reservedQty,
    required this.soldQty,
    required this.inStock,
  });

  final int availableQty;
  final int reservedQty;
  final int soldQty;
  final bool inStock;

  factory ProductInventory.fromApi(Map<String, dynamic> json) {
    return ProductInventory(
      availableQty: _asInt(json['available_qty']),
      reservedQty: _asInt(json['reserved_qty']),
      soldQty: _asInt(json['sold_qty']),
      inStock: _asBool(json['in_stock']),
    );
  }
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.productId,
    required this.variantSku,
    required this.variantName,
    required this.attributes,
    required this.price,
    this.compareAtPrice,
    this.weightGram,
    required this.isDefault,
    required this.isActive,
    this.inventory,
  });

  final Object id;
  final Object productId;
  final String variantSku;
  final String variantName;
  final Map<String, String> attributes;
  final double price;
  final double? compareAtPrice;
  final int? weightGram;
  final bool isDefault;
  final bool isActive;
  final ProductInventory? inventory;

  String get sizeLabel => attributes['size_label'] ?? variantName;
  String get sizeSubtitle => attributes['size_subtitle'] ?? '';
  String get potStyle => attributes['pot_style'] ?? '';
  String get waterNeed => attributes['water_need'] ?? '';
  String get lightNeed => attributes['light_need'] ?? '';
  String get careBadge => attributes['care_badge'] ?? '';

  factory ProductVariant.fromApi(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? json['_id'] ?? '',
      productId: json['product_id'] ?? '',
      variantSku: _asString(json['variant_sku']),
      variantName: _asString(json['variant_name']),
      attributes: _toStringMap(json['attributes']),
      price: _asDouble(json['price']),
      compareAtPrice: json['compare_at_price'] == null
          ? null
          : _asDouble(json['compare_at_price']),
      weightGram: json['weight_gram'] == null
          ? null
          : _asInt(json['weight_gram']),
      isDefault: _asBool(json['is_default']),
      isActive: _asBool(json['is_active'], fallback: true),
      inventory: json['inventory'] is Map<String, dynamic>
          ? ProductInventory.fromApi(json['inventory'] as Map<String, dynamic>)
          : json['inventory'] is Map
          ? ProductInventory.fromApi(_toMap(json['inventory']))
          : null,
    );
  }
}

class ProductImage {
  const ProductImage({
    required this.imageId,
    required this.productId,
    this.variantId,
    required this.imageUrl,
    required this.altText,
    required this.sortOrder,
    required this.isPrimary,
    this.isFallback = false,
  });

  final Object imageId;
  final Object productId;
  final Object? variantId;
  final String imageUrl;
  final String altText;
  final int sortOrder;
  final bool isPrimary;
  final bool isFallback;

  factory ProductImage.fromApi(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['id'] ?? json['_id'] ?? '',
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'],
      imageUrl: _asString(json['image_url']),
      altText: _asString(json['alt_text']),
      sortOrder: _asInt(json['sort_order']),
      isPrimary: _asBool(json['is_primary']),
      isFallback: _asBool(json['is_fallback']),
    );
  }
}

class LinkedPlantSnapshot {
  const LinkedPlantSnapshot({
    required this.plantId,
    required this.scientificName,
    required this.commonName,
    required this.family,
    required this.taxonomicOrder,
    required this.genus,
    required this.species,
    required this.taxonomicStatus,
    required this.description,
    required this.toxicityWarning,
    this.uses = '',
    this.advantages = '',
    this.safetyNotes = '',
    this.evidenceLevel = '',
    this.source = const {},
  });

  final Object plantId;
  final String scientificName;
  final String commonName;
  final String family;
  final String taxonomicOrder;
  final String genus;
  final String species;
  final String taxonomicStatus;
  final String description;
  final String toxicityWarning;
  final String uses;
  final String advantages;
  final String safetyNotes;
  final String evidenceLevel;
  final Map<String, String> source;

  factory LinkedPlantSnapshot.fromApi(Map<String, dynamic> json) {
    return LinkedPlantSnapshot(
      plantId: json['id'] ?? json['_id'] ?? '',
      scientificName: _asString(json['scientific_name']),
      commonName: _asString(json['common_name']),
      family: _asString(json['family']),
      taxonomicOrder: _asString(json['taxonomic_order']),
      genus: _asString(json['genus']),
      species: _asString(json['species']),
      taxonomicStatus: _asString(json['taxonomic_status']),
      description: _asString(json['description']),
      toxicityWarning: _asString(json['toxicity_warning']),
      uses: _asString(json['uses']),
      advantages: _asString(json['advantages']),
      safetyNotes: _asString(json['safety_notes']),
      evidenceLevel: _asString(json['evidence_level']),
      source: _toStringMap(json['source']),
    );
  }
}

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.categoryId,
    required this.plantId,
    required this.sku,
    required this.productType,
    required this.name,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.careLevel,
    required this.ratingAvg,
    required this.ratingCount,
    required this.isActive,
    required this.category,
    required this.variants,
    required this.images,
    required this.linkedPlant,
  });

  final Object id;
  final Object? categoryId;
  final Object? plantId;
  final String sku;
  final ShopProductType productType;
  final String name;
  final String slug;
  final String shortDescription;
  final String description;
  final String careLevel;
  final double ratingAvg;
  final int ratingCount;
  final bool isActive;
  final ProductCategory? category;
  final List<ProductVariant> variants;
  final List<ProductImage> images;
  final LinkedPlantSnapshot? linkedPlant;

  ProductVariant get defaultVariant => variants.firstWhere(
    (variant) => variant.isDefault,
    orElse: () => variants.first,
  );

  ProductImage get primaryImage =>
      images.firstWhere((image) => image.isPrimary, orElse: () => images.first);

  List<ProductImage> get sortedImages {
    final copy = [...images];
    copy.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  List<ProductVariant> get sizeVariants {
    final map = <String, ProductVariant>{};
    for (final variant in variants.where((item) => item.isActive)) {
      map.putIfAbsent(variant.sizeLabel, () => variant);
    }
    return map.values.toList(growable: false);
  }

  List<String> get potStyles {
    final styles = variants
        .where((variant) => variant.isActive && variant.potStyle.isNotEmpty)
        .map((variant) => variant.potStyle)
        .toSet()
        .toList(growable: false);
    return styles;
  }

  ProductVariant resolveVariant({
    required String sizeLabel,
    required String potStyle,
  }) {
    for (final variant in variants.where((item) => item.isActive)) {
      if (variant.sizeLabel == sizeLabel && variant.potStyle == potStyle) {
        return variant;
      }
    }
    for (final variant in variants.where((item) => item.isActive)) {
      if (variant.sizeLabel == sizeLabel) return variant;
    }
    return defaultVariant;
  }

  factory ShopProduct.fromApi(Map<String, dynamic> json) {
    final categoryMap = _toMap(json['category']);
    final linkedPlantMap = _toMap(json['linked_plant']);
    final variants = _toList(
      json['variants'],
    ).map(ProductVariant.fromApi).toList(growable: false);
    final images = _toList(
      json['images'],
    ).map(ProductImage.fromApi).toList(growable: false);

    return ShopProduct(
      id: json['id'] ?? json['_id'] ?? '',
      categoryId: json['category_id'],
      plantId: json['plant_id'],
      sku: _asString(json['sku']),
      productType: _parseProductType(_asString(json['product_type'])),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      shortDescription: _asString(json['short_description']),
      description: _asString(json['description']),
      careLevel: _asString(json['care_level']),
      ratingAvg: _asDouble(json['rating_avg']),
      ratingCount: _asInt(json['rating_count']),
      isActive: _asBool(json['is_active'], fallback: true),
      category: categoryMap.isEmpty
          ? null
          : ProductCategory.fromApi(categoryMap),
      variants: variants,
      images: images,
      linkedPlant: linkedPlantMap.isEmpty
          ? null
          : LinkedPlantSnapshot.fromApi(linkedPlantMap),
    );
  }
}

class ShopCatalogPage {
  const ShopCatalogPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<ShopProduct> items;
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory ShopCatalogPage.fromApi(Map<String, dynamic> json) {
    final data = _toMap(json['data']);
    final pagination = _toMap(data['pagination']);
    return ShopCatalogPage(
      items: _toList(
        data['items'],
      ).map(ShopProduct.fromApi).toList(growable: false),
      page: _asInt(pagination['page'], fallback: 1),
      limit: _asInt(pagination['limit'], fallback: 8),
      totalItems: _asInt(pagination['total_items']),
      totalPages: _asInt(pagination['total_pages'], fallback: 1),
      hasNextPage: _asBool(pagination['has_next_page']),
      hasPreviousPage: _asBool(pagination['has_previous_page']),
    );
  }
}

ShopProductType _parseProductType(String value) {
  switch (value.trim().toLowerCase()) {
    case 'pot':
      return ShopProductType.pot;
    case 'accessory':
      return ShopProductType.accessory;
    case 'service':
      return ShopProductType.service;
    case 'plant':
    default:
      return ShopProductType.plant;
  }
}

Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _toList(dynamic raw) {
  if (raw is List) {
    return raw.map(_toMap).toList(growable: false);
  }
  return const <Map<String, dynamic>>[];
}

Map<String, String> _toStringMap(dynamic raw) {
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), _asString(value)));
  }
  return const <String, String>{};
}

String _asString(dynamic raw) {
  if (raw == null) return '';
  return raw.toString().trim();
}

bool _asBool(dynamic raw, {bool fallback = false}) {
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;
  final value = _asString(raw).toLowerCase();
  if (value == 'true' || value == '1') return true;
  if (value == 'false' || value == '0') return false;
  return fallback;
}

int _asInt(dynamic raw, {int fallback = 0}) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(_asString(raw)) ?? fallback;
}

double _asDouble(dynamic raw, {double fallback = 0}) {
  if (raw is double) return raw;
  if (raw is num) return raw.toDouble();
  return double.tryParse(_asString(raw)) ?? fallback;
}
