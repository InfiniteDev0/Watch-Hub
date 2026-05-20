import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/services/products_service.dart';

class SearchSheet extends StatefulWidget {
  final VoidCallback onClose;
  final FocusNode focusNode;

  const SearchSheet({
    super.key,
    required this.onClose,
    required this.focusNode,
  });

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final _controller = TextEditingController();
  final _brandsRepo = BrandsRepository();
  final _productsService = ProductsService();

  List<BrandModel> _allBrands = [];
  List<ProductModel> _popularProducts = [];
  List<BrandModel> _filteredBrands = [];
  List<ProductModel> _searchProducts = [];

  bool _loadingPopular = true;
  bool _searching = false;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPopular();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPopular() async {
    try {
      final results = await Future.wait([
        _brandsRepo.getBrands(),
        _productsService.fetchProducts(limit: 50),
      ]);
      if (!mounted) return;
      setState(() {
        _allBrands = results[0] as List<BrandModel>;
        _popularProducts = (results[1] as List<Map<String, dynamic>>)
            .map(ProductModel.fromJson)
            .toList();
        _loadingPopular = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPopular = false);
    }
  }

  void _onQueryChanged() {
    final q = _controller.text.trim();
    if (q == _query) return;
    setState(() => _query = q);

    _debounce?.cancel();
    if (q.isEmpty) {
      setState(() {
        _filteredBrands = [];
        _searchProducts = [];
        _searching = false;
      });
      return;
    }

    final lower = q.toLowerCase();

    // Filter brands & products from already-loaded data immediately
    setState(() {
      _filteredBrands = _allBrands
          .where((b) => b.name.toLowerCase().contains(lower))
          .toList();
      _searchProducts = _popularProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(lower) ||
                (p.brandName?.toLowerCase().contains(lower) ?? false),
          )
          .toList();
      _searching = false;
    });
  }

  void _goToBrand(BrandModel brand) {
    widget.onClose();
    context.push('/brands/${brand.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111111),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    SvgPicture.asset(
                      AppAssets.searchIcon,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: widget.focusNode,
                        autofocus: false,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search for a watch',
                          hintStyle: TextStyle(
                            fontFamily: AppAssets.instrumentSerif,
                            color: Colors.black54,
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () => _controller.clear(),
                      )
                    else
                      IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.closeIcon,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                        onPressed: widget.onClose,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: _query.isNotEmpty
                  ? _buildSuggestions()
                  : _buildDefaultContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Suggestions view (while typing) ──────────────────────────────
  Widget _buildSuggestions() {
    // Brand pills: brands matching query, else all brands
    final pillBrands = _filteredBrands.isNotEmpty
        ? _filteredBrands
        : _allBrands.take(6).toList();

    // Keyword suggestions: distinct product names containing query
    final suggestions = _popularProducts
        .map((p) => p.name)
        .where((n) => n.toLowerCase().contains(_query.toLowerCase()))
        .toSet()
        .take(5)
        .toList();

    final q = _query;
    final capitalQ = q.isEmpty ? q : q[0].toUpperCase() + q.substring(1);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── "Search [Query] In" + brand pills ───────────────────
        if (pillBrands.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Text(
              'Search $capitalQ In',
              style: const TextStyle(
                color: Colors.white38,
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: pillBrands.length,
              itemBuilder: (_, i) {
                final brand = pillBrands[i];
                return GestureDetector(
                  onTap: () => _goToBrand(brand),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      brand.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: AppAssets.manrope,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── "Suggested" keyword list ─────────────────────────────
        if (suggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Suggested',
              style: const TextStyle(
                color: Colors.white38,
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...suggestions.map(
            (name) => InkWell(
              onTap: () {
                _controller.text = name;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: name.length),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                child: _highlightedText(name, q),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── "Top Results For [Query]" product grid ───────────────
        if (_searching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white38,
                ),
              ),
            ),
          )
        else if (_searchProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Top Results For $capitalQ',
              style: const TextStyle(
                color: Colors.white38,
                fontFamily: AppAssets.manrope,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _searchProducts.take(6).map(_productCard).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ] else if (!_searching && suggestions.isEmpty && pillBrands.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                'No results for "$q"',
                style: const TextStyle(
                  color: Colors.white38,
                  fontFamily: AppAssets.manrope,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Default content (empty query) ─────────────────────────────────
  Widget _buildDefaultContent() {
    if (_loadingPopular) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white38,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Popular brands ───────────────────────────────────────
          _sectionLabel('Popular brands'),
          const SizedBox(height: 12),
          ..._allBrands.take(6).map(_brandRow),

          const SizedBox(height: 28),

          // ── Popular products ─────────────────────────────────────
          if (_popularProducts.isNotEmpty) ...[
            _sectionLabel('Popular Products'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _popularProducts.take(6).map(_productCard).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontFamily: AppAssets.instrumentSerif,
      fontSize: 18,
      color: Colors.white54,
    ),
  );

  /// Tappable brand row — used in default "Popular brands" section
  Widget _brandRow(BrandModel brand) => InkWell(
    onTap: () => _goToBrand(brand),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // logo thumbnail
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: brand.logoUrl!,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const SizedBox(),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              brand.name,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: AppAssets.manrope,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
        ],
      ),
    ),
  );

  /// Brand row used in suggestions list (typing state)
  Widget _brandSuggestionRow(BrandModel brand) => InkWell(
    onTap: () => _goToBrand(brand),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            color: Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(child: _highlightedText(brand.name, _query)),
          const Icon(Icons.north_west, color: Colors.white24, size: 14),
        ],
      ),
    ),
  );

  /// Product row used in suggestions list
  Widget _productSuggestionRow(ProductModel product) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        // small thumbnail
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.primaryImage != null
              ? CachedNetworkImage(
                  imageUrl: product.primaryImage!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox(),
                )
              : const SizedBox(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _highlightedText(product.name, _query),
              if (product.brandName != null)
                Text(
                  product.brandName!,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontFamily: AppAssets.manrope,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Text(
          '\$${product.price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white54,
            fontFamily: AppAssets.manrope,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  /// Product grid card — used in default "Popular products" section
  Widget _productCard(ProductModel product) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.primaryImage != null
              ? CachedNetworkImage(
                  imageUrl: product.primaryImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (_, __, ___) => const SizedBox(),
                )
              : const SizedBox(),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: AppAssets.manrope,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (product.brandName != null)
        Text(
          product.brandName!,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white38,
            fontFamily: AppAssets.manrope,
            fontSize: 11,
          ),
        ),
      const SizedBox(height: 2),
      Text(
        '\$${product.price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white70,
          fontFamily: AppAssets.manrope,
          fontSize: 13,
        ),
      ),
    ],
  );

  /// Renders text with the matching portion bold + white
  Widget _highlightedText(String text, String query) {
    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final start = lower.indexOf(qLower);
    if (start == -1) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: AppAssets.manrope,
          fontSize: 14,
        ),
      );
    }
    final end = start + query.length;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: AppAssets.manrope, fontSize: 14),
        children: [
          TextSpan(
            text: text.substring(0, start),
            style: const TextStyle(color: Colors.white60),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: text.substring(end),
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
