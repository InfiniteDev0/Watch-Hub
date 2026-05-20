import 'package:flutter/foundation.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

enum ReviewSort { newest, highestRating, lowestRating }

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repo;

  ReviewProvider([ReviewRepository? repo]) : _repo = repo ?? ReviewRepository();

  // ── State ──────────────────────────────────────────────────────
  String? _currentProductId;
  List<ReviewModel> _reviews = [];
  ReviewSummary _summary = ReviewSummary.empty();
  ReviewModel? _myReview;

  bool _loading = false;
  bool _submitting = false;
  String? _error;
  String? _submitError;
  ReviewSort _sort = ReviewSort.newest;

  // ── Getters ────────────────────────────────────────────────────
  List<ReviewModel> get reviews => _sortedReviews();
  ReviewSummary get summary => _summary;
  ReviewModel? get myReview => _myReview;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;
  String? get submitError => _submitError;
  ReviewSort get sort => _sort;

  void setSort(ReviewSort s) {
    _sort = s;
    notifyListeners();
  }

  List<ReviewModel> _sortedReviews() {
    final list = List<ReviewModel>.from(_reviews);
    switch (_sort) {
      case ReviewSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ReviewSort.highestRating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case ReviewSort.lowestRating:
        list.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return list;
  }

  // ── Load ───────────────────────────────────────────────────────

  Future<void> loadReviews(String productId) async {
    // Skip if same product already loaded
    if (_currentProductId == productId && _reviews.isNotEmpty) return;

    _currentProductId = productId;
    _loading = true;
    _error = null;
    _myReview = null;
    notifyListeners();

    try {
      final result = await _repo.fetchReviews(productId);
      _reviews = result.reviews;
      _summary = result.summary;
      _error = null;
    } catch (e) {
      _error = _readable(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyReview(String productId) async {
    try {
      _myReview = await _repo.fetchMyReview(productId);
      notifyListeners();
    } catch (_) {
      // Silently fail — user may not be logged in
    }
  }

  // ── Submit (upsert) ─────────────────────────────────────────────

  Future<bool> submitReview(
    String productId, {
    required int rating,
    String? title,
    String? body,
  }) async {
    _submitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final submitted = await _repo.submitReview(
        productId,
        rating: rating,
        title: title,
        body: body,
      );

      // Update or insert into local list
      final existingIdx = _reviews.indexWhere((r) => r.id == submitted.id);
      if (existingIdx >= 0) {
        _reviews[existingIdx] = submitted;
      } else {
        _reviews.insert(0, submitted);
      }

      _myReview = submitted;

      // Recompute summary locally
      _recomputeSummary();
      return true;
    } catch (e) {
      _submitError = _readable(e);
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  // ── Delete ──────────────────────────────────────────────────────

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _repo.deleteReview(reviewId);
      _reviews.removeWhere((r) => r.id == reviewId);
      _myReview = null;
      _recomputeSummary();
      notifyListeners();
      return true;
    } catch (e) {
      _submitError = _readable(e);
      notifyListeners();
      return false;
    }
  }

  // ── Reset when navigating away ──────────────────────────────────

  void resetForProduct(String productId) {
    if (_currentProductId != productId) {
      _currentProductId = null;
      _reviews = [];
      _summary = ReviewSummary.empty();
      _myReview = null;
      _error = null;
      _submitError = null;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────

  void _recomputeSummary() {
    if (_reviews.isEmpty) {
      _summary = ReviewSummary.empty();
      return;
    }
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    double sum = 0;
    for (final r in _reviews) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
      sum += r.rating;
    }
    _summary = ReviewSummary(
      average: double.parse((sum / _reviews.length).toStringAsFixed(1)),
      total: _reviews.length,
      distribution: dist,
    );
  }

  String _readable(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception:') ? msg.substring(10).trim() : msg;
  }
}
