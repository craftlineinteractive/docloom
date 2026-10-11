import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppTypography.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.danger,
        ),
        textTheme: AppTypography.textTheme,
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.switchOff;
          }),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.md),
            ),
          ),
        ),
      );
}
