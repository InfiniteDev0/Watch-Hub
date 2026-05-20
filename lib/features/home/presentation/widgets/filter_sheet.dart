import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/features/admin/presentation/widgets/skeleton.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/home/data/models/product_filter.dart';

class FilterSheet extends StatefulWidget {
  final ProductFilter current;
  final ValueChanged<ProductFilter> onApply;

  const FilterSheet({super.key, required this.current, required this.onApply});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ProductFilter _draft;
  final _brandsRepo = BrandsRepository();
  List<BrandModel> _brands = [];
  bool _loadingBrands = true;

  @override
  void initState() {
    super.initState();
    _draft = widget.current;
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _brandsRepo.getBrands();
      if (!mounted) return;
      setState(() {
        _brands = brands;
        _loadingBrands = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingBrands = false);
    }
  }

  void _reset() => setState(() => _draft = const ProductFilter.empty());

  void _applyAndClose() {
    widget.onApply(_draft);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 22),
              ),
              const Text(
                'Filter',
                style: TextStyle(
                  fontFamily: AppAssets.instrumentSerif,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: _reset,
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Brand section
          const Text(
            'Brand',
            style: TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _loadingBrands
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    5,
                    (_) =>
                        const Skeleton(width: 72, height: 36, borderRadius: 20),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BrandChip(
                      label: 'All',
                      selected: _draft.brandId == null,
                      onTap: () => setState(
                        () => _draft = _draft.copyWith(
                          brandId: null,
                          brandName: null,
                        ),
                      ),
                    ),
                    ..._brands.map(
                      (b) => _BrandChip(
                        label: b.name,
                        selected: _draft.brandId == b.id,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            brandId: b.id,
                            brandName: b.name,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 24),

          // Status section
          const Text(
            'Status',
            style: TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: 'All',
                selected:
                    _draft.isNewArrival == null &&
                    _draft.isBestSeller == null &&
                    _draft.isFeatured == null,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(
                    isNewArrival: null,
                    isBestSeller: null,
                    isFeatured: null,
                  );
                }),
              ),
              _StatusChip(
                label: 'New Arrival',
                selected: _draft.isNewArrival == true,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(
                    isNewArrival: _draft.isNewArrival == true ? null : true,
                    isBestSeller: null,
                    isFeatured: null,
                  );
                }),
              ),
              _StatusChip(
                label: 'Best Seller',
                selected: _draft.isBestSeller == true,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(
                    isBestSeller: _draft.isBestSeller == true ? null : true,
                    isNewArrival: null,
                    isFeatured: null,
                  );
                }),
              ),
              _StatusChip(
                label: 'Featured',
                selected: _draft.isFeatured == true,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(
                    isFeatured: _draft.isFeatured == true ? null : true,
                    isNewArrival: null,
                    isBestSeller: null,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sort by price section
          const Text(
            'Sort by Price',
            style: TextStyle(
              fontFamily: AppAssets.manrope,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BrandChip(
                label: 'Default',
                selected: _draft.sortByPrice == null,
                onTap: () =>
                    setState(() => _draft = _draft.copyWith(sortByPrice: null)),
              ),
              _BrandChip(
                label: 'Low to High',
                selected: _draft.sortByPrice == 'asc',
                onTap: () => setState(
                  () => _draft = _draft.copyWith(sortByPrice: 'asc'),
                ),
              ),
              _BrandChip(
                label: 'High to Low',
                selected: _draft.sortByPrice == 'desc',
                onTap: () => setState(
                  () => _draft = _draft.copyWith(sortByPrice: 'desc'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _applyAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontFamily: AppAssets.manrope,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BrandChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) =>
      _BrandChip(label: label, selected: selected, onTap: onTap);
}
