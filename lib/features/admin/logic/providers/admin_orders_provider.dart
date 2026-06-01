import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/models/admin_order_model.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';

class AdminOrdersProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminOrdersProvider(this._repo);

  List<AdminOrderModel> _all = [];
  String? _statusFilter;
  bool isLoading = false;
  bool isUpdating = false;
  bool _hasLoaded = false;

  // Two channels so a failed status update doesn't poison the list view.
  String? loadError;
  String? updateError;

  // Backwards-compat for any callers that still read `.error`.
  String? get error => loadError;
  bool get hasLoaded => _hasLoaded;

  String? get statusFilter => _statusFilter;

  List<AdminOrderModel> get orders {
    if (_statusFilter == null) return _all;
    return _all.where((o) => o.status == _statusFilter).toList();
  }

  Future<void> load() async {
    if (_all.isNotEmpty) return;
    await _fetch();
  }

  Future<void> reload() async => _fetch();

  Future<void> _fetch() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      _all = await _repo.getOrders(limit: 200);
      _hasLoaded = true;
    } catch (e) {
      loadError = _msg(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<AdminOrderModel?> getDetail(String id) async {
    try {
      return await _repo.getOrder(id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    isUpdating = true;
    updateError = null;
    notifyListeners();
    try {
      final updated = await _repo.updateOrderStatus(id, status);
      _all = _all.map((o) => o.id == id ? updated : o).toList();
      isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      updateError = _msg(e);
      isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  String _msg(Object e) {
    if (e is DioException) {
      final body = e.response?.data;
      if (body is Map && body['error'] != null) {
        return body['error'].toString();
      }
      if (body is String && body.isNotEmpty) return body;
      final code = e.response?.statusCode;
      if (code == 404) return 'Not found';
      if (code == 403) return 'Access denied';
      if (code == 401) return 'Sign in again';
      return e.message ?? 'Network error';
    }
    final s = e.toString();
    return s.startsWith('Exception:') ? s.substring(10).trim() : s;
  }
}
