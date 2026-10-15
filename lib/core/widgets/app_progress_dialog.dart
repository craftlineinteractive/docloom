import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppProgressDialog extends StatelessWidget {
  const AppProgressDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T> showAppProgressDialog<T>({
  required BuildContext context,
  required String message,
  required Future<T> Function() task,
}) async {
  var isDialogPopped = false;
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => AppProgressDialog(message: message),
  ).then((_) => isDialogPopped = true);

  try {
    return await task();
  } finally {
    if (!isDialogPopped) {
      navigator.pop();
    }
  }
}
