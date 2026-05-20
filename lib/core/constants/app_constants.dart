// Other app-wide constants
/// App-wide constants
class AppConstants {
  AppConstants._();

  // ==================== GENERAL ====================
  static const int otpLength = 6; // Supabase sends 6-digit OTPs
  static const int otpExpirySeconds = 60; // 60-second resend cooldown

  // ==================== TOKEN STORAGE KEYS ====================
  static const String keyAccessToken = 'supabase_access_token';
  static const String keyRefreshToken = 'supabase_refresh_token';

  // ==================== ANIMATION DURATIONS ====================
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ==================== PADDING & SPACING ====================
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ==================== BORDER RADIUS ====================
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;

  // ==================== SHARED PREFERENCES KEYS ====================
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyThemeMode = 'theme_mode';
}
