import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/data/fake_edge_detector.dart';
import 'package:docloom/features/scan/data/opencv_edge_detector.dart';
import 'package:docloom/features/scan/domain/camera_service.dart';
import 'package:docloom/features/scan/presentation/camera_init_coordinator.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';

class _SlowCameraService extends FakeCameraService {
  Completer<void>? initGate;

  @override
  Future<void> initialize({
    CameraPreset preset = CameraPreset.max,
    CameraLens lens = CameraLens.back,
  }) async {
    if (initGate != null) {
      await initGate!.future;
    }
    await super.initialize(preset: preset, lens: lens);
  }
}

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
            child: const Text('Open Camera'),
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

  group('Bug 2 Camera Reopen and Lifecycle Tests', () {
    testWidgets('open, close, open again shows a preview with fake camera', (tester) async {
      final camera = FakeCameraService();
      final permission = FakeCameraPermissionService();

      await tester.pumpWidget(_buildApp(camera: camera, permission: permission));

      // Open 1
      await tester.tap(find.text('Open Camera'));
      await tester.pumpAndSettle();
      expect(find.byType(CameraScreen), findsOneWidget);
      expect(camera.initializeCount, equals(1));
      expect(camera.isInitialized, isTrue);

      // Close 1 (back navigation)
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(CameraScreen), findsNothing);
      expect(camera.disposeCount, equals(1));
      expect(camera.isInitialized, isFalse);

      // Open 2 (reopen camera)
      await tester.tap(find.text('Open Camera'));
      await tester.pumpAndSettle();
      expect(find.byType(CameraScreen), findsOneWidget);
      expect(camera.initializeCount, equals(2));
      expect(camera.isInitialized, isTrue);

      // Clean up
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    });

    test('overlapping init and dispose never leaves a disposed controller in use', () async {
      final camera = _SlowCameraService();
      final gate = Completer<void>();
      camera.initGate = gate;

      // Start init 1 that will pause inside initialize
      final init1 = CameraInitCoordinator.initialize(
        camera: camera,
        lens: CameraLens.back,
        isMounted: () => true,
      );

      // While init 1 is paused in initialize, call dispose
      final disp = CameraInitCoordinator.dispose(camera: camera);

      // And call init 2 with a normal camera
      final camera2 = FakeCameraService();
      final init2 = CameraInitCoordinator.initialize(
        camera: camera2,
        lens: CameraLens.back,
        isMounted: () => true,
      );

      // Release init 1
      gate.complete();

      final r1 = await init1;
      await disp;
      final r2 = await init2;

      // Stale init 1 must be ignored
      expect(r1, isFalse);
      // Init 2 must succeed
      expect(r2, isTrue);
      // Camera 2 must remain initialized and NOT left disposed
      expect(camera2.isInitialized, isTrue);
      expect(camera2.disposeCount, equals(0));
    });
  });
}
