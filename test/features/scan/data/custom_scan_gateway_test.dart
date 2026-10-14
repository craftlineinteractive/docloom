import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/app/router/app_router.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/custom_scan_gateway.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/domain/scan_gateway.dart';

void main() {
  testWidgets('CustomScanGateway pushes /scan/camera and awaits outcome', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(FakeCameraService()),
          cameraPermissionServiceProvider.overrideWithValue(FakeCameraPermissionService()),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    final future = const CustomScanGateway().scan(pageLimit: 50);
    await tester.pumpAndSettle();

    appRouter.pop(const ScanCancelled());
    await tester.pumpAndSettle();

    final outcome = await future;
    expect(outcome, isA<ScanCancelled>());
  });
}
