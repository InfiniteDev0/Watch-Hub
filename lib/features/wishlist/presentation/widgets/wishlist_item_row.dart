import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/wishlist/data/models/wishlist_model.dart';

class WishlistItemRow extends StatelessWidget {
  final WishlistItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onMoveToCart;

  const WishlistItemRow({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onMoveToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 100,
                  height: 110,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: 16),

        // Details
        Expanded(
          child: SizedBox(
            height: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + trash icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ],
                ),

                // Subtitle
                if (item.details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],

                const Spacer(),

                // Price + Move to Bag button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: AppAssets.manrope,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    _MoveToBagBtn(onTap: onMoveToCart),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.watch, color: Color(0xFFE0E0E0), size: 36),
      );
}

class _MoveToBagBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _MoveToBagBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Move to Bag',
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
