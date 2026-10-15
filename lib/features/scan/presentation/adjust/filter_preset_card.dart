import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/scan_filter.dart';

class FilterPresetCard extends StatelessWidget {
  const FilterPresetCard({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.thumbnailBytes,
  });

  final ScanFilter filter;
  final bool isSelected;
  final VoidCallback onTap;
  final Uint8List? thumbnailBytes;

  static const double _cardSize = 72;
  static const double _badgeSize = 16;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _cardSize,
            height: _cardSize,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTint : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md - 1),
                    child: Image.memory(
                      thumbnailBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(),
                    ),
                  )
                else
                  const Center(
                    child: Icon(
                      LucideIcons.sparkles,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: AppSpacing.xs / 2,
                    right: AppSpacing.xs / 2,
                    child: Container(
                      width: _badgeSize,
                      height: _badgeSize,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.check,
                        size: 10,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            filter.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
