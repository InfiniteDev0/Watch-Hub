import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/repositories/products_repository.dart';

/// Drives the brand detail screen — loads the brand and its products in parallel.
class BrandDetailProvider extends ChangeNotifier {
  final BrandsRepository _brandsRepo;
  final ProductsRepository _productsRepo;

  BrandDetailProvider(this._brandsRepo, this._productsRepo);

  BrandModel? brand;
  List<ProductModel> products = [];
  bool isLoading = false;
  String? error;

  Future<void> load(String brandId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _brandsRepo.getBrandById(brandId),
        _productsRepo.getProductsByBrand(brandId),
      ]);
      brand = results[0] as BrandModel;
      products = results[1] as List<ProductModel>;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
