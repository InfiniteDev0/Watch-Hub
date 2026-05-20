import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';

/// Wraps all raw HTTP calls for the brands endpoints.
/// Returns untyped JSON so the repository can map to models.
class BrandsService {
  final Dio _dio;

  BrandsService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<Map<String, dynamic>>> fetchAllBrands() async {
    final res = await _dio.get('/api/brands');
    return (res.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchBrandById(String id) async {
    final res = await _dio.get('/api/brands/$id');
    return res.data as Map<String, dynamic>;
  }
}
