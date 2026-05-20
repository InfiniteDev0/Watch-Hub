import 'package:dio/dio.dart';
import 'package:watch_hub/core/network/api_client.dart';
import 'package:watch_hub/core/network/api_constants.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final Dio _dio = ApiClient.dio;

  Future<({List<ReviewModel> reviews, ReviewSummary summary})> fetchReviews(
    String productId,
  ) async {
    final res = await _dio.get(ApiConstants.productReviews(productId));
    final data = res.data as Map<String, dynamic>;
    final reviews = (data['reviews'] as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final summary = ReviewSummary.fromJson(
      data['summary'] as Map<String, dynamic>,
    );
    return (reviews: reviews, summary: summary);
  }

  Future<ReviewModel?> fetchMyReview(String productId) async {
    final res = await _dio.get(ApiConstants.myProductReview(productId));
    if (res.data == null) return null;
    return ReviewModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ReviewModel> submitReview(
    String productId, {
    required int rating,
    String? title,
    String? body,
  }) async {
    final res = await _dio.post(
      ApiConstants.productReviews(productId),
      data: {'rating': rating, 'title': title, 'body': body},
    );
    return ReviewModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete(ApiConstants.deleteReview(reviewId));
  }
}
