import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/ocr_language.dart';

class OcrLanguageTile extends StatelessWidget {
  const OcrLanguageTile({
    super.key,
    required this.lang,
    required this.isSelected,
    required this.isDownloaded,
    required this.progress,
    required this.onTap,
  });

  final OcrLanguage lang;
  final bool isSelected;
  final bool isDownloaded;
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(
          lang.code.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
      title: Text(lang.name, style: AppTypography.textTheme.bodyMedium),
      subtitle: Text(
        lang.nativeName,
        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget _buildTrailing() {
    final p = progress;
    if (p != null) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: p, strokeWidth: 3),
            Text(
              '${(p * 100).toInt()}%',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    if (isSelected) {
      return const Icon(LucideIcons.check, color: AppColors.primary);
    }
    if (isDownloaded) {
      return const Icon(LucideIcons.circleCheck, color: AppColors.folderGreen, size: 20);
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.hairline,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.download, size: 12, color: AppColors.primary),
          const SizedBox(width: AppSpacing.hairline),
          Text(
            '${lang.sizeMb}MB',
            style: const TextStyle(fontSize: 11, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
