import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/data/fake_edge_detector.dart';
import 'package:docloom/features/scan/data/fake_image_engine.dart';
import 'package:docloom/features/scan/data/opencv_edge_detector.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/domain/image_engine.dart';
import 'package:docloom/features/scan/domain/scan_gateway.dart';
import 'package:docloom/features/scan/presentation/adjust/adjust_screen.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';

Widget _buildApp({
  required FakeCameraService camera,
  required FakeCameraPermissionService permission,
  FakeImageEngine? engine,
  void Function(ScanOutcome? outcome)? onPopped,
}) {
  return ProviderScope(
    overrides: [
      cameraServiceProvider.overrideWithValue(camera),
      cameraPermissionServiceProvider.overrideWithValue(permission),
      edgeDetectorProvider.overrideWithValue(FakeEdgeDetector()),
      if (engine != null) engineProvider.overrideWithValue(engine),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.of(ctx).push<ScanOutcome>(
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
              onPopped?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('lifecycle dispose and re-initialize works', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(camera.initializeCount, equals(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();

    expect(camera.disposeCount, equals(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(camera.initializeCount, equals(2));
  });

  testWidgets('double tap on shutter triggers single capture', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    final engine = FakeImageEngine()..completer = Completer<ImageSize>();

    await tester.pumpWidget(_buildApp(camera: camera, permission: permission, engine: engine));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Tap shutter twice rapidly
    await tester.tap(find.byType(GestureDetector).last);
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).last);
    await tester.pump();

    expect(camera.takePictureCount, equals(1));
    engine.completer!.complete(const ImageSize(width: 100, height: 100));
    await tester.pumpAndSettle();

    expect(find.byType(AdjustScreen), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraScreen), findsOneWidget);
  });

  testWidgets('back returns ScanCancelled', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    ScanOutcome? outcome;

    await tester.pumpWidget(_buildApp(
      camera: camera,
      permission: permission,
      onPopped: (o) => outcome = o,
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(outcome, isA<ScanCancelled>());
  });
}
