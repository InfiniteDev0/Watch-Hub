import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import '../models/wishlist_model.dart';

class WishlistRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<WishlistItemModel>> fetchWishlist() async {
    final res = await _dio.get('/api/wishlist');
    final items = res.data['items'] as List? ?? [];
    return items
        .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WishlistItemModel> addToWishlist(String productId) async {
    final res = await _dio.post(
      '/api/wishlist',
      data: {'product_id': productId},
    );
    return WishlistItemModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> removeFromWishlist(String productId) async {
    await _dio.delete('/api/wishlist/$productId');
  }
}
