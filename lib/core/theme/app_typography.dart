import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static const textTheme = TextTheme(
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
}
