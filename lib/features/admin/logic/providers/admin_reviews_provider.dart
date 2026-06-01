import 'package:flutter/foundation.dart';
import 'package:watch_hub/features/admin/data/models/admin_review_model.dart';
import 'package:watch_hub/features/admin/data/repositories/admin_repository.dart';

class AdminReviewsProvider extends ChangeNotifier {
  final AdminRepository _repo;
  AdminReviewsProvider(this._repo);

  List<AdminReviewModel> _all = [];
  bool isLoading = false;
  String? error;

  List<AdminReviewModel> get reviews => _all;

  Future<void> load() async {
    if (_all.isNotEmpty) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _repo.getReviews(limit: 200);
    } catch (e) {
      error = _msg(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _all = [];
    await load();
  }

  Future<bool> delete(String reviewId) async {
    try {
      await _repo.deleteReview(reviewId);
      _all = _all.where((r) => r.id != reviewId).toList();
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
