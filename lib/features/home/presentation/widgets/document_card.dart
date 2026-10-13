import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import 'round_checkbox.dart';

class DocumentItem {
  const DocumentItem({
    required this.name,
    required this.date,
    required this.pageCount,
    this.coverPath,
    this.isFavorite = false,
    this.folderName,
  });

  final String name;
  final String date;
  final String pageCount;
  final String? coverPath;
  final bool isFavorite;
  final String? folderName;
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.onOptionsPressed,
    this.selectable = false,
    this.isSelected = false,
    this.onSelectToggle,
  });

  final DocumentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOptionsPressed;
  final bool selectable;
  final bool isSelected;
  final VoidCallback? onSelectToggle;

  @override
  Widget build(BuildContext context) {
    final effectiveTap = selectable ? (onSelectToggle ?? onTap) : onTap;

    return AppCard(
      onTap: effectiveTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(AppSpacing.md),
      border: isSelected ? Border.all(color: AppColors.primary, width: AppSpacing.hairline) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (selectable) ...[
            RoundCheckbox(isSelected: isSelected),
            const SizedBox(width: AppSpacing.md),
          ],
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
                if (item.folderName != null && item.folderName!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.hairline),
                  Row(
                    children: [
                      const Icon(LucideIcons.folder, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          item.folderName!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      item.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
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
                    const Icon(LucideIcons.fileText, size: 14, color: AppColors.danger),
                    if (item.isFavorite) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(LucideIcons.heart, size: 14, color: AppColors.danger),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!selectable)
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
