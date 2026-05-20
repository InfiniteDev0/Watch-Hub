import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';

class ProductBadgeRow extends StatelessWidget {
  final ProductModel product;

  const ProductBadgeRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final badges = <(String, Color, Color)>[];
    if (product.isNewArrival) {
      badges.add(('New Arrival', Colors.black, Colors.white));
    }
    if (product.isBestSeller) {
      badges.add(('Best Seller', const Color(0xFFF5A623), Colors.white));
    }
    if (product.isFeatured) {
      badges.add(('Featured', const Color(0xFF4A90D9), Colors.white));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: badges
          .map(
            (b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: b.$2,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                b.$1,
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: b.$3,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ProductPriceRow extends StatelessWidget {
  final ProductModel product;

  const ProductPriceRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final effectivePrice =
        product.hasDiscount ? product.discountPrice! : product.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${effectivePrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 16,
                color: Colors.grey[500],
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${product.discountPercent.toInt()}% off',
              style: const TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ProductAvailabilityBadge extends StatelessWidget {
  final ProductModel product;

  const ProductAvailabilityBadge({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;
    final qty = product.stockQuantity;
    final lowStock = qty != null && qty > 0 && qty <= 5;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: inStock
                ? (lowStock ? Colors.orange : Colors.green)
                : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          inStock
              ? (lowStock ? 'Low stock — only $qty left' : 'In Stock')
              : 'Out of Stock',
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: inStock
                ? (lowStock ? Colors.orange[800] : Colors.green[700])
                : Colors.red[700],
          ),
        ),
      ],
    );
  }
}
