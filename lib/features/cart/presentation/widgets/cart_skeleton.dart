import 'package:flutter/material.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';

class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: 3,
            separatorBuilder: (_, __) =>
                const Divider(height: 32, color: Color(0xFFF0F0F0)),
            itemBuilder: (_, __) => const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 100, height: 110, borderRadius: 8),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Skeleton(width: 180, height: 15, borderRadius: 4),
                      SizedBox(height: 8),
                      Skeleton(width: 120, height: 12, borderRadius: 4),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Skeleton(width: 64, height: 15, borderRadius: 4),
                          Skeleton(width: 88, height: 32, borderRadius: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
          ),
          child: const Column(
            children: [
              Skeleton(height: 16, borderRadius: 4),
              SizedBox(height: 10),
              Skeleton(height: 16, borderRadius: 4),
              SizedBox(height: 20),
              Skeleton(height: 54, borderRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}
