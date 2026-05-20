class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? sku;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? brandId;
  final String? brandName;
  final String? brandLogoUrl;
  final List<String> images;
  final bool isNewArrival;
  final bool isBestSeller;
  final bool isFeatured;
  final bool isActive;
  final String status;
  final int? stockQuantity;
  // Watch specifications
  final String? movementType;
  final String? caseMaterial;
  final double? caseDiameterMm;
  final double? caseThicknessMm;
  final String? bandMaterial;
  final double? bandWidthMm;
  final String? dialColor;
  final String? crystalType;
  final int? waterResistanceM;
  final double? lugWidthMm;
  final List<String> tags;

  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    this.description,
    required this.price,
    this.discountPrice,
    this.brandId,
    this.brandName,
    this.brandLogoUrl,
    this.images = const [],
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.isFeatured = false,
    this.isActive = true,
    this.status = 'active',
    this.stockQuantity,
    this.movementType,
    this.caseMaterial,
    this.caseDiameterMm,
    this.caseThicknessMm,
    this.bandMaterial,
    this.bandWidthMm,
    this.dialColor,
    this.crystalType,
    this.waterResistanceM,
    this.lugWidthMm,
    this.tags = const [],
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get discountPercent => hasDiscount
      ? ((price - discountPrice!) / price * 100).roundToDouble()
      : 0;

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  bool get inStock => (stockQuantity == null || stockQuantity! > 0) && isActive;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.whereType<String>().toList();
    }

    final brandObj = json['brand'] as Map<String, dynamic>?;

    final rawTags = json['tags'];
    List<String> tagList = [];
    if (rawTags is List) {
      tagList = rawTags.whereType<String>().toList();
    }

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice:
          (json['discount_price'] ?? json['compare_at_price']) != null
          ? ((json['discount_price'] ?? json['compare_at_price']) as num)
                .toDouble()
          : null,
      brandId: json['brand_id'] as String? ?? brandObj?['id'] as String?,
      brandName: json['brand_name'] as String? ?? brandObj?['name'] as String?,
      brandLogoUrl: brandObj?['logo_url'] as String?,
      images: imageList,
      isNewArrival: json['is_new_arrival'] as bool? ?? false,
      isBestSeller: json['is_best_seller'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String? ?? 'active',
      stockQuantity: json['stock_quantity'] as int?,
      movementType: json['movement_type'] as String?,
      caseMaterial: json['case_material'] as String?,
      caseDiameterMm: json['case_diameter_mm'] != null
          ? (json['case_diameter_mm'] as num).toDouble()
          : null,
      caseThicknessMm: json['case_thickness_mm'] != null
          ? (json['case_thickness_mm'] as num).toDouble()
          : null,
      bandMaterial: json['band_material'] as String?,
      bandWidthMm: json['band_width_mm'] != null
          ? (json['band_width_mm'] as num).toDouble()
          : null,
      dialColor: json['dial_color'] as String?,
      crystalType: json['crystal_type'] as String?,
      waterResistanceM: json['water_resistance_m'] as int?,
      lugWidthMm: json['lug_width_mm'] != null
          ? (json['lug_width_mm'] as num).toDouble()
          : null,
      tags: tagList,
    );
  }
}
