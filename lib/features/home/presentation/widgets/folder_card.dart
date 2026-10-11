import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

class FolderItem {
  const FolderItem({
    required this.name,
    required this.itemCountAndDate,
    required this.color,
  });

  final String name;
  final String itemCountAndDate;
  final Color color;
}

class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final FolderItem item;
  final VoidCallback? onTap;

  static const double _iconBoxSize = 44;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap ?? () {},
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _iconBoxSize,
            height: _iconBoxSize,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.md),
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.folder,
                color: item.color,
                size: _iconSize,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs / 2),
          Text(
            item.itemCountAndDate,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
