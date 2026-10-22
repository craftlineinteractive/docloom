import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/photo_size_providers.dart';
import '../../domain/photo_size.dart';
import 'add_photo_size_dialog.dart';
import 'photo_size_card.dart';
import 'photo_size_dialog_footer.dart';

class PhotoSizePopupDialog extends ConsumerWidget {
  const PhotoSizePopupDialog({super.key});

  static Future<PhotoSize?> show(BuildContext context) {
    return showDialog<PhotoSize>(
      context: context,
      barrierColor: AppColors.cameraOverlay,
      builder: (_) => const PhotoSizePopupDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoSizesProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ID Photo Editor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Select photo size',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Long press and drag to rearrange',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: state.sizes.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    mainAxisExtent: AppSizes.photoCardHeight,
                  ),
                  itemBuilder: (context, index) {
                    final size = state.sizes[index];
                    final isSelected = size.id == state.selectedId;
                    return DragTarget<int>(
                      onAcceptWithDetails: (details) {
                        ref
                            .read(photoSizesProvider.notifier)
                            .reorder(details.data, index);
                      },
                      builder: (context, _, _) {
                        return LongPressDraggable<int>(
                          data: index,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 160,
                              height: AppSizes.photoCardHeight,
                              child: PhotoSizeCard(
                                size: size,
                                isSelected: isSelected,
                                onTap: () {},
                                onRemove: () {},
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: PhotoSizeCard(
                              size: size,
                              isSelected: isSelected,
                              onTap: () {},
                              onRemove: () {},
                            ),
                          ),
                          child: PhotoSizeCard(
                            size: size,
                            isSelected: isSelected,
                            onTap: () => ref
                                .read(photoSizesProvider.notifier)
                                .select(size.id),
                            onRemove: () => ref
                                .read(photoSizesProvider.notifier)
                                .remove(size.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PhotoSizeDialogFooter(
                onClose: () => Navigator.of(context).pop(),
                onAddNew: () async {
                  final newSize = await AddPhotoSizeDialog.show(context);
                  if (newSize != null) {
                    await ref.read(photoSizesProvider.notifier).add(newSize);
                  }
                },
                onSelect: () =>
                    Navigator.of(context).pop(state.selectedSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
