import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/opencv_image_engine.dart';
import '../../domain/quad.dart';
import '../../domain/scan_filter.dart';
import 'filter_preset_card.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.previewPath,
    required this.quad,
    required this.rotation,
    required this.selectedFilterId,
    required this.onSelectFilter,
  });

  final String previewPath;
  final Quad quad;
  final int rotation;
  final String selectedFilterId;
  final ValueChanged<String> onSelectFilter;

  static const double thumbnailSide = 160;

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  final Map<String, Uint8List> _thumbnails = {};
  late String _selectedFilterId;

  @override
  void initState() {
    super.initState();
    _selectedFilterId = widget.selectedFilterId;
    _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    final engine = ref.read(engineProvider);
    for (final filter in ScanFilter.all) {
      try {
        final bytes = await engine.renderPreview(
          previewPath: widget.previewPath,
          quad: widget.quad,
          rotation: widget.rotation,
          filterId: filter.id,
          maxSide: FilterBottomSheet.thumbnailSide.toInt(),
        );
        if (mounted) setState(() => _thumbnails[filter.id] = bytes);
      } catch (_) {}
    }
  }

  void _onTap(String filterId) {
    setState(() => _selectedFilterId = filterId);
    widget.onSelectFilter(filterId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${ScanFilter.all.length} Presets',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ScanFilter.all.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: FilterPresetCard(
                    filter: filter,
                    isSelected: filter.id == _selectedFilterId,
                    thumbnailBytes: _thumbnails[filter.id],
                    onTap: () => _onTap(filter.id),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
