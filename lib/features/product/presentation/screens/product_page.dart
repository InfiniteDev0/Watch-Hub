import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/services/products_service.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_add_to_cart_bar.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_description.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_image_gallery.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_info_section.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_reviews_section.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_skeleton.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_specs_section.dart';
import 'package:watch_hub/features/product/presentation/widgets/product_tags.dart';
import 'package:watch_hub/features/reviews/logic/providers/review_provider.dart';

class ProductPage extends StatefulWidget {
  final String productId;

  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _service = ProductsService();
  ProductModel? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rp = context.read<ReviewProvider>();
      rp.loadReviews(widget.productId);
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      if (isLoggedIn) rp.loadMyReview(widget.productId);
    });
  }

  Future<void> _fetch() async {
    try {
      final raw = await _service.fetchProductById(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = ProductModel.fromJson(raw);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load product';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _loading
            ? const ProductSkeleton()
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.black38),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _fetch();
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final p = _product!;
    final images = p.images.isNotEmpty
        ? p.images
        : (p.primaryImage != null ? [p.primaryImage!] : <String>[]);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              title: Column(
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontFamily: AppAssets.instrumentSerif,
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (p.sku != null)
                    Text(
                      p.sku!,
                      style: TextStyle(
                        fontFamily: AppAssets.manrope,
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {},
                ),
              ],
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageGallery(images: images),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.brandName != null)
                          Text(
                            p.brandName!.toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppAssets.manrope,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              letterSpacing: 1.5,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontFamily: AppAssets.instrumentSerif,
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ProductBadgeRow(product: p),
                        const SizedBox(height: 20),

                        ProductPriceRow(product: p),
                        const SizedBox(height: 20),

                        ProductAvailabilityBadge(product: p),
                        const SizedBox(height: 24),

                        const Divider(height: 1, color: Color(0xFFE5E5E5)),
                        const SizedBox(height: 24),

                        if (p.description != null &&
                            p.description!.isNotEmpty) ...[
                          ProductDescription(description: p.description!),
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          const SizedBox(height: 8),
                        ],

                        ProductSpecsSection(product: p),

                        if (p.tags.isNotEmpty) ...[
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          const SizedBox(height: 16),
                          ProductTags(tags: p.tags),
                          const SizedBox(height: 16),
                        ],

                        const Divider(height: 1, color: Color(0xFFE5E5E5)),
                        const SizedBox(height: 8),
                        ProductReviewsSection(productId: widget.productId),
                        const SizedBox(height: 16),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        ProductAddToCartBar(product: p),
      ],
    );
  }
}
