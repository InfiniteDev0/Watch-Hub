import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';

class BrandCard extends StatelessWidget {
  final BrandModel brand;
  final VoidCallback? onTap;

  const BrandCard({super.key, required this.brand, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: brand.logoUrl!,
                          width: 60,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _logoPlaceholder(),
                          errorWidget: (_, __, ___) => _logoPlaceholder(),
                        )
                      : _logoPlaceholder(),
                ),
                const SizedBox(width: 16),
                // Brand name
                Expanded(
                  child: Text(
                    brand.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppAssets.instrumentSerif,
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            if (brand.description != null && brand.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                brand.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder() => Container(
    width: 60,
    height: 50,
    decoration: BoxDecoration(
      color: const Color(0xFFD9D9D9),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

/// List of skeleton cards while loading — matches the list style.
class BrandCardSkeleton extends StatelessWidget {
  const BrandCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) =>
          const Divider(color: Color.fromARGB(255, 194, 194, 194), thickness: 1.5, height: 32),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Skeleton(width: 60, height: 50, borderRadius: 8),
                const SizedBox(width: 16),
                Skeleton(width: 140, height: 40, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 12),
            Skeleton(width: double.infinity, height: 14),
            const SizedBox(height: 4),
            Skeleton(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}
