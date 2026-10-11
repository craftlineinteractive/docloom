import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppToastContent extends StatelessWidget {
  const AppToastContent({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.surface,
          ),
    );
  }
}

void showAppToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      content: AppToastContent(message: message),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppColors.primaryLight,
              onPressed: onAction,
            )
          : null,
    ),
  );
}
