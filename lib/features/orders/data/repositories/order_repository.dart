import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import 'package:watch_hub/core/network/api_constants.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<OrderModel>> fetchOrders() async {
    final res = await _dio.get(ApiConstants.orders);
    final list = res.data as List;
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> fetchOrderById(String orderId) async {
    final res = await _dio.get(ApiConstants.orderById(orderId));
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<OrderModel> createOrder({
    required Map<String, dynamic> shippingAddress,
  }) async {
    final res = await _dio.post(
      ApiConstants.orders,
      data: {'shipping_address': shippingAddress},
    );
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<OrderModel> cancelOrder(String orderId) async {
    final res = await _dio.patch(ApiConstants.cancelOrder(orderId));
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }
}
