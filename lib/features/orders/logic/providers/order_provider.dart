import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo;

  OrderProvider([OrderRepository? repo]) : _repo = repo ?? OrderRepository();

  List<OrderModel> _orders = [];
  bool _initialLoading = false;
  bool _isPlacing = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get initialLoading => _initialLoading;
  bool get isPlacing => _isPlacing;
  String? get error => _error;

  // ── Fetch list (skeleton only on first open) ──────────────────────

  Future<void> fetchOrders() async {
    if (_orders.isEmpty) {
      _initialLoading = true;
      notifyListeners();
    }
    try {
      _orders = await _repo.fetchOrders();
      _error = null;
    } catch (e) {
      _error = _readable(e);
    } finally {
      _initialLoading = false;
      notifyListeners();
    }
  }

  // ── Place order from checkout ─────────────────────────────────────
  // Returns the created OrderModel on success, null on failure.

  Future<OrderModel?> placeOrder({
    required Map<String, dynamic> shippingAddress,
  }) async {
    _isPlacing = true;
    _error = null;
    notifyListeners();
    try {
      final order = await _repo.createOrder(shippingAddress: shippingAddress);
      _orders = [order, ..._orders];
      return order;
    } catch (e) {
      _error = _readable(e);
      return null;
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }

  // ── Cancel a pending order ────────────────────────────────────────

  Future<bool> cancelOrder(String orderId) async {
    try {
      final updated = await _repo.cancelOrder(orderId);
      _orders = _orders.map((o) => o.id == orderId ? updated : o).toList();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _readable(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _readable(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception:') ? msg.substring(10).trim() : msg;
  }
}
