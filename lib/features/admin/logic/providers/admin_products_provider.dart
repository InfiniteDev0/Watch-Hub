import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';
import 'package:watch_hub/features/product/data/models/products_model.dart';
import 'package:watch_hub/features/product/data/services/products_service.dart';

class AdminProductsProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminProductsProvider(this._repo);

  List<ProductModel> _all = [];
  List<ProductModel> _filtered = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  String _query = '';

  List<ProductModel> get products => _query.isEmpty ? _all : _filtered;

  Future<void> load() async {
    if (_all.isNotEmpty) {
      _applyFilter();
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _repo.getProducts(limit: 200);
      _applyFilter();
    } catch (e) {
      error = _msg(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _all = [];
    await load();
  }

  void search(String query) {
    _query = query.toLowerCase().trim();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_query.isEmpty) {
      _filtered = _all;
      return;
    }
    _filtered = _all
        .where((p) =>
            p.name.toLowerCase().contains(_query) ||
            (p.brandName?.toLowerCase().contains(_query) ?? false) ||
            (p.sku?.toLowerCase().contains(_query) ?? false))
        .toList();
  }

  Future<bool> create(Map<String, dynamic> data) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final created = await _repo.createProduct(data);
      _all = [created, ..._all];
      _applyFilter();
      ProductsService.invalidateCache();
      return true;
    } catch (e) {
      error = _msg(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final updated = await _repo.updateProduct(id, data);
      _all = _all.map((p) => p.id == id ? updated : p).toList();
      _applyFilter();
      ProductsService.invalidateCache();
      return true;
    } catch (e) {
      error = _msg(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repo.deleteProduct(id);
      _all = _all.where((p) => p.id != id).toList();
      _applyFilter();
      ProductsService.invalidateCache();
      notifyListeners();
      return true;
    } catch (e) {
      error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  String _msg(Object e) {
    final s = e.toString();
    return s.startsWith('Exception:') ? s.substring(10).trim() : s;
  }
}
