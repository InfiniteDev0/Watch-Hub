import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/models/admin_stats_model.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';

/// Drives the admin panel UI state.
/// Provided at the top of the admin shell so all admin screens share it.
class AdminProvider extends ChangeNotifier {
  final AdminRepository _repo;

  AdminProvider(this._repo);

  // ── Stats ──────────────────────────────────────────────────────
  AdminStatsModel? stats;
  bool isLoadingStats = false;

  Future<void> loadStats() async {
    isLoadingStats = true;
    notifyListeners();
    try {
      stats = await _repo.getStats();
    } catch (_) {
      // TODO: surface error state
    } finally {
      isLoadingStats = false;
      notifyListeners();
    }
  }

  // ── Users ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> users = [];
  bool isLoadingUsers = false;

  Future<void> loadUsers() async {
    isLoadingUsers = true;
    notifyListeners();
    try {
      users = await _repo.getUsers();
    } catch (_) {
    } finally {
      isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    await _repo.deleteUser(id);
    users.removeWhere((u) => u['id'] == id);
    notifyListeners();
  }

  // ── Products ────────────────────────────────────────────────────
  List<Map<String, dynamic>> products = [];
  bool isLoadingProducts = false;

  Future<void> loadProducts() async {
    isLoadingProducts = true;
    notifyListeners();
    try {
      products = await _repo.getProducts();
    } catch (_) {
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
    products.removeWhere((p) => p['id'] == id);
    notifyListeners();
  }

  // ── Brands ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> brands = [];
  bool isLoadingBrands = false;

  Future<void> loadBrands() async {
    isLoadingBrands = true;
    notifyListeners();
    try {
      brands = await _repo.getBrands();
    } catch (_) {
    } finally {
      isLoadingBrands = false;
      notifyListeners();
    }
  }

  Future<void> deleteBrand(String id) async {
    await _repo.deleteBrand(id);
    brands.removeWhere((b) => b['id'] == id);
    notifyListeners();
  }
}
