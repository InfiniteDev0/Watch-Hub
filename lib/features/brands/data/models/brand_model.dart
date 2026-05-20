class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final bool isActive;

  const BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.isActive = true,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String?,
    logoUrl: json['logo_url'] as String?,
    bannerUrl: json['banner_url'] as String?,
    isActive: json['is_active'] as bool? ?? true,
  );
}
