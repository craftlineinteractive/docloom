import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/ocr_providers.dart';
import 'ocr_language_picker_sheet.dart';

class OcrLanguagePill extends ConsumerWidget {
  const OcrLanguagePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLang = ref.watch(activeOcrLanguageProvider);

    return InkWell(
      onTap: () => OcrLanguagePickerSheet.show(context),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.cameraBlack.withAlpha(180),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.gridLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.languages,
              size: 14,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${activeLang.name} (${activeLang.code.toUpperCase()})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(width: AppSpacing.hairline),
            const Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: AppColors.textOnDarkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
