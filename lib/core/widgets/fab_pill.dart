import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class FabPill extends StatelessWidget {
  const FabPill({
    super.key,
    required this.onCamera,
    required this.onAdd,
  });

  final VoidCallback onCamera;
  final VoidCallback onAdd;

  static const double _buttonSize = 56;
  static const double _dividerHeight = 24;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    const pillRadius = BorderRadius.all(Radius.circular(AppRadius.pill));

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: pillRadius,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: pillRadius,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Scan document',
              button: true,
              child: Tooltip(
                message: 'Scan document',
                child: SizedBox(
                  width: _buttonSize,
                  height: _buttonSize,
                  child: InkWell(
                    onTap: onCamera,
                    child: const Center(
                      child: Icon(
                        LucideIcons.camera,
                        color: AppColors.surface,
                        size: _iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: _dividerHeight,
              color: AppColors.surface.withValues(alpha: 0.38),
            ),
            Semantics(
              label: 'Import',
              button: true,
              child: Tooltip(
                message: 'Import',
                child: SizedBox(
                  width: _buttonSize,
                  height: _buttonSize,
                  child: InkWell(
                    onTap: onAdd,
                    child: const Center(
                      child: Icon(
                        LucideIcons.plus,
                        color: AppColors.surface,
                        size: _iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
