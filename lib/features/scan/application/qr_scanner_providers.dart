import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plugin_url_launcher_service.dart';
import '../data/zxing_qr_decoder.dart';
import '../domain/qr_content_parser.dart';
import '../domain/qr_decoder.dart';
import '../domain/url_launcher_service.dart';
import 'qr_scan_state.dart';

final qrDecoderProvider = Provider<QrDecoder>((ref) {
  return const ZxingQrDecoder();
});

final urlLauncherServiceProvider = Provider<UrlLauncherService>((ref) {
  return const PluginUrlLauncherService();
});

final qrScanControllerProvider =
    NotifierProvider<QrScanController, QrScanState>(QrScanController.new);

class QrScanController extends Notifier<QrScanState> {
  DateTime? _lastFrameTime;
  static const _frameThrottle = Duration(milliseconds: 200);
  static const _duplicateWindow = Duration(seconds: 2);

  @override
  QrScanState build() => const QrScanState();

  Future<void> processFrame(Uint8List gray, int width, int height) async {
    if (state.isProcessing || state.isSheetOpen) return;

    final now = DateTime.now();
    if (_lastFrameTime != null && now.difference(_lastFrameTime!) < _frameThrottle) {
      return;
    }
    _lastFrameTime = now;

    state = state.copyWith(isProcessing: true);
    try {
      final decoder = ref.read(qrDecoderProvider);
      final text = await decoder.decodeGray(gray, width, height);

      if (text != null && text.isNotEmpty) {
        final lastText = state.lastScannedText;
        final lastTime = state.lastScannedTime;
        final isDuplicate = lastText == text &&
            lastTime != null &&
            now.difference(lastTime) < _duplicateWindow;

        if (!isDuplicate) {
          try {
            await HapticFeedback.mediumImpact();
          } catch (_) {}
          final parsed = QrContentParser.parse(text);
          state = state.copyWith(
            isProcessing: false,
            isSheetOpen: true,
            currentResult: parsed,
            lastScannedText: text,
            lastScannedTime: now,
          );
          return;
        }
      }
    } catch (_) {}

    state = state.copyWith(isProcessing: false);
  }

  void dismissResult() {
    state = state.copyWith(
      clearResult: true,
      isSheetOpen: false,
      lastScannedTime: DateTime.now(),
    );
  }

  void resetDuplicateTracker() {
    state = const QrScanState();
  }
}
