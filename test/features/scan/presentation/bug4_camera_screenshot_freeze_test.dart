import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/data/fake_edge_detector.dart';
import 'package:docloom/features/scan/data/opencv_edge_detector.dart';
import 'package:docloom/features/scan/presentation/camera_permission_view.dart';
import 'package:docloom/features/scan/presentation/camera_init_coordinator.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';

Widget _buildApp({
  required FakeCameraService camera,
  required FakeCameraPermissionService permission,
}) {
  return ProviderScope(
    overrides: [
      cameraServiceProvider.overrideWithValue(camera),
      cameraPermissionServiceProvider.overrideWithValue(permission),
      edgeDetectorProvider.overrideWithValue(FakeEdgeDetector()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    CameraInitCoordinator.resetForTesting();
  });

  tearDown(() {
    CameraInitCoordinator.stopWatchdog();
  });

  group('Bug 4 Camera Screenshot and Lifecycle Watchdog Tests', () {
    testWidgets('inactive then resumed keeps the same controller without disposing', (tester) async {
      final camera = FakeCameraService();
      final permission = FakeCameraPermissionService();

      await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(camera.initializeCount, equals(1));
      expect(camera.disposeCount, equals(0));

      // Simulate screenshot (AppLifecycleState.inactive)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(milliseconds: 100));

      // Must NOT dispose camera
      expect(camera.disposeCount, equals(0));
      expect(camera.isInitialized, isTrue);

      // Return from screenshot (AppLifecycleState.resumed)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 100));

      // Controller is retained and not re-initialized
      expect(camera.initializeCount, equals(1));
      expect(camera.disposeCount, equals(0));

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    });

    testWidgets('paused then resumed re-initializes exactly once', (tester) async {
      final camera = FakeCameraService();
      final permission = FakeCameraPermissionService();

      await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(camera.initializeCount, equals(1));

      // Paused (app goes to background)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();

      expect(camera.disposeCount, equals(1));
      expect(camera.isInitialized, isFalse);

      // Resumed (app returns to foreground)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Must re-initialize exactly once
      expect(camera.initializeCount, equals(2));
      expect(camera.isInitialized, isTrue);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    });

    testWidgets('stalled stream triggers one re-init, then retry view on second stall', (tester) async {
      final camera = FakeCameraService();
      final permission = FakeCameraPermissionService();

      await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(camera.initializeCount, equals(1));

      // Simulate stream stall (> 2s without frames)
      camera.lastFrameTime = DateTime.now().subtract(const Duration(seconds: 3));
      // Pump watchdog timer tick
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Triggered one re-init
      expect(camera.initializeCount, equals(2));

      // Simulate second stall after re-init
      camera.lastFrameTime = DateTime.now().subtract(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Second stall shows retry view
      expect(find.byType(CameraErrorView), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    });
  });
}
