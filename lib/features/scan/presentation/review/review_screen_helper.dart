import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/scan_session.dart';
import '../camera_screen.dart';
import '../scan_finish_coordinator.dart';
import 'review_dialogs.dart';

abstract final class ReviewScreenHelper {
  static Future<void> onRetake(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) async {
    final newPage = await Navigator.of(context).push<ScanSessionPage>(
      MaterialPageRoute(
        builder: (_) => CameraScreen(retakePageIndex: currentIndex),
      ),
    );
    if (newPage != null && context.mounted) {
      ref
          .read(scanSessionProvider.notifier)
          .replacePage(currentIndex, newPage);
    }
  }

  static Future<void> onRename(
    BuildContext context,
    WidgetRef ref,
    ScanSession session,
  ) async {
    final name = await ReviewDialogs.showRenameScanDialog(
      context,
      session.name ?? 'docLoom Scan',
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      ref.read(scanSessionProvider.notifier).setName(name);
    }
  }

  static Future<void> onBack(
    BuildContext context,
    WidgetRef ref,
    ScanSession session,
  ) async {
    final act = await ReviewDialogs.showBackScanDialog(
      context,
      session.pages.length,
    );
    if (act == null || !context.mounted) return;
    if (act == BackScanAction.saveAndExit) {
      await onCheck(context, ref);
    } else {
      ref.read(scanSessionProvider.notifier).discard();
      Navigator.of(context).pop();
    }
  }

  static Future<void> onCheck(BuildContext context, WidgetRef ref) async {
    final success = await ScanFinishCoordinator.finish(
      context: context,
      ref: ref,
    );
    if (success != null && context.mounted) {
      Navigator.of(context).pop(success);
    }
  }
}
