import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.onCamera, required this.onImport});

  final VoidCallback onCamera;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
              child: const Center(child: Icon(LucideIcons.scanLine, size: 40, color: AppColors.primary)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Scan your first document',
              style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Convert paper documents, receipts, and notes into high-quality PDFs',
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ActionHintChip(icon: LucideIcons.camera, label: 'Tap camera to scan', onTap: onCamera),
            const SizedBox(height: AppSpacing.sm),
            _ActionHintChip(icon: LucideIcons.imagePlus, label: 'Tap + to import files', onTap: onImport),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.lock, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text('ON-DEVICE EDGE PROCESSING', style: AppTypography.textTheme.labelSmall?.copyWith(letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionHintChip extends StatelessWidget {
  const _ActionHintChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(label, style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ),
              const Icon(LucideIcons.arrowRight, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
