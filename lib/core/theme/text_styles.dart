import 'package:flutter/material.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
// Typography styles

/// Typography styles for the app
class AppTextStyles {
  AppTextStyles._();

  // ==================== HEADINGS ====================
  static TextStyle h1Light = const TextStyle(
    fontFamily: AppAssets.instrumentSans,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
    height: 1.2,
  );

  static TextStyle h1Dark = h1Light.copyWith(color: AppColors.textPrimaryDark);

  static TextStyle h2Light = const TextStyle(
    fontFamily: AppAssets.instrumentSans,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
    height: 1.3,
  );

  static TextStyle h2Dark = h2Light.copyWith(color: AppColors.textPrimaryDark);

  static TextStyle h3Light = const TextStyle(
    fontFamily: AppAssets.instrumentSans,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
    height: 1.4,
  );

  static TextStyle h3Dark = h3Light.copyWith(color: AppColors.textPrimaryDark);

  // ==================== BODY TEXT ====================
  static TextStyle bodyLight = const TextStyle(
    fontFamily: AppAssets.manrope,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  static TextStyle bodyDark = bodyLight.copyWith(
    color: AppColors.textPrimaryDark,
  );

  static TextStyle bodySmallLight = const TextStyle(
    fontFamily: AppAssets.manrope,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
    height: 1.5,
  );

  static TextStyle bodySmallDark = bodySmallLight.copyWith(
    color: AppColors.textSecondaryDark,
  );

  // ==================== BUTTON TEXT ====================
  static TextStyle buttonLight = const TextStyle(
    fontFamily: AppAssets.manrope,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static TextStyle buttonDark = buttonLight.copyWith(color: AppColors.black);

  // ==================== CAPTION / SUBTITLE ====================
  static TextStyle captionLight = const TextStyle(
    fontFamily: AppAssets.instrumentSerif,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
    height: 1.4,
  );

  static TextStyle captionDark = captionLight.copyWith(
    color: AppColors.textSecondaryDark,
  );

  // ==================== LOGO TEXT ====================
  static TextStyle logo = const TextStyle(
    fontFamily: AppAssets.instrumentSerif,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    letterSpacing: -1,
  );
}
