import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';

class BrandsProvider extends ChangeNotifier {
  final BrandsRepository _repo;

  BrandsProvider(this._repo);

  List<BrandModel> brands = [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      brands = await _repo.getBrands();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
