import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import 'package:watch_hub/core/network/api_constants.dart';
import 'package:watch_hub/features/auth/data/models/auth_user_model.dart';
import '../models/address_model.dart';

class ProfileRepository {
  final Dio _dio = ApiClient.dio;

  // ── Profile ───────────────────────────────────────────────────────

  Future<AuthUserModel> fetchProfile(String userId) async {
    final res = await _dio.get(ApiConstants.userById(userId));
    return AuthUserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthUserModel> updateProfile(
    String userId, {
    String? fullName,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (phone != null) body['phone'] = phone;

    final res = await _dio.patch(ApiConstants.userById(userId), data: body);
    return AuthUserModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Addresses ─────────────────────────────────────────────────────

  Future<List<AddressModel>> fetchAddresses(String userId) async {
    final res = await _dio.get(ApiConstants.userAddresses(userId));
    final list = res.data as List;
    return list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> createAddress(
    String userId,
    AddressModel address,
  ) async {
    final res = await _dio.post(
      ApiConstants.userAddresses(userId),
      data: address.toJsonForCreate(),
    );
    return AddressModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AddressModel> updateAddress(
    String userId,
    AddressModel address,
  ) async {
    final res = await _dio.patch(
      ApiConstants.userAddress(userId, address.id),
      data: address.toJsonForUpdate(),
    );
    return AddressModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    await _dio.delete(ApiConstants.userAddress(userId, addressId));
  }
}
