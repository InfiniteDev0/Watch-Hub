import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import 'package:watch_hub/features/admin/data/models/admin_message_model.dart';
import 'package:watch_hub/features/admin/data/models/admin_order_model.dart';
import 'package:watch_hub/features/admin/data/models/admin_review_model.dart';
import 'package:watch_hub/features/admin/data/models/admin_stats_model.dart';
import 'package:watch_hub/features/admin/data/models/admin_user_model.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';

/// All admin-scoped API calls. Every request automatically carries the
/// admin JWT via [ApiClient.dio] — the backend's `requireAdmin` middleware
/// rejects non-admin tokens with 403.
class AdminRepository {
  final Dio _dio;
  AdminRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  // ── Stats ──────────────────────────────────────────────────────
  Future<AdminStatsModel> getStats() async {
    final res = await _dio.get('/api/admin/stats');
    return AdminStatsModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Users ──────────────────────────────────────────────────────
  Future<List<AdminUserModel>> getUsers() async {
    final res = await _dio.get('/api/users');
    return (res.data as List)
        .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _dio.patch('/api/users/$userId/role', data: {'role': role});
  }

  Future<void> deleteUser(String userId) async {
    await _dio.delete('/api/users/$userId');
  }

  // ── Products ────────────────────────────────────────────────────
  Future<List<ProductModel>> getProducts({int limit = 100}) async {
    final res = await _dio.get('/api/products', queryParameters: {'limit': limit});
    final body = res.data;
    final List raw = body is List ? body : (body['products'] ?? []) as List;
    return raw
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/products', data: data);
    return ProductModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/api/products/$id', data: data);
    return ProductModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String productId) async {
    await _dio.delete('/api/products/$productId');
  }

  // ── Brands ──────────────────────────────────────────────────────
  Future<List<BrandModel>> getBrands() async {
    final res = await _dio.get('/api/brands');
    return (res.data as List)
        .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BrandModel> createBrand(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/brands', data: data);
    return BrandModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BrandModel> updateBrand(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/api/brands/$id', data: data);
    return BrandModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteBrand(String brandId) async {
    await _dio.delete('/api/brands/$brandId');
  }

  // ── Orders ──────────────────────────────────────────────────────
  Future<List<AdminOrderModel>> getOrders({String? status, int limit = 100}) async {
    final res = await _dio.get('/api/admin/orders', queryParameters: {
      if (status != null) 'status': status,
      'limit': limit,
    });
    final list = res.data['orders'] as List;
    return list
        .map((e) => AdminOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminOrderModel> getOrder(String id) async {
    final res = await _dio.get('/api/admin/orders/$id');
    return AdminOrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AdminOrderModel> updateOrderStatus(String id, String status) async {
    final res = await _dio.patch(
      '/api/admin/orders/$id/status',
      data: {'status': status},
    );
    return AdminOrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Reviews ─────────────────────────────────────────────────────
  Future<List<AdminReviewModel>> getReviews({int limit = 100}) async {
    final res = await _dio.get('/api/admin/reviews', queryParameters: {'limit': limit});
    final list = res.data['reviews'] as List;
    return list
        .map((e) => AdminReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete('/api/admin/reviews/$reviewId');
  }

  // ── Messages (contact / feedback) ──────────────────────────────
  Future<List<AdminMessageModel>> getMessages({int limit = 100}) async {
    final res = await _dio.get(
      '/api/admin/messages',
      queryParameters: {'limit': limit},
    );
    final list = res.data['messages'] as List;
    return list
        .map((e) => AdminMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminMessageModel> markMessageRead(String id, bool isRead) async {
    final res = await _dio.patch(
      '/api/admin/messages/$id',
      data: {'is_read': isRead},
    );
    return AdminMessageModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteMessage(String id) async {
    await _dio.delete('/api/admin/messages/$id');
  }
}
