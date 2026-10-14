import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/domain/camera_permission_service.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';

Widget _buildApp({
  required FakeCameraService camera,
  required FakeCameraPermissionService permission,
}) {
  return ProviderScope(
    overrides: [
      cameraServiceProvider.overrideWithValue(camera),
      cameraPermissionServiceProvider.overrideWithValue(permission),
    ],
    child: const MaterialApp(
      home: CameraScreen(),
    ),
  );
}

void main() {
  testWidgets('notDetermined shows Camera Access Needed and Allow button',
      (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService(
      status: CameraPermissionState.notDetermined,
      requestResult: CameraPermissionState.granted,
    );

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.text('Camera Access Needed'), findsOneWidget);
    expect(find.text('Allow Camera'), findsOneWidget);

    await tester.tap(find.text('Allow Camera'));
    await tester.pumpAndSettle();

    expect(permission.requestPermissionCount, equals(1));
    expect(camera.initializeCount, equals(1));
  });

  testWidgets('denied status shows explanation and allow button requests',
      (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService(
      status: CameraPermissionState.denied,
      requestResult: CameraPermissionState.granted,
    );

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.text('Camera Access Needed'), findsOneWidget);
    expect(find.text('Allow Camera'), findsOneWidget);

    await tester.tap(find.text('Allow Camera'));
    await tester.pumpAndSettle();

    expect(permission.requestPermissionCount, equals(1));
  });

  testWidgets('permanentlyDenied shows Open Settings button',
      (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService(
      status: CameraPermissionState.permanentlyDenied,
    );

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.text('Permission Denied'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);

    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(permission.openSettingsCount, equals(1));
  });

  testWidgets('permission revoked while open transitions to denied',
      (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService(
      status: CameraPermissionState.granted,
    );

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fake_camera_preview')), findsOneWidget);

    // Revoke permission while app is open and simulate lifecycle resume
    permission.status = CameraPermissionState.denied;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Camera Access Needed'), findsOneWidget);
  });

  testWidgets('initialization failure shows CameraErrorView and retry works',
      (tester) async {
    final camera = FakeCameraService()..shouldFailInitialize = true;
    final permission = FakeCameraPermissionService(
      status: CameraPermissionState.granted,
    );

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.text('Camera Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    camera.shouldFailInitialize = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(camera.initializeCount, equals(2));
    expect(find.byKey(const ValueKey('fake_camera_preview')), findsOneWidget);
  });
}
