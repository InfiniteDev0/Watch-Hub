import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/brands/logic/providers/brands_provider.dart';
import 'package:watch_hub/features/brands/presentation/widgets/brand_card.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrandsProvider(BrandsRepository())..load(),
      child: const _BrandsView(),
    );
  }
}

class _BrandsView extends StatelessWidget {
  const _BrandsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Brands',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<BrandsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _BrandListSkeleton();
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      size: 40,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.read<BrandsProvider>().load(),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.brands.isEmpty) {
            return const Center(
              child: Text(
                'No brands available yet.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.brands.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.black, thickness: 1.5, height: 32),
            itemBuilder: (context, index) => BrandCard(
              brand: provider.brands[index],
              onTap: () => context.push('/brands/${provider.brands[index].id}'),
            ),
          );
        },
      ),
    );
  }
}

class _BrandListSkeleton extends StatelessWidget {
  const _BrandListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const BrandCardSkeleton();
  }
}
