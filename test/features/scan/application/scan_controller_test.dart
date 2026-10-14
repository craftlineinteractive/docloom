import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/constants/app_config.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/custom_scan_gateway.dart';
import 'package:docloom/features/scan/domain/scan_gateway.dart';
import 'package:docloom/features/scan/domain/scanned_page.dart';

class FakeScanGateway implements ScanGateway {
  FakeScanGateway(this.outcome);
  ScanOutcome outcome;
  int callCount = 0;
  int? lastPageLimit;
  Completer<ScanOutcome>? completer;

  @override
  Future<ScanOutcome> scan({required int pageLimit}) async {
    callCount++;
    lastPageLimit = pageLimit;
    if (completer != null) return completer!.future;
    return outcome;
  }
}

class ThrowingScanGateway implements ScanGateway {
  int callCount = 0;

  @override
  Future<ScanOutcome> scan({required int pageLimit}) async {
    callCount++;
    throw Exception('Native crash');
  }
}

void main() {
  test('Success shows toast with page count and returns to idle', () async {
    final fake = FakeScanGateway(const ScanSuccess([
      ScannedPage(originalPath: '/p1.jpg'),
      ScannedPage(originalPath: '/p2.jpg'),
    ]));
    final container = ProviderContainer(
      overrides: [scanGatewayProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final toasts = <String>[];
    expect(container.read(scanControllerProvider), equals(ScanState.idle));

    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);

    expect(fake.callCount, equals(1));
    expect(fake.lastPageLimit, equals(AppConfig.scanPageLimit));
    expect(toasts, equals(['Scanned 2 pages']));
    expect(container.read(scanControllerProvider), equals(ScanState.idle));
  });

  test('Cancel shows nothing and returns to idle', () async {
    final fake = FakeScanGateway(const ScanCancelled());
    final container = ProviderContainer(
      overrides: [scanGatewayProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final toasts = <String>[];
    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);

    expect(fake.callCount, equals(1));
    expect(toasts, isEmpty);
    expect(container.read(scanControllerProvider), equals(ScanState.idle));
  });

  test('Failure shows message as toast and returns to idle', () async {
    final fake = FakeScanGateway(const ScanFailure('Camera permission denied'));
    final container = ProviderContainer(
      overrides: [scanGatewayProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final toasts = <String>[];
    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);

    expect(fake.callCount, equals(1));
    expect(toasts, equals(['Camera permission denied']));
    expect(container.read(scanControllerProvider), equals(ScanState.idle));
  });

  test('Two quick taps call the gateway only once', () async {
    final fake = FakeScanGateway(const ScanCancelled());
    final completer = Completer<ScanOutcome>();
    fake.completer = completer;

    final container = ProviderContainer(
      overrides: [scanGatewayProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(scanControllerProvider.notifier);
    final future1 = notifier.startScan();
    expect(container.read(scanControllerProvider), equals(ScanState.scanning));

    final future2 = notifier.startScan();
    expect(fake.callCount, equals(1));

    completer.complete(const ScanCancelled());
    await Future.wait([future1, future2]);

    expect(fake.callCount, equals(1));
    expect(container.read(scanControllerProvider), equals(ScanState.idle));
  });

  test('State returns to idle when the gateway throws an unhandled error', () async {
    final throwing = ThrowingScanGateway();
    final container = ProviderContainer(
      overrides: [scanGatewayProvider.overrideWithValue(throwing)],
    );
    addTearDown(container.dispose);

    final toasts = <String>[];
    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);

    expect(throwing.callCount, equals(1));
    expect(toasts.length, equals(1));
    expect(toasts.first, contains('Scanner unavailable'));
    expect(container.read(scanControllerProvider), equals(ScanState.idle));
  });

  test('CustomScanGateway default returns camera arrives in 4C', () async {
    const gateway = CustomScanGateway();
    final outcome = await gateway.scan(pageLimit: 50);
    expect(outcome, isA<ScanFailure>());
    expect((outcome as ScanFailure).message, equals('Camera screen arrives in 4C'));
  });
}
