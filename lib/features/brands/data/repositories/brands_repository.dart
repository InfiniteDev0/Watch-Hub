import 'package:watch_hub/features/brands/data/models/brand_model.dart';
import 'package:watch_hub/features/brands/data/services/brands_service.dart';

class BrandsRepository {
  final BrandsService _service;

  BrandsRepository({BrandsService? service})
    : _service = service ?? BrandsService();

  Future<List<BrandModel>> getBrands() async {
    final data = await _service.fetchAllBrands();
    return data.map(BrandModel.fromJson).toList();
  }

  Future<BrandModel> getBrandById(String id) async {
    final data = await _service.fetchBrandById(id);
    return BrandModel.fromJson(data);
  }
}
