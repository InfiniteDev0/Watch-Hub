import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/repositories/products_repository.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _repo = ProductsRepository();
  List<ProductModel> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await _repo.getAllProducts(limit: 100);
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

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
                    'Products',
                    style: TextStyle(
                      fontFamily: AppAssets.instrumentSerif,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: navigate to add product
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
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildSkeleton();

    if (_error != null) {
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
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetch,
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Text(
          'No products yet.',
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _products.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (context, index) =>
          _ProductAdminTile(product: _products[index]),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Skeleton(width: 56, height: 56, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 160, height: 14),
                  const SizedBox(height: 6),
                  Skeleton(width: 100, height: 12),
                  const SizedBox(height: 6),
                  Skeleton(width: 80, height: 12),
                ],
              ),
            ),
            Skeleton(width: 60, height: 24, borderRadius: 6),
          ],
        ),
      ),
    );
  }
}

class _ProductAdminTile extends StatelessWidget {
  final ProductModel product;

  const _ProductAdminTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.primaryImage != null
                ? CachedNetworkImage(
                    imageUrl: product.primaryImage!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imagePlaceholder(),
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (product.brandName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    product.brandName!,
                    style: const TextStyle(
                      fontFamily: AppAssets.manrope,
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  product.hasDiscount
                      ? '\$${product.discountPrice!.toStringAsFixed(2)}'
                      : '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Stock badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: inStock
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              inStock ? 'In Stock' : 'Out',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: inStock
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: const Color(0xFFE0E0E0),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.watch, color: Colors.white54, size: 24),
  );
}
