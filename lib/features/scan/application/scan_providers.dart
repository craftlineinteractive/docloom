import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/widgets/app_toast.dart';
import '../data/mlkit_scan_gateway.dart';
import '../domain/scan_gateway.dart';

enum ScanState { idle, scanning, saving }

final scanGatewayProvider = Provider<ScanGateway>((ref) {
  return const MlKitScanGateway();
});

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => ScanState.idle;

  Future<void> startScan({
    String? folderId,
    void Function(String message)? onToast,
  }) async {
    if (state != ScanState.idle) return;
    state = ScanState.scanning;

    try {
      final gateway = ref.read(scanGatewayProvider);
      final outcome = await gateway.scan(pageLimit: AppConfig.scanPageLimit);
      switch (outcome) {
        case ScanSuccess(:final imagePaths):
          _showToast('Scanned ${imagePaths.length} pages (saving comes in 4B)', onToast);
        case ScanCancelled():
          break;
        case ScanFailure(:final message):
          _showToast(message, onToast);
      }
    } catch (_) {
      _showToast(
        'Scanner not available. Check that Google Play services is installed and up to date.',
        onToast,
      );
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
