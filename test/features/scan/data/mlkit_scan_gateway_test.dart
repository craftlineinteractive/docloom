import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/mlkit_scan_gateway.dart';
import 'package:docloom/features/scan/domain/scan_gateway.dart';

void main() {
  test('MlKitScanGateway returns ScanFailure when not on Android', () async {
    if (!Platform.isAndroid) {
      const gateway = MlKitScanGateway();
      final outcome = await gateway.scan(pageLimit: 50);
      expect(outcome, isA<ScanFailure>());
      final failure = outcome as ScanFailure;
      expect(failure.message, equals('Scanning is only available on Android'));
    }
  });
}
