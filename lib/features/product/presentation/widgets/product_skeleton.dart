import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';

class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Skeleton(height: 360, borderRadius: 0),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(width: 100, height: 14, borderRadius: 4),
                    const SizedBox(height: 10),
                    const Skeleton(
                      width: double.infinity,
                      height: 22,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    const Skeleton(width: 80, height: 14, borderRadius: 4),
                    const SizedBox(height: 20),
                    const Skeleton(width: 140, height: 28, borderRadius: 4),
                    const SizedBox(height: 24),
                    const Skeleton(height: 1, borderRadius: 0),
                    const SizedBox(height: 20),
                    ...List.generate(
                      4,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Skeleton(height: 14, borderRadius: 4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
