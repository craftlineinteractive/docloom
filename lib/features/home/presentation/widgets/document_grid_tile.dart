import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import 'document_card.dart';
import 'round_checkbox.dart';

class DocumentGridTile extends StatelessWidget {
  const DocumentGridTile({
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
      padding: const EdgeInsets.all(AppSpacing.sm),
      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      color: AppColors.pageBackdrop,
                      child: PageThumbnail(relativePath: item.coverPath),
                    ),
                  ),
                ),
                if (selectable)
                  Positioned(
                    top: AppSpacing.xs,
                    left: AppSpacing.xs,
                    child: RoundCheckbox(isSelected: isSelected),
                  ),
                if (!selectable && item.isFavorite)
                  const Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: Icon(LucideIcons.heart, size: 16, color: AppColors.danger),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.date,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: const BoxDecoration(
                  color: AppColors.pageBackdrop,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
                child: Text(
                  item.pageCount,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
              ),
              if (!selectable) ...[
                const SizedBox(width: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: onOptionsPressed,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(LucideIcons.moreVertical, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
