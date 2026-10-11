import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: cancelLabel,
                  variant: AppButtonVariant.text,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: confirmLabel,
                  variant: destructive
                      ? AppButtonVariant.danger
                      : AppButtonVariant.filled,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showAppDialog(
  BuildContext context, {
  required String title,
  required String body,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AppDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
}
