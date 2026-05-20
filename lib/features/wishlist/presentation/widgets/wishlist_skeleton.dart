import 'package:flutter/material.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';

class WishlistSkeleton extends StatelessWidget {
  const WishlistSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: 3,
      separatorBuilder: (_, __) =>
          const Divider(height: 28, color: Color(0xFFF0F0F0)),
      itemBuilder: (_, __) => const _SkeletonRow(),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(width: 100, height: 110, borderRadius: 8),
        SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: double.infinity, height: 16),
                SizedBox(height: 8),
                Skeleton(width: 120, height: 13),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 80, height: 16),
                    Skeleton(width: 100, height: 32, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
