import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_icon_button.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
  });

  final String? title;
  final Widget child;

  static const double _handleWidth = 48;
  static const double _handleHeight = 4;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: _handleWidth,
                height: _handleHeight,
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  AppIconButton(
                    icon: LucideIcons.x,
                    tooltip: 'Close',
                    size: 20,
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            child,
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  String? title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (sheetContext) => AppBottomSheet(
      title: title,
      child: child,
    ),
  );
}
