import '../../../app/router/app_router.dart';
import '../../../app/router/routes.dart';
import '../domain/scan_gateway.dart';

class CustomScanGateway implements ScanGateway {
  const CustomScanGateway();

  @override
  Future<ScanOutcome> scan({required int pageLimit}) async {
    final outcome = await appRouter.push<ScanOutcome>(Routes.scanCamera);
    return outcome ?? const ScanCancelled();
  }
}
