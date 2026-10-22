import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/capture_mode_provider.dart';
import 'book_dialog_row.dart';

class BookPopupDialog extends ConsumerWidget {
  const BookPopupDialog({super.key});

  static Future<BookScanType?> show(BuildContext context) {
    return showDialog<BookScanType>(
      context: context,
      barrierColor: AppColors.cameraOverlay,
      builder: (_) => const BookPopupDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(bookScanTypeProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan Book',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              BookDialogRow(
                title: 'Single page',
                caption: 'Scan one book page at a time',
                icon: LucideIcons.fileText,
                isSelected: currentType == BookScanType.singlePage,
                onTap: () {
                  ref
                      .read(bookScanTypeProvider.notifier)
                      .setType(BookScanType.singlePage);
                  Navigator.of(context).pop(BookScanType.singlePage);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              BookDialogRow(
                title: 'Two pages (auto split)',
                caption: 'Captures both pages and separates them',
                icon: LucideIcons.bookOpen,
                isSelected: currentType == BookScanType.twoPagesSplit,
                onTap: () {
                  ref
                      .read(bookScanTypeProvider.notifier)
                      .setType(BookScanType.twoPagesSplit);
                  Navigator.of(context).pop(BookScanType.twoPagesSplit);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
