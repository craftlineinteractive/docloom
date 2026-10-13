import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../application/library_actions.dart';
import 'folder_palette_row.dart';

class FolderColorDialog extends ConsumerWidget {
  const FolderColorDialog({
    super.key,
    required this.folderId,
    required this.currentColorIndex,
  });

  final String folderId;
  final int currentColorIndex;

  static Future<void> show(
    BuildContext context, {
    required String folderId,
    required int currentColorIndex,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) => FolderColorDialog(
          folderId: folderId,
          currentColorIndex: currentColorIndex,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Change color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FolderPaletteRow(
              selectedIndex: currentColorIndex,
              onSelect: (i) async {
                Navigator.of(context).pop();
                try {
                  await ref.read(libraryActionsProvider).setFolderColor(
                        id: folderId,
                        colorIndex: i,
                      );
                  ref.refreshLibrary();
                } on AppException catch (e) {
                  if (context.mounted) showAppToast(context, e.message);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
