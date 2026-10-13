import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';

class PageThumbnail extends ConsumerWidget {
  const PageThumbnail({
    super.key,
    this.relativePath,
    this.size = AppSizes.thumbnail,
  });

  final String? relativePath;
  final double size;

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: const Icon(
        LucideIcons.fileText,
        size: 24,
        color: AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = relativePath;
    if (path == null || path.isEmpty) {
      return _buildPlaceholder();
    }

    final fileStore = ref.watch(fileStoreProvider);
    final File file;
    try {
      file = fileStore.resolve(path);
      if (!file.existsSync()) {
        return _buildPlaceholder();
      }
    } catch (_) {
      return _buildPlaceholder();
    }

    final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          cacheWidth: cacheWidth,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      ),
    );
  }
}
