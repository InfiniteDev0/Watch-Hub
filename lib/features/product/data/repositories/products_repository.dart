import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/services/products_service.dart';

class ProductsRepository {
  final ProductsService _service;

  ProductsRepository({ProductsService? service})
    : _service = service ?? ProductsService();

  Future<List<ProductModel>> getProductsByBrand(String brandId) async {
    final data = await _service.fetchProducts(brandId: brandId);
    return data.map(ProductModel.fromJson).toList();
  }

  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 50,
  }) async {
    final data = await _service.fetchProducts(page: page, limit: limit);
    return data.map(ProductModel.fromJson).toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final data = await _service.fetchProductById(id);
    return ProductModel.fromJson(data);
  }
}
