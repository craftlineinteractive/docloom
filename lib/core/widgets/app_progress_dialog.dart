import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppProgressDialog extends StatelessWidget {
  const AppProgressDialog({
    super.key,
    required this.message,
    this.messageListenable,
  });

  final String message;
  final ValueListenable<String>? messageListenable;

  Widget _buildText(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        );
    if (messageListenable != null) {
      return ValueListenableBuilder<String>(
        valueListenable: messageListenable!,
        builder: (context, val, _) => Text(val, style: style),
      );
    }
    return Text(message, style: style);
  }

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
              Expanded(child: _buildText(context)),
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
  ValueListenable<String>? messageListenable,
  required Future<T> Function() task,
}) async {
  var isDialogPopped = false;
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  if (navigator == null) return task();

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => AppProgressDialog(
      message: message,
      messageListenable: messageListenable,
    ),
  ).then((_) => isDialogPopped = true);

  try {
    return await task();
  } finally {
    if (!isDialogPopped) {
      navigator.pop();
    }
  }
}
