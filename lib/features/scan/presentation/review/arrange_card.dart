import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class ArrangeCard extends StatelessWidget {
  const ArrangeCard({
    super.key,
    required this.previewPath,
    required this.number,
    this.isDragging = false,
  });

  final String previewPath;
  final int number;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDragging ? AppColors.primary : AppColors.divider,
          width: isDragging ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: isDragging ? 0.2 : 0.06),
            blurRadius: isDragging ? 16 : 8,
            offset: Offset(0, isDragging ? 6 : 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.file(
                File(previewPath),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.pageBackdrop),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDragging ? AppColors.primary : AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textOnDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
