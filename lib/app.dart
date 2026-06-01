import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/providers/app_bootstrap_provider.dart';
import 'package:watch_hub/core/providers/connectivity_provider.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/core/theme/app_theme.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/features/cart/logic/providers/cart_provider.dart';
import 'package:watch_hub/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:watch_hub/shared/screens/no_internet_screen.dart';

class WatchHubApp extends StatefulWidget {
  final AuthProvider authProvider;

  const WatchHubApp({super.key, required this.authProvider});

  @override
  State<WatchHubApp> createState() => _WatchHubAppState();
}

class _WatchHubAppState extends State<WatchHubApp> {
  late final _router = AppRouter.createRouter(widget.authProvider);
  bool? _wasLoggedIn;

  @override
  void initState() {
    super.initState();
    // Listen to auth transitions so we can clear/repopulate user-scoped
    // caches (wishlist, cart, bootstrap) exactly when sessions change.
    widget.authProvider.addListener(_onAuthChange);
    _wasLoggedIn = widget.authProvider.isLoggedIn;
  }

  @override
  void dispose() {
    widget.authProvider.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    final now = widget.authProvider.isLoggedIn;
    if (now == _wasLoggedIn) return;
    _wasLoggedIn = now;

    final wishlist = context.read<WishlistProvider>();
    final cart = context.read<CartProvider>();
    final bootstrap = context.read<AppBootstrapProvider>();

    if (now) {
      // Fresh sign-in — refetch personal data so likes/bag are accurate.
      bootstrap.reset();
      wishlist.fetchWishlist();
      cart.fetchCart();
    } else {
      // Signed out — wipe personal state so the next user starts clean.
      wishlist.clear();
      cart.clear();
      bootstrap.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WatchHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      // Overlay the no-internet screen on top of all routes when offline
      builder: (context, child) {
        return Consumer<ConnectivityProvider>(
          builder: (context, connectivity, _) {
            if (!connectivity.isOnline) {
              return const NoInternetScreen();
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
