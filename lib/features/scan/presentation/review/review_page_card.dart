import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/image_engine.dart';
import '../../domain/scan_session_page.dart';

class ReviewPageCard extends StatelessWidget {
  const ReviewPageCard({
    super.key,
    required this.page,
    required this.engine,
  });

  final ScanSessionPage page;
  final ImageEngine engine;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: FutureBuilder<Uint8List>(
          key: ValueKey('${page.id}_${page.rotation}_${page.filterId}_${page.quad.hashCode}'),
          future: engine.renderPreview(
            previewPath: page.previewPath,
            quad: page.quad,
            rotation: page.rotation,
            filterId: page.filterId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
              );
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            );
          },
        ),
      ),
    );
  }
}
