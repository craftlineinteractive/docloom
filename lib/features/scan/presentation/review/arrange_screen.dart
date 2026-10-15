import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/scan_session.dart';
import 'arrange_card.dart';

class ArrangeScreen extends ConsumerWidget {
  const ArrangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(scanSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Arrange pages',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 36,
            color: AppColors.primaryTint.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Long press, then drag to reorder',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemCount: session.pages.length,
              itemBuilder: (context, index) {
                final page = session.pages[index];
                return DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    if (details.data != index) {
                      ref.read(scanSessionProvider.notifier).reorder(details.data, index);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isTarget = candidateData.isNotEmpty;
                    return LongPressDraggable<int>(
                      data: index,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Transform.rotate(
                          angle: 0.03,
                          child: Transform.scale(
                            scale: 1.05,
                            child: SizedBox(
                              width: 150,
                              height: 185,
                              child: ArrangeCard(
                                previewPath: page.previewPath,
                                number: index + 1,
                                isDragging: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: ArrangeCard(
                          previewPath: page.previewPath,
                          number: index + 1,
                        ),
                      ),
                      child: Container(
                        decoration: isTarget
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.primary, width: 2),
                              )
                            : null,
                        child: ArrangeCard(
                          previewPath: page.previewPath,
                          number: index + 1,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
