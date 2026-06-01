class AdminOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double priceAtPurchase;

  const AdminOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> j) => AdminOrderItem(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        productName: j['product_name'] as String? ?? '',
        productImage: j['product_image'] as String?,
        quantity: j['quantity'] as int? ?? 1,
        priceAtPurchase:
            (j['price_at_purchase'] as num?)?.toDouble() ?? 0.0,
      );
}

class AdminOrderModel {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final String customerName;
  final String? customerId;
  final Map<String, dynamic>? shippingAddress;
  final List<AdminOrderItem> items;

  const AdminOrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.customerName,
    this.customerId,
    this.shippingAddress,
    this.items = const [],
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> j) {
    final rawItems = j['order_items'] as List?;
    return AdminOrderModel(
      id: j['id'] as String,
      status: j['status'] as String? ?? 'pending',
      total: (j['total'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      customerName: j['customer_name'] as String? ?? 'Unknown',
      customerId: j['customer_id'] as String?,
      shippingAddress: j['shipping_address'] as Map<String, dynamic>?,
      items: rawItems
              ?.map((e) => AdminOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
