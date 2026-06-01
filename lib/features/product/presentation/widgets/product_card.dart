import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final double? discountPrice;
  final int? discountPercentage;
  final bool isNewArrival;
  final VoidCallback? onTap;

  // Wishlist — optional so existing call sites need no changes
  final String? productId;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.discountPrice,
    this.discountPercentage,
    this.isNewArrival = false,
    this.onTap,
    this.productId,
    this.isWishlisted = false,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Section
          Expanded(
            child: Stack(
              children: [
                // CachedNetworkImage keeps decoded bitmaps in memory and on
                // disk so revisiting / re-scrolling the grid never re-downloads
                // or re-decodes the same image — eliminates scroll jank.
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    color: const Color(0xFFF6F6F6),
                    width: double.infinity,
                    height: double.infinity,
                    child: imageUrl.isEmpty
                        ? const SizedBox()
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(milliseconds: 180),
                            fadeOutDuration: Duration.zero,
                            placeholder: (_, __) =>
                                const ColoredBox(color: Color(0xFFF6F6F6)),
                            errorWidget: (_, __, ___) =>
                                const ColoredBox(color: Color(0xFFF6F6F6)),
                          ),
                  ),
                ),
                // "New" Badge — Top Left
                if (isNewArrival)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                // Wishlist Icon — Bottom Right
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: isWishlisted
                          ? const Color(0xFFE53935)
                          : Colors.black87,
                    ),
                    onPressed: onWishlistTap,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (discountPrice != null) ...[
                      Text(
                        '£${discountPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '£${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-$discountPercentage%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD9534F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '£${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
    );
  }
}
