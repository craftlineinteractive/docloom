import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/camera_setting_tile.dart';

class CameraSettingsTileItem extends StatelessWidget {
  const CameraSettingsTileItem({super.key, required this.tile});

  final CameraSettingTile tile;

  Color get _iconColor {
    if (tile.isOn == true) return AppColors.primaryLight;
    if (tile.isOn == false) return AppColors.textSecondary;
    return AppColors.textOnDark;
  }

  Color get _valueColor {
    if (tile.isOn == true) return AppColors.primaryLight;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tile.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('setting_tile_${tile.id}'),
          onTap: tile.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppSizes.settingTileMinTouch,
              minHeight: AppSizes.settingTileMinTouch,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tile.icon,
                    size: AppSizes.settingTileIcon,
                    color: _iconColor,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tile.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textOnDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.hairline),
                  Text(
                    tile.valueText.isEmpty ? ' ' : tile.valueText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _valueColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
