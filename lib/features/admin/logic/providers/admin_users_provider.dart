import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/models/admin_user_model.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';

class AdminUsersProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminUsersProvider(this._repo);

  List<AdminUserModel> _all = [];
  List<AdminUserModel> _filtered = [];
  bool isLoading = false;
  String? error;
  String _query = '';

  List<AdminUserModel> get users => _query.isEmpty ? _all : _filtered;

  Future<void> load() async {
    if (_all.isNotEmpty) {
      _applyFilter();
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _repo.getUsers();
      _applyFilter();
    } catch (e) {
      error = _msg(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
        .where((u) =>
            (u.fullName?.toLowerCase().contains(_query) ?? false) ||
            u.id.contains(_query))
        .toList();
  }

  Future<bool> changeRole(String userId, String role) async {
    try {
      await _repo.updateUserRole(userId, role);
      _all = _all.map((u) {
        if (u.id != userId) return u;
        return AdminUserModel(
          id: u.id,
          fullName: u.fullName,
          phone: u.phone,
          avatarUrl: u.avatarUrl,
          role: role,
          createdAt: u.createdAt,
        );
      }).toList();
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String userId) async {
    try {
      await _repo.deleteUser(userId);
      _all = _all.where((u) => u.id != userId).toList();
      _applyFilter();
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
