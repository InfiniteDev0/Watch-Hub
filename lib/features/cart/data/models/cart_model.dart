class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String? imageUrl;
  final String details; // e.g. "Automatic | Stainless Steel"
  final int quantity;
  final double price;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.details,
    required this.quantity,
    required this.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    // Image: products table uses an images[] array
    final images = product?['images'];
    final imageUrl =
        (images is List && images.isNotEmpty) ? images[0] as String? : null;

    // Subtitle: prefer "Movement | Material", fall back to SKU
    final movement = product?['movement_type'] as String?;
    final material = product?['case_material'] as String?;
    final sku = product?['sku'] as String?;
    final detailParts = [movement, material]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    final details = detailParts.isNotEmpty
        ? detailParts.join(' | ')
        : (sku ?? '');

    return CartItemModel(
      id: json['id'] as String,
      productId:
          json['product_id'] as String? ?? product?['id'] as String? ?? '',
      name: product?['name'] as String? ?? '',
      imageUrl: imageUrl,
      details: details,
      quantity: json['quantity'] as int,
      price: ((product?['price'] ?? 0) as num).toDouble(),
    );
  }

  CartItemModel withQuantity(int qty) => CartItemModel(
        id: id,
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        details: details,
        quantity: qty,
        price: price,
      );

  double get subtotal => price * quantity;
}

class CartModel {
  final String? id;
  final List<CartItemModel> items;

  CartModel({this.id, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String?,
      items: (json['items'] as List? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
}
