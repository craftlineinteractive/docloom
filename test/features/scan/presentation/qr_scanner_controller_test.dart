import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/qr_scanner_providers.dart';
import 'package:docloom/features/scan/data/fake_qr_decoder.dart';

void main() {
  group('QrScanController', () {
    late ProviderContainer container;
    late FakeQrDecoder fakeDecoder;

    setUp(() {
      fakeDecoder = FakeQrDecoder();
      container = ProviderContainer(
        overrides: [
          qrDecoderProvider.overrideWithValue(fakeDecoder),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial state has empty result and sheet closed', () {
      final state = container.read(qrScanControllerProvider);
      expect(state.isProcessing, isFalse);
      expect(state.isSheetOpen, isFalse);
      expect(state.currentResult, isNull);
    });

    test('successful scan opens sheet and sets result', () async {
      fakeDecoder.nextResult = 'https://docloom.app';
      final dummyFrame = Uint8List(100);

      await container.read(qrScanControllerProvider.notifier).processFrame(dummyFrame, 10, 10);

      final state = container.read(qrScanControllerProvider);
      expect(state.isSheetOpen, isTrue);
      expect(state.currentResult, isNotNull);
      expect(state.currentResult!.rawText, 'https://docloom.app');
      expect(state.lastScannedText, 'https://docloom.app');
    });

    test('duplicate frame within 2 seconds is ignored', () async {
      fakeDecoder.nextResult = 'https://docloom.app';
      final dummyFrame = Uint8List(100);

      final notifier = container.read(qrScanControllerProvider.notifier);
      await notifier.processFrame(dummyFrame, 10, 10);
      expect(container.read(qrScanControllerProvider).isSheetOpen, isTrue);

      // Dismiss the bottom sheet
      notifier.dismissResult();
      expect(container.read(qrScanControllerProvider).isSheetOpen, isFalse);

      // Wait 100 ms (less than 2s duplicate window, but after throttle)
      await Future<void>.delayed(const Duration(milliseconds: 210));

      // Same QR text presented again within 2s
      await notifier.processFrame(dummyFrame, 10, 10);

      // Must NOT re-open sheet
      expect(container.read(qrScanControllerProvider).isSheetOpen, isFalse);
    });

    test('different QR code triggers immediately', () async {
      fakeDecoder.nextResult = 'https://docloom.app/first';
      final dummyFrame = Uint8List(100);

      final notifier = container.read(qrScanControllerProvider.notifier);
      await notifier.processFrame(dummyFrame, 10, 10);
      notifier.dismissResult();

      await Future<void>.delayed(const Duration(milliseconds: 210));

      // Different QR text
      fakeDecoder.nextResult = 'https://docloom.app/second';
      await notifier.processFrame(dummyFrame, 10, 10);

      expect(container.read(qrScanControllerProvider).isSheetOpen, isTrue);
      expect(container.read(qrScanControllerProvider).currentResult!.rawText, 'https://docloom.app/second');
    });
  });
}
