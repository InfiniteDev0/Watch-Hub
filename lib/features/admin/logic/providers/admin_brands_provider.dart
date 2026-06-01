import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';
import 'package:watch_hub/features/brands/data/models/brand_model.dart';

class AdminBrandsProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminBrandsProvider(this._repo);

  List<BrandModel> _all = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  List<BrandModel> get brands => _all;

  Future<void> load() async {
    if (_all.isNotEmpty) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _repo.getBrands();
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

  Future<bool> create(Map<String, dynamic> data) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final created = await _repo.createBrand(data);
      _all = [created, ..._all];
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
      final updated = await _repo.updateBrand(id, data);
      _all = _all.map((b) => b.id == id ? updated : b).toList();
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
      await _repo.deleteBrand(id);
      _all = _all.where((b) => b.id != id).toList();
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
