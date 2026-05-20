import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watch_hub/core/constants/app_colors.dart';

/// Shimmer loading placeholder for product cards
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Product name shimmer
        Shimmer.fromColors(
          baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.borderLight,
          highlightColor: isDarkMode ? AppColors.borderDark : Colors.grey[100]!,
          child: Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Product description shimmer
        Shimmer.fromColors(
          baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.borderLight,
          highlightColor: isDarkMode ? AppColors.borderDark : Colors.grey[100]!,
          child: Container(
            height: 12,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
