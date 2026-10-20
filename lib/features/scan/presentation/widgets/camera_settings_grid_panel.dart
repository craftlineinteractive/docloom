import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/camera_settings_provider.dart';
import 'camera_settings_tile_item.dart';
import 'camera_settings_tiles_builder.dart';

class CameraSettingsGridPanel extends ConsumerWidget {
  const CameraSettingsGridPanel({
    super.key,
    required this.onClose,
    required this.onHomeScreenTap,
  });

  final VoidCallback onClose;
  final VoidCallback onHomeScreenTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(cameraSettingsProvider);
    final visibleTiles = CameraSettingsTilesBuilder.build(
      context: context,
      ref: ref,
      settings: settings,
      onHomeScreenTap: onHomeScreenTap,
    ).where((t) => t.visible).toList();

    return Container(
      key: const Key('camera_settings_grid_panel'),
      color: AppColors.cameraPanelOverlay,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: visibleTiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  mainAxisExtent: 96,
                ),
                itemBuilder: (context, index) {
                  return CameraSettingsTileItem(tile: visibleTiles[index]);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              key: const Key('camera_settings_close_button'),
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, AppSizes.bottomSlotButton),
                side: const BorderSide(color: AppColors.textOnDark, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
