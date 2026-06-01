import 'package:flutter/material.dart';
import '../../data/models/wishlist_model.dart';
import '../../data/repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _repo;

  List<WishlistItemModel> _items = [];
  final Set<String> _productIds = {};
  bool _initialLoading = false;
  String? _error;

  WishlistProvider([WishlistRepository? repo])
      : _repo = repo ?? WishlistRepository();

  List<WishlistItemModel> get items => List.unmodifiable(_items);
  bool get initialLoading => _initialLoading;
  String? get error => _error;
  int get count => _items.length;

  /// Read-only view of the wishlisted product ids. Exposed so consumers
  /// (e.g. the product grid) can `context.select` on just this set and
  /// avoid rebuilding when other wishlist state changes.
  Set<String> get wishlistedIds => Set.unmodifiable(_productIds);

  bool isInWishlist(String productId) => _productIds.contains(productId);

  // ── Fetch ─────────────────────────────────────────────────────────────────
  // Shows skeleton only on the first load; silent refresh afterwards.

  Future<void> fetchWishlist() async {
    if (_items.isEmpty) {
      _initialLoading = true;
      notifyListeners();
    }
    try {
      final fetched = await _repo.fetchWishlist();
      _items = fetched;
      _productIds
        ..clear()
        ..addAll(_items.map((i) => i.productId));
      _error = null;
    } catch (e) {
      _error = _readable(e);
    } finally {
      _initialLoading = false;
      notifyListeners();
    }
  }

  // ── Add (optimistic) ──────────────────────────────────────────────────────
  // Returns true on success, false on failure (caller shows toast accordingly).

  Future<bool> addToWishlist(WishlistItemModel optimistic) async {
    if (_productIds.contains(optimistic.productId)) return true;

    // Instantly update UI
    _items = [optimistic, ..._items];
    _productIds.add(optimistic.productId);
    _error = null;
    notifyListeners();

    try {
      final confirmed = await _repo.addToWishlist(optimistic.productId);
      // Swap temporary item with server-confirmed item (real UUID)
      _items = _items
          .map((i) => i.productId == optimistic.productId ? confirmed : i)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      // Revert on failure
      _items = _items
          .where((i) => i.productId != optimistic.productId)
          .toList();
      _productIds.remove(optimistic.productId);
      _error = _readable(e);
      notifyListeners();
      return false;
    }
  }

  // ── Remove (optimistic) ───────────────────────────────────────────────────

  Future<bool> removeFromWishlist(String productId) async {
    final snapshot = List<WishlistItemModel>.from(_items);
    _items = _items.where((i) => i.productId != productId).toList();
    _productIds.remove(productId);
    _error = null;
    notifyListeners();

    try {
      await _repo.removeFromWishlist(productId);
      return true;
    } catch (e) {
      _items = snapshot;
      _productIds.add(productId);
      _error = _readable(e);
      notifyListeners();
      return false;
    }
  }

  /// Drop all local state — used on sign-out so the next user doesn't
  /// see the previous user's saved items leak through.
  void clear() {
    _items = [];
    _productIds.clear();
    _initialLoading = false;
    _error = null;
    notifyListeners();
  }

  String _readable(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception:') ? msg.substring(10).trim() : msg;
  }
}
