// All color definitions for the app
import 'package:flutter/material.dart';

/// App Color Palette
/// Follows WatchHub's minimalist black & white design
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ==================== LIGHT MODE ====================
  static const Color primaryLight = Color(0xFF000000); // Black
  static const Color backgroundLight = Color(0xFFFAFAFA); // Off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color textPrimaryLight = Color(0xFF000000); // Black text
  static const Color textSecondaryLight = Color(0xFF757575); // Gray text
  static const Color borderLight = Color(0xFFE0E0E0); // Light gray border
  static const Color errorLight = Color(0xFFD32F2F); // Red for errors

  // ==================== DARK MODE ====================
  static const Color primaryDark = Color(0xFFFFFFFF); // White
  static const Color backgroundDark = Color(0xFF121212); // Dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Card background
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Light gray text
  static const Color borderDark = Color(0xFF333333); // Dark border
  static const Color errorDark = Color(0xFFEF5350); // Lighter red

  // ==================== COMMON ====================
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
