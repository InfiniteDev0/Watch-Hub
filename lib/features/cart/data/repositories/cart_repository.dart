import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRepository {
  final Dio _dio = ApiClient.dio;

  Future<CartModel> fetchCart() async {
    final res = await _dio.get('/api/cart');
    return CartModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CartModel> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    await _dio.post(
      '/api/cart/add',
      data: {'product_id': productId, 'quantity': quantity},
    );
    // Re-fetch so the UI gets complete product data (images, name, etc.)
    return fetchCart();
  }

  // Returns void — the provider handles optimistic state, no re-fetch needed.
  // Re-fetching here caused a second rebuild + flicker on every +/- tap.
  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    await _dio.put(
      '/api/cart/item/$cartItemId',
      data: {'quantity': quantity},
    );
  }

  Future<void> removeCartItem(String cartItemId) async {
    await _dio.delete('/api/cart/item/$cartItemId');
  }

  Future<void> clearCart() async {
    await _dio.delete('/api/cart/clear');
  }
}
