enum ShopProductType { plant, pot, accessory, service }

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final String slug;
  final String description;
  final bool isActive;
  final int sortOrder;
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
  });

  final int id;
  final String productId;
  final String variantSku;
  final String variantName;
  final Map<String, String> attributes;
  final double price;
  final double? compareAtPrice;
  final int? weightGram;
  final bool isDefault;
  final bool isActive;

  String get sizeLabel => attributes['size_label'] ?? variantName;
  String get sizeSubtitle => attributes['size_subtitle'] ?? '';
  String get potStyle => attributes['pot_style'] ?? '';
  String get waterNeed => attributes['water_need'] ?? '';
  String get lightNeed => attributes['light_need'] ?? '';
  String get careBadge => attributes['care_badge'] ?? '';
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
  });

  final String imageId;
  final String productId;
  final int? variantId;
  final String imageUrl;
  final String altText;
  final int sortOrder;
  final bool isPrimary;
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
  });

  final int plantId;
  final String scientificName;
  final String commonName;
  final String family;
  final String taxonomicOrder;
  final String genus;
  final String species;
  final String taxonomicStatus;
  final String description;
  final String toxicityWarning;
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

  final String id;
  final int categoryId;
  final int plantId;
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
  final ProductCategory category;
  final List<ProductVariant> variants;
  final List<ProductImage> images;
  final LinkedPlantSnapshot linkedPlant;

  ProductVariant get defaultVariant =>
      variants.firstWhere((variant) => variant.isDefault, orElse: () => variants.first);

  ProductImage get primaryImage => images.firstWhere(
        (image) => image.isPrimary,
        orElse: () => images.first,
      );

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

  ProductVariant resolveVariant({required String sizeLabel, required String potStyle}) {
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
}
