import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

/// A single stat tile used in the dashboard overview grid.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onView;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'View',
            size: ButtonSize.sm,
            width: 60,
            onPressed: onView,
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder shown while stats are loading.
class StatsGridSkeleton extends StatelessWidget {
  const StatsGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (_) => Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Skeleton(width: 36, height: 36, borderRadius: 8),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 60, height: 13, borderRadius: 4),
                    const SizedBox(height: 4),
                    Skeleton(width: 80, height: 20, borderRadius: 6),
                  ],
                ),
              ),
              Skeleton(width: 60, height: 32, borderRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2-column grid of [StatCard]s shown at the top of the dashboard.
class StatsGrid extends StatelessWidget {
  final int totalUsers;
  final int totalOrders;
  final int totalProducts;
  final double totalRevenue;
  final Function(int)? onNavigate; // Added navigation callback

  const StatsGrid({
    super.key,
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalRevenue,
    this.onNavigate, // Added this parameter
  });

  @override
  Widget build(BuildContext context) {
    void goTo(int index) {
      onNavigate?.call(index);
    }

    return Column(
      children: [
        StatCard(
          label: 'All Users',
          value: '$totalUsers',
          icon: Icons.people_outline,
          onView: () => goTo(3),
        ),
        StatCard(
          label: 'All Products',
          value: '$totalProducts',
          icon: Icons.watch_outlined,
          onView: () => goTo(1),
        ),
        StatCard(
          label: 'All Orders',
          value: '$totalOrders',
          icon: Icons.receipt_long_outlined,
          onView: () => goTo(2),
        ),
        StatCard(
          label: 'All Brands',
          value: '',
          icon: Icons.storefront_outlined,
          onView: () => goTo(4),
        ),
      ],
    );
  }
}
