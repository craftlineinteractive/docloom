import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/scan_gateway.dart';
import '../../domain/scan_session.dart';
import '../review/review_screen.dart';

abstract final class CameraSlotsHelper {
  static Widget? buildLeft({
    required BuildContext context,
    required ScanSession session,
    required bool isRetake,
    void Function(ScanOutcome outcome)? onOutcome,
  }) {
    if (isRetake || session.pages.isEmpty) return null;
    return CameraThumbnailSlot(
      previewPath: session.pages.last.previewPath,
      count: session.pages.length,
      onTap: () async {
        final outcome = await Navigator.of(context).push<ScanOutcome>(
          MaterialPageRoute(
            builder: (_) => ReviewScreen(initialIndex: session.pages.length - 1),
          ),
        );
        if (outcome != null) {
          onOutcome?.call(outcome);
        }
      },
    );
  }

  static Widget? buildRight({
    required BuildContext context,
    required ScanSession session,
    required bool isRetake,
    VoidCallback? onCheck,
  }) {
    if (isRetake || session.pages.isEmpty) return null;
    return CameraCheckSlot(
      onTap: onCheck ??
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReviewScreen()),
              ),
    );
  }
}

class CameraThumbnailSlot extends StatelessWidget {
  const CameraThumbnailSlot({
    super.key,
    required this.previewPath,
    required this.count,
    required this.onTap,
  });

  final String previewPath;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: AppSizes.bottomSlotButton,
            height: AppSizes.bottomSlotButton,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.textOnDark, width: 2),
              color: AppColors.textPrimary,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              File(previewPath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.pageBackdrop),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textOnDark, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textOnDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraCheckSlot extends StatelessWidget {
  const CameraCheckSlot({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: AppSizes.bottomSlotButton,
        height: AppSizes.bottomSlotButton,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Center(
          child: Icon(LucideIcons.check, color: AppColors.textOnDark, size: 24),
        ),
      ),
    );
  }
}
