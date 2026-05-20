/// Sort order for price. `'asc'` = low→high, `'desc'` = high→low.
typedef PriceSortOrder = String;

class ProductFilter {
  final String? brandId;
  final String? brandName;
  final bool? isNewArrival;
  final bool? isBestSeller;
  final bool? isFeatured;

  /// `'asc'` | `'desc'` | null
  final String? sortByPrice;

  const ProductFilter({
    this.brandId,
    this.brandName,
    this.isNewArrival,
    this.isBestSeller,
    this.isFeatured,
    this.sortByPrice,
  });

  bool get isActive =>
      brandId != null ||
      isNewArrival != null ||
      isBestSeller != null ||
      isFeatured != null ||
      sortByPrice != null;

  int get activeCount {
    int n = 0;
    if (brandId != null) n++;
    if (isNewArrival != null) n++;
    if (isBestSeller != null) n++;
    if (isFeatured != null) n++;
    if (sortByPrice != null) n++;
    return n;
  }

  ProductFilter copyWith({
    Object? brandId = _sentinel,
    Object? brandName = _sentinel,
    Object? isNewArrival = _sentinel,
    Object? isBestSeller = _sentinel,
    Object? isFeatured = _sentinel,
    Object? sortByPrice = _sentinel,
  }) {
    return ProductFilter(
      brandId: brandId == _sentinel ? this.brandId : brandId as String?,
      brandName: brandName == _sentinel ? this.brandName : brandName as String?,
      isNewArrival: isNewArrival == _sentinel
          ? this.isNewArrival
          : isNewArrival as bool?,
      isBestSeller: isBestSeller == _sentinel
          ? this.isBestSeller
          : isBestSeller as bool?,
      isFeatured: isFeatured == _sentinel
          ? this.isFeatured
          : isFeatured as bool?,
      sortByPrice: sortByPrice == _sentinel
          ? this.sortByPrice
          : sortByPrice as String?,
    );
  }

  const ProductFilter.empty()
    : brandId = null,
      brandName = null,
      isNewArrival = null,
      isBestSeller = null,
      isFeatured = null,
      sortByPrice = null;
}

const _sentinel = Object();
