import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/photo_size_providers.dart';
import '../../application/scanner_controller_provider.dart';
import '../../domain/package_quad_adapter.dart';
import '../../domain/scan_session.dart';
import '../adjust/adjust_result.dart';
import '../adjust/adjust_screen.dart';
import 'review_dialogs.dart';

abstract final class ReviewActionsHelper {
  static Future<void> cropPage({
    required BuildContext context,
    required WidgetRef ref,
    required ScanSession session,
    required int currentIndex,
  }) async {
    final page = session.pages[currentIndex];
    final photoSize = page.photoSizeId != null
        ? ref.read(photoSizesProvider.notifier).findSize(page.photoSizeId!)
        : null;
    final sc = ref.read(betterScannerControllerProvider);
    final rawPath = (page.packagePage != null && sc != null)
        ? (sc.originalPath(page.packagePage!) ?? page.capturePath)
        : page.capturePath;
    final res = await Navigator.of(context).push<AdjustResult>(
      MaterialPageRoute(
        builder: (_) => AdjustScreen(
          previewPath: rawPath,
          importedPath: rawPath,
          rawCapturePath: rawPath,
          initialQuad: page.quad,
          initialRotation: page.rotation,
          initialFilterId: page.filterId,
          pageIndicator: '${currentIndex + 1}/${session.pages.length}',
          mode: page.mode,
          photoSize: photoSize,
        ),
      ),
    );
    if (res != null && context.mounted) {
      final clamped = res.quad.clamp01();
      if (page.packagePage != null && sc != null) {
        await sc.setPageCrop(page.packagePage!, clamped.toPackageQuad());
        await sc.setPageEnhancement(page.packagePage!, filterIdToEnhancement(res.filterId));
      }
      final n = ref.read(scanSessionProvider.notifier);
      n.updateCrop(currentIndex, clamped);
      n.setRotation(currentIndex, res.rotation);
      n.setFilter(currentIndex, res.filterId);
    }
  }

  static Future<void> rotatePage({
    required WidgetRef ref,
    required ScanSession session,
    required int currentIndex,
  }) async {
    final p = session.pages[currentIndex];
    final sc = ref.read(betterScannerControllerProvider);
    if (p.packagePage != null && sc != null) {
      await sc.rotatePage(p.packagePage!, quarterTurns: 1);
    }
    ref.read(scanSessionProvider.notifier).setRotation(currentIndex, (p.rotation + 90) % 360);
  }

  static Future<void> selectFilter({
    required WidgetRef ref,
    required ScanSession session,
    required int currentIndex,
    required String filterId,
  }) async {
    final p = session.pages[currentIndex];
    final sc = ref.read(betterScannerControllerProvider);
    if (p.packagePage != null && sc != null) {
      await sc.setPageEnhancement(p.packagePage!, filterIdToEnhancement(filterId));
    }
    ref.read(scanSessionProvider.notifier).setFilter(currentIndex, filterId);
  }

  static Future<void> applyFilterToAll({
    required WidgetRef ref,
    required ScanSession session,
    required int currentIndex,
  }) async {
    final p = session.pages[currentIndex];
    final sc = ref.read(betterScannerControllerProvider);
    if (sc != null) {
      for (final pg in session.pages) {
        if (pg.packagePage != null) {
          await sc.setPageEnhancement(pg.packagePage!, filterIdToEnhancement(p.filterId));
        }
      }
    }
    ref.read(scanSessionProvider.notifier).setFilterForAll(p.filterId);
  }

  static Future<int?> deletePage({
    required BuildContext context,
    required WidgetRef ref,
    required ScanSession session,
    required int currentIndex,
  }) async {
    final page = session.pages[currentIndex];
    final sc = ref.read(betterScannerControllerProvider);
    if (session.pages.length > 1) {
      if (await ReviewDialogs.showDeletePageDialog(context, currentIndex + 1)) {
        if (page.packagePage != null && sc != null) {
          await sc.deletePage(page.packagePage!);
        }
        ref.read(scanSessionProvider.notifier).removePage(currentIndex);
        final len = ref.read(scanSessionProvider).pages.length;
        return currentIndex.clamp(0, len - 1);
      }
    } else if (await ReviewDialogs.showDiscardScanDialog(context, 1)) {
      ref.read(scanSessionProvider.notifier).discard();
      if (context.mounted) Navigator.of(context).pop();
    }
    return null;
  }

  static Future<Map<String, Uint8List>> loadThumbnails({
    required WidgetRef ref,
    required ScanSessionPage page,
  }) async {
    final pkgPage = page.packagePage;
    final sc = ref.read(betterScannerControllerProvider);
    if (pkgPage == null || sc == null) return const {};
    try {
      final thumbs = await sc.renderEnhancementThumbnails(pkgPage, size: 220);
      final map = <String, Uint8List>{};
      if (thumbs.isNotEmpty) map['original'] = thumbs[0];
      if (thumbs.length > 1) map['auto_enhance'] = thumbs[1];
      if (thumbs.length > 2) map['vivid_light'] = thumbs[2];
      if (thumbs.length > 3) map['black_white'] = thumbs[3];
      if (thumbs.length > 4) map['grayscale'] = thumbs[4];
      return map;
    } catch (_) {
      return const {};
    }
  }
}

