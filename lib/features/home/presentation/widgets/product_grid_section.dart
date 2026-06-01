import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/home/data/models/product_filter.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/services/products_service.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_card.dart';
import 'package:watch_hub/features/wishlist/data/models/wishlist_model.dart';
import 'package:watch_hub/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:watch_hub/shared/widgets/shimmer_product_card.dart';

class ProductGridSection extends StatefulWidget {
  final ProductFilter filter;

  const ProductGridSection({
    super.key,
    this.filter = const ProductFilter.empty(),
  });

  @override
  State<ProductGridSection> createState() => _ProductGridSectionState();
}

class _ProductGridSectionState extends State<ProductGridSection> {
  final _service = ProductsService();
  List<ProductModel> _products = [];
  bool _loading = true;
  bool _refreshing = false;
  bool _initialLoad = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(ProductGridSection old) {
    super.didUpdateWidget(old);
    final f = widget.filter;
    final o = old.filter;
    if (f.brandId != o.brandId ||
        f.isNewArrival != o.isNewArrival ||
        f.isBestSeller != o.isBestSeller ||
        f.isFeatured != o.isFeatured) {
      _fetchProducts();
    } else if (f.sortByPrice != o.sortByPrice) {
      setState(() => _products = _sorted(_products, f.sortByPrice));
    }
  }

  Future<void> _fetchProducts() async {
    if (_initialLoad) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _refreshing = true;
        _error = null;
      });
    }
    try {
      final f = widget.filter;
      final raw = await _service.fetchProducts(
        limit: 20,
        brandId: f.brandId,
        isNewArrival: f.isNewArrival,
        isBestSeller: f.isBestSeller,
        isFeatured: f.isFeatured,
      );
      if (!mounted) return;
      setState(() {
        _products = _sorted(
          raw.map(ProductModel.fromJson).toList(),
          widget.filter.sortByPrice,
        );
        _loading = false;
        _refreshing = false;
        _initialLoad = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load products';
        _loading = false;
        _refreshing = false;
      });
    }
  }

  Future<void> _toggleWishlist(BuildContext context, ProductModel p) async {
    final wishlist = context.read<WishlistProvider>();

    if (wishlist.isInWishlist(p.id)) {
      final ok = await wishlist.removeFromWishlist(p.id);
      if (ok && context.mounted) {
        ToastHelper.showInfo(context, 'Removed from saved items');
      } else if (!ok && context.mounted) {
        ToastHelper.showError(context, 'Failed to remove item');
      }
    } else {
      final detailParts = [p.movementType, p.caseMaterial]
          .where((s) => s != null && s.isNotEmpty)
          .toList();
      final details =
          detailParts.isNotEmpty ? detailParts.join(' | ') : (p.sku ?? '');

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
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _fetchProducts,
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

    // Watch the wishlist so hearts reflect optimistic toggles instantly.
    // Each ProductCard is wrapped in RepaintBoundary so this rebuild is
    // cheap — only the changed heart icon repaints.
    final wishlist = context.watch<WishlistProvider>();

    Widget grid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Drawing slightly past the viewport keeps cards warm so a fling
      // doesn't expose blank tiles waiting to be built.
      cacheExtent: 600,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.58,
      ),
      itemCount: _loading ? 6 : _products.length,
      itemBuilder: (context, index) {
        if (_loading) return const ShimmerProductCard();
        final p = _products[index];
        return ProductCard(
          key: ValueKey(p.id),
          imageUrl: p.primaryImage ?? '',
          title: p.name,
          price: p.price,
          discountPrice: p.discountPrice,
          discountPercentage:
              p.hasDiscount ? p.discountPercent.toInt() : null,
          isNewArrival: p.isNewArrival,
          onTap: () => context.push('/products/${p.id}'),
          productId: p.id,
          isWishlisted: wishlist.isInWishlist(p.id),
          onWishlistTap: () => _toggleWishlist(context, p),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (_refreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: Colors.black,
            ),
          AnimatedOpacity(
            opacity: _refreshing ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: grid,
          ),
        ],
      ),
    );
  }

  List<ProductModel> _sorted(List<ProductModel> list, String? sortByPrice) {
    if (sortByPrice == null) return list;
    final sorted = List<ProductModel>.from(list);
    sorted.sort((a, b) {
      final aPrice = a.discountPrice ?? a.price;
      final bPrice = b.discountPrice ?? b.price;
      return sortByPrice == 'asc'
          ? aPrice.compareTo(bPrice)
          : bPrice.compareTo(aPrice);
    });
    return sorted;
  }
}
