import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/capture_mode_provider.dart';
import '../domain/capture_mode.dart';
import 'widgets/book_popup_dialog.dart';
import 'widgets/id_card_popup_dialog.dart';
import 'widgets/photo_size_popup_dialog.dart';

class CameraModeRow extends ConsumerWidget {
  const CameraModeRow({super.key});

  static Future<void> showModePopup(
      BuildContext context, CaptureMode mode) async {
    switch (mode) {
      case CaptureMode.photo:
        await PhotoSizePopupDialog.show(context);
        break;
      case CaptureMode.idCard:
        await IdCardPopupDialog.show(context);
        break;
      case CaptureMode.book:
        await BookPopupDialog.show(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMode = ref.watch(captureModeProvider);
    final visibleModes = CaptureMode.values.where((m) => m.visible).toList();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: visibleModes.map((mode) {
              final isSelected = mode == activeMode;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: InkWell(
                  onTap: () {
                    if (isSelected && mode.hasPopup) {
                      showModePopup(context, mode);
                    } else {
                      ref.read(captureModeProvider.notifier).setMode(mode);
                      if (mode.hasPopup) {
                        showModePopup(context, mode);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.primaryTint.withAlpha(50),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(120),
                              width: 1,
                            ),
                          )
                        : null,
                    child: Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textOnDark
                            : AppColors.textOnDarkMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
