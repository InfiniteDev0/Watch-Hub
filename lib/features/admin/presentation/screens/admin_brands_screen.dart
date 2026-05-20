import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/brands/logic/providers/brands_provider.dart';
import 'package:watch_hub/features/brands/presentation/widgets/brand_card.dart';

class AdminBrandsScreen extends StatelessWidget {
  const AdminBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrandsProvider(BrandsRepository())..load(),
      child: const _AdminBrandsView(),
    );
  }
}

class _AdminBrandsView extends StatelessWidget {
  const _AdminBrandsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Brands',
                    style: TextStyle(
                      fontFamily: AppAssets.instrumentSerif,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: navigate to add brand
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<BrandsProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const BrandCardSkeleton();
                    }

                    if (provider.error != null) {
                      return Center(
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
                              onPressed: () =>
                                  context.read<BrandsProvider>().load(),
                              child: const Text(
                                'Retry',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.brands.isEmpty) {
                      return Center(
                        child: Text(
                          'No brands yet.',
                          style: TextStyle(
                            fontFamily: AppAssets.manrope,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.brands.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Colors.black,
                        thickness: 1.5,
                        height: 32,
                      ),
                      itemBuilder: (context, index) =>
                          BrandCard(brand: provider.brands[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
