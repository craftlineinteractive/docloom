import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

class AdjustTopBar extends StatelessWidget {
  const AdjustTopBar({
    super.key,
    required this.onBack,
    this.pageIndicator = '1/1',
  });

  final VoidCallback onBack;
  final String pageIndicator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: AppSizes.topBarButton,
              height: AppSizes.topBarButton,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textOnDark),
                tooltip: 'Back',
              ),
            ),
            Text(
              'Adjust',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs / 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.textOnDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                pageIndicator,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textOnDarkMuted,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
