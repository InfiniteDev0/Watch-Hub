import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import 'package:watch_hub/features/admin/data/models/admin_stats_model.dart';

/// All admin-specific API calls. Every request automatically carries the
/// admin JWT via [ApiClient.dio]'s interceptor — the backend's
/// `requireAdmin` middleware will reject non-admin tokens with 403.
class AdminRepository {
  final Dio _dio;

  AdminRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  // ── Dashboard stats ────────────────────────────────────────────
  Future<AdminStatsModel> getStats() async {
    final res = await _dio.get('/api/admin/stats');
    return AdminStatsModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Users ──────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await _dio.get('/api/users');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _dio.patch('/api/users/$userId/role', data: {'role': role});
  }

  Future<void> deleteUser(String userId) async {
    await _dio.delete('/api/users/$userId');
  }

  // ── Products ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await _dio.get('/api/products');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> deleteProduct(String productId) async {
    await _dio.delete('/api/products/$productId');
  }

  // ── Brands ──────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBrands() async {
    final res = await _dio.get('/api/brands');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> deleteBrand(String brandId) async {
    await _dio.delete('/api/brands/$brandId');
  }
}
