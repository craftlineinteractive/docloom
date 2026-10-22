import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/capture_mode_provider.dart';
import 'id_card_option_card.dart';

class IdCardPopupDialog extends ConsumerWidget {
  const IdCardPopupDialog({super.key});

  static Future<IdCardScanType?> show(BuildContext context) {
    return showDialog<IdCardScanType>(
      context: context,
      barrierColor: AppColors.cameraOverlay,
      builder: (_) => const IdCardPopupDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(idCardScanTypeProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scan ID Card',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: IdCardOptionCard(
                      title: 'Single side',
                      caption: '1 side only',
                      icon: LucideIcons.idCard,
                      isSelected: currentType == IdCardScanType.singleSide,
                      onTap: () {
                        ref
                            .read(idCardScanTypeProvider.notifier)
                            .setType(IdCardScanType.singleSide);
                        Navigator.of(context).pop(IdCardScanType.singleSide);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: IdCardOptionCard(
                      title: 'Both sides',
                      caption: 'Front and back on one page',
                      icon: LucideIcons.copy,
                      isSelected: currentType == IdCardScanType.bothSides,
                      onTap: () {
                        ref
                            .read(idCardScanTypeProvider.notifier)
                            .setType(IdCardScanType.bothSides);
                        Navigator.of(context).pop(IdCardScanType.bothSides);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
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
