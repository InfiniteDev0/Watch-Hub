import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/models/admin_stats_model.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminDashboardProvider(this._repo);

  AdminStatsModel? stats;
  bool isLoading = false;
  String? error;

  Future<void> loadStats() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      stats = await _repo.getStats();
    } catch (e) {
      error = _msg(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _msg(Object e) {
    final s = e.toString();
    return s.startsWith('Exception:') ? s.substring(10).trim() : s;
  }
}
