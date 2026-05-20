import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double priceAtPurchase;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        productName: json['product_name'] as String? ?? '',
        productImage: json['product_image'] as String?,
        quantity: json['quantity'] as int,
        priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      );

  double get subtotal => priceAtPurchase * quantity;
}

class OrderModel {
  final String id;
  final String status;
  final double total;
  final int itemCount;
  final Map<String, dynamic> shippingAddress;
  final List<OrderItemModel> items;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.itemCount,
    required this.shippingAddress,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List?;
    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] as num).toDouble(),
      itemCount: json['item_count'] as int? ?? rawItems?.length ?? 0,
      shippingAddress:
          (json['shipping_address'] as Map<String, dynamic>?) ?? {},
      items: rawItems
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get formattedDate => DateFormat('MMM d, yyyy').format(createdAt);
  String get shortId => '#${id.substring(0, 8).toUpperCase()}';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFE67E22);
      case 'confirmed':
        return const Color(0xFF2980B9);
      case 'shipped':
        return const Color(0xFF8E44AD);
      case 'delivered':
        return const Color(0xFF27AE60);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  bool get isCancellable => status == 'pending';
}
