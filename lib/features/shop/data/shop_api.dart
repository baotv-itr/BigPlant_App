import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class ShopApi {
  ShopApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchCategories() {
    return _client.get(_buildUrl('api/shop/categories'));
  }

  Future<Map<String, dynamic>> fetchProducts({
    String? categorySlug,
    String? query,
    required int page,
    required int limit,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (categorySlug != null && categorySlug.trim().isNotEmpty)
        'category': categorySlug.trim(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };
    return _client.get(_buildUrl('api/shop/products', queryParameters: params));
  }

  Future<Map<String, dynamic>> fetchProductDetail(String slug) {
    return _client.get(_buildUrl('api/shop/products/${slug.trim()}'));
  }

  String _buildUrl(String path, {Map<String, String>? queryParameters}) {
    final base = ApiConstants.baseUrl;
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    final uri = Uri.parse('$normalizedBase$path');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri.toString();
    }
    return uri.replace(queryParameters: queryParameters).toString();
  }
}
