import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

class DocumentItem {
  const DocumentItem({
    required this.name,
    required this.date,
    required this.pageCount,
    this.coverPath,
    this.isFavorite = false,
  });

  final String name;
  final String date;
  final String pageCount;
  final String? coverPath;
  final bool isFavorite;
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onOptionsPressed,
  });

  final DocumentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap ?? () {},
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PageThumbnail(relativePath: item.coverPath),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      item.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.pageBackdrop,
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                      ),
                      child: Text(
                        item.pageCount,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      LucideIcons.fileText,
                      size: 14,
                      color: AppColors.danger,
                    ),
                    if (item.isFavorite) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        LucideIcons.heart,
                        size: 14,
                        color: AppColors.danger,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: LucideIcons.moreVertical,
            tooltip: 'Document options',
            color: AppColors.textSecondary,
            onPressed: onOptionsPressed ?? () {},
          ),
        ],
      ),
    );
  }
}
