import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/scan_filter.dart';

class AdjustFilterRow extends StatelessWidget {
  const AdjustFilterRow({
    super.key,
    required this.currentFilterId,
    required this.onTapFilter,
  });

  final String currentFilterId;
  final VoidCallback onTapFilter;

  @override
  Widget build(BuildContext context) {
    final filter = ScanFilter.fromId(currentFilterId);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FILTER',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
          ),
          InkWell(
            onTap: onTapFilter,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.cameraControlBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.gridLine, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 14,
                    color: AppColors.textOnDarkMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
