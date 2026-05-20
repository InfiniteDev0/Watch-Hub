import 'package:flutter_dotenv/flutter_dotenv.dart';

/// All API endpoint constants
class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:4000';

  // ==================== AUTH ENDPOINTS ====================
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authLogout = '/api/auth/logout';
  static const String authResetPassword = '/api/auth/reset-password';

  // ==================== USER ENDPOINTS ====================
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';
  static String userAddresses(String id) => '/api/users/$id/addresses';
  static String userAddress(String userId, String addressId) =>
      '/api/users/$userId/addresses/$addressId';

  // ==================== ORDER ENDPOINTS ====================
  static const String orders = '/api/orders';
  static String orderById(String id) => '/api/orders/$id';
  static String cancelOrder(String id) => '/api/orders/$id/cancel';

  // ==================== REVIEW ENDPOINTS ====================
  static String productReviews(String productId) =>
      '/api/reviews/product/$productId';
  static String myProductReview(String productId) =>
      '/api/reviews/product/$productId/mine';
  static String deleteReview(String reviewId) => '/api/reviews/$reviewId';

  // ==================== CONTACT ENDPOINT ====================
  static const String contact = '/api/contact';

  // ==================== TIMEOUTS ====================
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
