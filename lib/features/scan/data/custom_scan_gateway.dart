import '../domain/scan_gateway.dart';

class CustomScanGateway implements ScanGateway {
  const CustomScanGateway();

  @override
  Future<ScanOutcome> scan({required int pageLimit}) async {
    return const ScanFailure('Camera screen arrives in 4C');
  }
}
