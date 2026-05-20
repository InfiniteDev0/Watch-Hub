import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/brands/logic/providers/brand_detail_provider.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/repositories/products_repository.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_card.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/wishlist/data/models/wishlist_model.dart';
import 'package:watch_hub/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:watch_hub/shared/widgets/breadcrumbs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BrandDetailScreen extends StatelessWidget {
  final String brandId;

  const BrandDetailScreen({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BrandDetailProvider(BrandsRepository(), ProductsRepository())
            ..load(brandId),
      child: const _BrandDetailView(),
    );
  }
}

class _BrandDetailView extends StatelessWidget {
  const _BrandDetailView();

  @override
  Widget build(BuildContext context) {
    return Consumer<BrandDetailProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: provider.brand != null
                ? Text(
                    provider.brand!.name,
                    style: const TextStyle(
                      fontFamily: AppAssets.instrumentSerif,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          body: provider.isLoading
              ? const _BrandDetailSkeleton()
              : provider.error != null
              ? _ErrorView(
                  message: provider.error!,
                  onRetry: () => context.read<BrandDetailProvider>().load(
                    context.read<BrandDetailProvider>().brand?.id ?? '',
                  ),
                )
              : _BrandDetailContent(
                  brand: provider.brand!,
                  products: provider.products,
                ),
        );
      },
    );
  }
}

class _BrandDetailContent extends StatelessWidget {
  final BrandModel brand;
  final List<ProductModel> products;

  const _BrandDetailContent({required this.brand, required this.products});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Breadcrumb(
              children: [
                BreadcrumbLink(label: 'Brands', onTap: () => context.pop()),
                const BreadcrumbSeparator(),
                BreadcrumbPage(label: brand.name),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (brand.bannerUrl != null && brand.bannerUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: brand.bannerUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Skeleton(
                        width: double.infinity,
                        height: 160,
                        borderRadius: 12,
                      ),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      brand.name,
                      style: const TextStyle(
                        fontFamily: AppAssets.instrumentSerif,
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${products.length} item${products.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                if (brand.description != null &&
                    brand.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    brand.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(color: Colors.black12),
              ],
            ),
          ),
        ),

        if (products.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text(
                  'No products available for this brand yet.',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
              children: products
                  .map((p) => _WishlistProductCard(product: p))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// Each card watches WishlistProvider in its own build() — avoids stale
// provider references captured inside map() closures.
class _WishlistProductCard extends StatelessWidget {
  final ProductModel product;
  const _WishlistProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final p = product;

    final detailParts = [p.movementType, p.caseMaterial]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    final details =
        detailParts.isNotEmpty ? detailParts.join(' | ') : (p.sku ?? '');

    return ProductCard(
      imageUrl: p.primaryImage ?? '',
      title: p.name,
      price: p.price,
      discountPrice: p.discountPrice,
      discountPercentage: p.hasDiscount ? p.discountPercent.toInt() : null,
      isNewArrival: p.isNewArrival,
      onTap: () => context.push('/products/${p.id}'),
      productId: p.id,
      isWishlisted: wishlist.isInWishlist(p.id),
      onWishlistTap: () async {
        if (wishlist.isInWishlist(p.id)) {
          final ok = await wishlist.removeFromWishlist(p.id);
          if (ok && context.mounted) {
            ToastHelper.showInfo(context, 'Removed from saved items');
          } else if (!ok && context.mounted) {
            ToastHelper.showError(context, 'Failed to remove item');
          }
        } else {
          final ok = await wishlist.addToWishlist(WishlistItemModel(
            id: 'opt_${p.id}',
            productId: p.id,
            name: p.name,
            imageUrl: p.primaryImage,
            details: details,
            price: p.discountPrice ?? p.price,
          ));
          if (ok && context.mounted) {
            ToastHelper.showSuccess(context, 'Added to saved items');
          } else if (!ok && context.mounted) {
            ToastHelper.showError(context, 'Failed to save item');
          }
        }
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandDetailSkeleton extends StatelessWidget {
  const _BrandDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(width: 140, height: 14),
          const SizedBox(height: 16),
          const Skeleton(width: 200, height: 36, borderRadius: 6),
          const SizedBox(height: 8),
          const Skeleton(width: double.infinity, height: 14),
          const SizedBox(height: 4),
          const Skeleton(width: 260, height: 14),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
              children: List.generate(
                6,
                (_) => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Skeleton(
                          width: double.infinity, borderRadius: 4),
                    ),
                    SizedBox(height: 8),
                    Skeleton(width: double.infinity, height: 13),
                    SizedBox(height: 4),
                    Skeleton(width: 80, height: 13),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
