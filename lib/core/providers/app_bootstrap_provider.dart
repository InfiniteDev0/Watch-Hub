import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/brands/data/repositories/brands_repository.dart';
import 'package:watch_hub/features/cart/logic/providers/cart_provider.dart';
import 'package:watch_hub/features/product/data/services/products_service.dart';
import 'package:watch_hub/features/wishlist/logic/providers/wishlist_provider.dart';

/// Coordinates the one-time data preload that runs while the splash
/// screen is visible. Everything below is fire-and-forget for the user;
/// the splash waits on [ready] before allowing navigation away.
class AppBootstrapProvider extends ChangeNotifier {
  AppBootstrapProvider({
    required WishlistProvider wishlist,
    required CartProvider cart,
  })  : _wishlist = wishlist,
        _cart = cart;

  final WishlistProvider _wishlist;
  final CartProvider _cart;
  final _brandsRepo = BrandsRepository();
  final _productsService = ProductsService();

  bool _ready = false;
  bool _running = false;
  bool get ready => _ready;

  /// Runs the preload for an authenticated session. Safe to call multiple
  /// times — only the first invocation does work.
  Future<void> preloadForUser() async {
    if (_ready || _running) return;
    _running = true;

    // Run all preloads in parallel; never let one failure stall the others.
    await Future.wait([
      _safe(_wishlist.fetchWishlist()),
      _safe(_cart.fetchCart()),
      _safe(_brandsRepo.getBrands()),
      _safe(_productsService.fetchProducts(limit: 20)),
    ]);

    _ready = true;
    _running = false;
    notifyListeners();
  }

  /// Lightweight preload for unauthenticated users — we still warm the
  /// product/brand caches so the home grid pops instantly post sign-in.
  Future<void> preloadGuest() async {
    if (_ready || _running) return;
    _running = true;
    await Future.wait([
      _safe(_brandsRepo.getBrands()),
      _safe(_productsService.fetchProducts(limit: 20)),
    ]);
    _ready = true;
    _running = false;
    notifyListeners();
  }

  /// Clear the ready flag — e.g. after sign-out so the next sign-in
  /// kicks the preload again.
  void reset() {
    _ready = false;
    _running = false;
    notifyListeners();
  }

  Future<void> _safe(Future<void> task) async {
    try {
      await task;
    } catch (_) {
      // Swallow — splash should never block on a transient API failure.
    }
  }
}
