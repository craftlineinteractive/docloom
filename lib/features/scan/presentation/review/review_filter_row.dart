import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/scan_filter.dart';
import '../adjust/filter_preset_card.dart';

class ReviewFilterSubRow extends StatelessWidget {
  const ReviewFilterSubRow({
    super.key,
    required this.selectedFilterId,
    required this.onSelectFilter,
    required this.onApplyToAll,
    this.thumbnails = const {},
  });

  final String selectedFilterId;
  final ValueChanged<String> onSelectFilter;
  final VoidCallback onApplyToAll;
  final Map<String, Uint8List> thumbnails;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ScanFilter.presets.map((filter) {
                final isSelected = filter.id == selectedFilterId;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: FilterPresetCard(
                    filter: filter,
                    isSelected: isSelected,
                    thumbnailBytes: thumbnails[filter.id],
                    onTap: () => onSelectFilter(filter.id),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: onApplyToAll,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.copyCheck, size: 16, color: AppColors.primary),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Apply to all pages',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
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
