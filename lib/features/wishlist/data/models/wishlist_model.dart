class WishlistItemModel {
  final String id;
  final String productId;
  final String name;
  final String? imageUrl;
  final String details;
  final double price;

  const WishlistItemModel({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.details,
    required this.price,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    final images = product?['images'];
    final imageUrl =
        (images is List && images.isNotEmpty) ? images[0] as String? : null;

    final movement = product?['movement_type'] as String?;
    final material = product?['case_material'] as String?;
    final sku = product?['sku'] as String?;
    final detailParts = [movement, material]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    final details =
        detailParts.isNotEmpty ? detailParts.join(' | ') : (sku ?? '');

    return WishlistItemModel(
      id: json['id'] as String,
      productId:
          json['product_id'] as String? ?? product?['id'] as String? ?? '',
      name: product?['name'] as String? ?? '',
      imageUrl: imageUrl,
      details: details,
      price: ((product?['discount_price'] ?? product?['price'] ?? 0) as num)
          .toDouble(),
    );
  }

  // Used to swap optimistic item with the server-confirmed item
  WishlistItemModel copyWith({String? id}) => WishlistItemModel(
        id: id ?? this.id,
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        details: details,
        price: price,
      );
}
