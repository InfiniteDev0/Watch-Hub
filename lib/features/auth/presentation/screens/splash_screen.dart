// Splash screen — validates the cached auth session AND warms the data
// caches (products, brands, wishlist, cart) so the home screen renders
// fully populated the moment the splash dismisses.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/providers/app_bootstrap_provider.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Minimum time the splash stays on-screen so it doesn't flash for users
  // on fast networks — gives the loader a chance to feel intentional.
  static const _minSplashDuration = Duration(milliseconds: 1100);

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final bootstrap = context.read<AppBootstrapProvider>();
    final stopwatch = Stopwatch()..start();

    // 1. Wait for auth to finish its server-side session check.
    await _waitForAuthInit(auth);
    if (!mounted) return;

    // 2. Kick off the data prefetch and wait for it (or auth flips away).
    if (auth.isLoggedIn) {
      await bootstrap.preloadForUser();
    } else {
      await bootstrap.preloadGuest();
    }
    if (!mounted) return;

    // 3. Honour the minimum splash duration so the transition feels smooth.
    final elapsed = stopwatch.elapsed;
    if (elapsed < _minSplashDuration) {
      await Future.delayed(_minSplashDuration - elapsed);
    }
    if (!mounted || _navigated) return;

    _navigated = true;
    _goNext(auth);
  }

  Future<void> _waitForAuthInit(AuthProvider auth) async {
    if (auth.isInitialized) return;
    final completer = _AuthInitWaiter(auth);
    await completer.future;
  }

  void _goNext(AuthProvider auth) {
    final String destination;
    if (!auth.isLoggedIn) {
      destination = AppRouter.onboarding;
    } else if (auth.isAdmin) {
      destination = AppRouter.admin;
    } else {
      destination = AppRouter.home;
    }
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
      body: Stack(
        children: [
          Center(
            child: Text(
              'Watch Hub',
              style: TextStyle(
                fontFamily: AppAssets.instrumentSerif,
                fontSize: 42,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bridges the [AuthProvider] ChangeNotifier into a Future so we can
/// `await` the very first `isInitialized = true` notification.
class _AuthInitWaiter {
  _AuthInitWaiter(this._auth) {
    if (_auth.isInitialized) {
      _completer.complete();
      return;
    }
    _auth.addListener(_onChange);
  }

  final AuthProvider _auth;
  final _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void _onChange() {
    if (_auth.isInitialized && !_completer.isCompleted) {
      _auth.removeListener(_onChange);
      _completer.complete();
    }
  }
}
