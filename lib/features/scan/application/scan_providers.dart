import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_providers.dart';
import '../../../core/widgets/app_progress_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../data/custom_scan_gateway.dart';
import '../data/plugin_camera_permission_service.dart';
import '../data/plugin_camera_service.dart';
import '../domain/camera_permission_service.dart';
import '../domain/camera_service.dart';
import '../domain/scan_gateway.dart';
import 'scan_save_service.dart';

enum ScanState { idle, scanning, saving }

final scanSaveServiceProvider = Provider<ScanSaveService>((ref) {
  return ScanSaveService(
    ref.watch(documentRepositoryProvider),
    ref.watch(fileStoreProvider),
  );
});

final scanGatewayProvider = Provider<ScanGateway>((ref) {
  return const CustomScanGateway();
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = PluginCameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

final cameraPermissionServiceProvider =
    Provider<CameraPermissionService>((ref) {
  return const PluginCameraPermissionService();
});

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => ScanState.idle;

  Future<void> startScan({
    BuildContext? context,
    String? folderId,
    void Function(String message)? onToast,
  }) async {
    if (state != ScanState.idle) return;
    state = ScanState.scanning;

    try {
      final gateway = ref.read(scanGatewayProvider);
      final outcome = await gateway.scan(pageLimit: AppConfig.scanPageLimit);
      switch (outcome) {
        case ScanSuccess(:final pages, :final suggestedName):
          state = ScanState.saving;
          try {
            final saveService = ref.read(scanSaveServiceProvider);
            if (context != null && context.mounted) {
              await showAppProgressDialog<void>(
                context: context,
                message: 'Saving ${pages.length} pages...',
                task: () => saveService.save(
                  pages: pages,
                  folderId: folderId,
                  name: suggestedName,
                ),
              );
            } else {
              await saveService.save(
                pages: pages,
                folderId: folderId,
                name: suggestedName,
              );
            }
            ref.refreshLibrary();
            _showToast('Saved ${pages.length} pages', onToast);
          } catch (_) {
            _showToast('Failed to save document. Please try again.', onToast);
          }
        case ScanCancelled():
          break;
        case ScanFailure(:final message):
          _showToast(message, onToast);
      }
    } catch (_) {
      _showToast('Scanner unavailable. Please try again.', onToast);
    } finally {
      state = ScanState.idle;
    }
  }

  void _showToast(String message, void Function(String message)? onToast) {
    if (onToast != null) {
      onToast(message);
    } else {
      showAppToastGlobal(message);
    }
  }
}

final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);
