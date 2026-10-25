import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AdjustCropContainer extends StatelessWidget {
  const AdjustCropContainer({
    super.key,
    required this.rotation,
    required this.child,
  });

  final int rotation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ColoredBox(
        color: AppColors.cameraBlack,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: RotatedBox(
            quarterTurns: (rotation ~/ 90) % 4,
            child: child,
          ),
        ),
      ),
    );
  }
}

class AdjustHintText extends StatelessWidget {
  const AdjustHintText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.info, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Drag the points to adjust the borders.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
