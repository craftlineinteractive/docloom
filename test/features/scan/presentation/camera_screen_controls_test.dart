import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/domain/camera_service.dart';
import 'package:docloom/features/scan/presentation/camera_flash_menu.dart';
import 'package:docloom/features/scan/presentation/camera_grid.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';
import 'package:docloom/features/scan/presentation/focus_ring.dart';

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
  testWidgets('flash menu toggles and sets flash mode', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.byType(CameraFlashMenu), findsNothing);
    await tester.tap(find.byTooltip('Flash'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraFlashMenu), findsOneWidget);
    await tester.tap(find.text('On'));
    await tester.pumpAndSettle();

    expect(camera.currentFlash, equals(CameraFlash.on));
    expect(find.byType(CameraFlashMenu), findsNothing);
  });

  testWidgets('grid button toggles rule of thirds overlay', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.byType(CameraGrid), findsNothing);
    await tester.tap(find.byTooltip('Grid'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraGrid), findsOneWidget);
    await tester.tap(find.byTooltip('Grid'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraGrid), findsNothing);
  });

  testWidgets('flip button switches camera and hides when single lens', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch Camera'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch Camera'));
    await tester.pumpAndSettle();

    expect(camera.currentLens, equals(CameraLens.front));
  });

  testWidgets('flip button hidden when only one lens exists', (tester) async {
    final camera = FakeCameraService(availableLenses: [CameraLens.back]);
    final permission = FakeCameraPermissionService();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch Camera'), findsNothing);
  });

  testWidgets('tap to focus triggers ring and focus call', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 300));
    await tester.pump();

    expect(find.byType(FocusRing), findsOneWidget);
    expect(camera.lastFocusPoint, isNotNull);
  });
}
