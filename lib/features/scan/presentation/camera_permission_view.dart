import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/camera_permission_service.dart';

class CameraPermissionView extends StatelessWidget {
  const CameraPermissionView({
    super.key,
    required this.state,
    required this.onRequest,
    required this.onOpenSettings,
    required this.onBack,
  });

  final CameraPermissionState state;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isPermanent = state == CameraPermissionState.permanentlyDenied;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: IconButton(
                  icon: const Icon(LucideIcons.x),
                  tooltip: 'Cancel',
                  onPressed: onBack,
                ),
              ),
            ),
            Expanded(
              child: EmptyState(
                icon: isPermanent
                    ? LucideIcons.settings
                    : LucideIcons.camera,
                title: isPermanent
                    ? 'Permission Denied'
                    : 'Camera Access Needed',
                body: isPermanent
                    ? 'Camera permission has been permanently denied. Please open system settings to allow access.'
                    : 'docLoom needs camera access to capture and scan your documents.',
                actionLabel: isPermanent ? 'Open Settings' : 'Allow Camera',
                onAction: isPermanent ? onOpenSettings : onRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraErrorView extends StatelessWidget {
  const CameraErrorView({
    super.key,
    required this.onRetry,
    required this.onBack,
  });

  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: IconButton(
                  icon: const Icon(LucideIcons.x),
                  tooltip: 'Cancel',
                  onPressed: onBack,
                ),
              ),
            ),
            Expanded(
              child: EmptyState(
                icon: LucideIcons.alertCircle,
                title: 'Camera Error',
                body: 'Failed to initialize the camera hardware. Please check your device and try again.',
                actionLabel: 'Retry',
                onAction: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
