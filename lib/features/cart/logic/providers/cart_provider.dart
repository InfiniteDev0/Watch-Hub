import 'package:flutter/material.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _repo;

  CartModel? _cart;
  bool _initialLoading = false;
  bool _isAdding = false;
  String? _error;

  CartProvider([CartRepository? repo]) : _repo = repo ?? CartRepository();

  CartModel? get cart => _cart;
  bool get initialLoading => _initialLoading;
  bool get loading => _isAdding; // product page button reads this
  String? get error => _error;
  int get itemCount => _cart?.itemCount ?? 0;

  // ── Fetch (skeleton on first open only) ──────────────────────────────────

  Future<void> fetchCart() async {
    if (_cart == null) {
      _initialLoading = true;
      notifyListeners();
    }
    try {
      _cart = await _repo.fetchCart();
      _error = null;
    } catch (e) {
      _error = _readable(e);
    } finally {
      _initialLoading = false;
      notifyListeners();
    }
  }

  // ── Add (full spinner — drives product page button) ──────────────────────

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    _isAdding = true;
    _error = null;
    notifyListeners();
    try {
      _cart = await _repo.addToCart(productId: productId, quantity: quantity);
    } catch (e) {
      _error = _readable(e);
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  // ── Update quantity (optimistic, ONE notify, no re-fetch) ────────────────
  //
  // The item StatefulWidget handles the instant visual via local state.
  // This method fires after a debounce, updates the provider's cart
  // optimistically, sends the PUT, and reverts only on failure.

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    final snapshot = _cart;
    _applyQtyUpdate(cartItemId, quantity); // instant provider update
    try {
      await _repo.updateCartItem(cartItemId: cartItemId, quantity: quantity);
      _error = null;
      // No extra notifyListeners — already fired by _applyQtyUpdate
    } catch (e) {
      _cart = snapshot;
      _error = _readable(e);
      notifyListeners(); // only fires on failure to show reverted state
    }
  }

  // ── Remove (optimistic) ──────────────────────────────────────────────────

  Future<void> removeCartItem(String cartItemId) async {
    final snapshot = _cart;
    _applyRemove(cartItemId);
    try {
      await _repo.removeCartItem(cartItemId);
      _error = null;
    } catch (e) {
      _cart = snapshot;
      _error = _readable(e);
      notifyListeners();
    }
  }

  // ── Clear (optimistic) ───────────────────────────────────────────────────

  Future<void> clearCart() async {
    final snapshot = _cart;
    _cart = CartModel(items: []);
    _error = null;
    notifyListeners();
    try {
      await _repo.clearCart();
    } catch (e) {
      _cart = snapshot;
      _error = _readable(e);
      notifyListeners();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _applyQtyUpdate(String itemId, int newQty) {
    if (_cart == null) return;
    _cart = CartModel(
      id: _cart!.id,
      items: _cart!.items
          .map((i) => i.id == itemId ? i.withQuantity(newQty) : i)
          .toList(),
    );
    notifyListeners();
  }

  void _applyRemove(String itemId) {
    if (_cart == null) return;
    _cart = CartModel(
      id: _cart!.id,
      items: _cart!.items.where((i) => i.id != itemId).toList(),
    );
    notifyListeners();
  }

  /// Drop all local state — used on sign-out so the next user doesn't
  /// inherit the previous user's bag.
  void clear() {
    _cart = null;
    _initialLoading = false;
    _isAdding = false;
    _error = null;
    notifyListeners();
  }

  String _readable(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception:') ? msg.substring(10).trim() : msg;
  }
}
