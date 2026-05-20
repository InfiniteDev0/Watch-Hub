import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';

class ProductsService {
  final Dio _dio;

  ProductsService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  // ── In-memory cache (5-min TTL) ────────────────────────────────────
  static final Map<String, List<Map<String, dynamic>>> _listCache = {};
  static final Map<String, DateTime> _listCacheTime = {};
  static final Map<String, Map<String, dynamic>> _detailCache = {};
  static const _ttl = Duration(minutes: 5);

  static String _listKey(
    String? brandId,
    bool? isNewArrival,
    bool? isBestSeller,
    bool? isFeatured,
    int page,
    int limit,
  ) =>
      '$brandId|$isNewArrival|$isBestSeller|$isFeatured|$page|$limit';

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? brandId,
    bool? isNewArrival,
    bool? isBestSeller,
    bool? isFeatured,
    int page = 1,
    int limit = 50,
  }) async {
    final key = _listKey(
        brandId, isNewArrival, isBestSeller, isFeatured, page, limit);
    final cached = _listCache[key];
    final cachedAt = _listCacheTime[key];
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _ttl) {
      return cached;
    }

    final res = await _dio.get(
      '/api/products',
      queryParameters: {
        if (brandId != null) 'brand_id': brandId,
        if (isNewArrival == true) 'is_new_arrival': 'true',
        if (isBestSeller == true) 'is_best_seller': 'true',
        if (isFeatured == true) 'is_featured': 'true',
        'page': page,
        'limit': limit,
      },
    );
    // Backend returns either a plain list or {products: [...], pagination: {...}}
    final body = res.data;
    List<Map<String, dynamic>> result;
    if (body is List) {
      result = body.cast<Map<String, dynamic>>();
    } else {
      final rawList = body['products'] ?? body['data'];
      result = rawList == null
          ? []
          : (rawList as List).cast<Map<String, dynamic>>();
    }

    _listCache[key] = result;
    _listCacheTime[key] = DateTime.now();
    return result;
  }

  Future<Map<String, dynamic>> fetchProductById(String id) async {
    final cached = _detailCache[id];
    if (cached != null) return cached;

    final res = await _dio.get('/api/products/$id');
    final result = res.data as Map<String, dynamic>;
    _detailCache[id] = result;
    return result;
  }

  static void invalidateCache() {
    _listCache.clear();
    _listCacheTime.clear();
    _detailCache.clear();
  }
}
