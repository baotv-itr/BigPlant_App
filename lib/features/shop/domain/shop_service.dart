import '../../../core/network/api_client.dart';
import '../data/shop_api.dart';
import 'models/shop_product.dart';

class ShopService {
  ShopService({ShopApi? api}) : _api = api ?? ShopApi(ApiClient());

  final ShopApi _api;

  Future<List<ProductCategory>> fetchCategories() async {
    final response = await _api.fetchCategories();
    final data = _toMap(response['data']);
    final rawItems = data['categories'];
    if (rawItems is! List) return const <ProductCategory>[];
    return rawItems
        .whereType<Map>()
        .map((item) => ProductCategory.fromApi(_toMap(item)))
        .toList(growable: false);
  }

  Future<ShopCatalogPage> fetchProducts({
    String? categorySlug,
    String? query,
    required int page,
    required int limit,
  }) async {
    final response = await _api.fetchProducts(
      categorySlug: categorySlug,
      query: query,
      page: page,
      limit: limit,
    );
    return ShopCatalogPage.fromApi(response);
  }

  Future<ShopProduct> fetchProductDetail(String slug) async {
    final response = await _api.fetchProductDetail(slug);
    final data = _toMap(response['data']);
    return ShopProduct.fromApi(_toMap(data['product']));
  }
}

Map<String, dynamic> _toMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}
