import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Monitors network reachability and exposes [isOnline].
/// Notifies listeners whenever the connection status changes.
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;

  bool _isOnline = true; // optimistic default until first check
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    // Initial check
    final result = await _connectivity.checkConnectivity();
    _update(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
  }

  void _update(ConnectivityResult result) {
    final online = result != ConnectivityResult.none;
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  /// Re-check immediately — called by the "Try Again" button.
  Future<void> recheck() async {
    final result = await _connectivity.checkConnectivity();
    final online = result != ConnectivityResult.none;
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    } else if (!_isOnline) {
      // Force a notify so the UI refreshes even if status didn't change
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
