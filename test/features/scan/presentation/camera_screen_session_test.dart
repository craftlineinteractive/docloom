import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';
import 'package:docloom/features/scan/presentation/widgets/camera_session_slots.dart';

void main() {
  late Directory tempDir;
  late String dummyFile;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('cam_session_test_');
    dummyFile = '${tempDir.path}/preview.jpg';
    File(dummyFile).writeAsBytesSync([1, 2, 3]);
  });

  tearDownAll(() {
    try { tempDir.deleteSync(recursive: true); } catch (_) {}
  });

  Widget buildApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: CameraScreen(),
      ),
    );
  }

  testWidgets('camera slot visibility reflects session pages', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(camera),
        cameraPermissionServiceProvider.overrideWithValue(permission),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    expect(find.byType(CameraThumbnailSlot), findsNothing);
    expect(find.byType(CameraCheckSlot), findsNothing);

    container.read(scanSessionProvider.notifier).addPage(
      ScanSessionPage(
        id: 'p1',
        capturePath: dummyFile,
        previewPath: dummyFile,
        quad: Quad.unit(),
        rotation: 0,
        filterId: 'vivid_light',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CameraThumbnailSlot), findsOneWidget);
    expect(find.byType(CameraCheckSlot), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('back confirmation dialog on non-empty session with Save and Exit and Discard', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(camera),
        cameraPermissionServiceProvider.overrideWithValue(permission),
      ],
    );
    addTearDown(container.dispose);

    container.read(scanSessionProvider.notifier).addPage(
      ScanSessionPage(
        id: 'p1',
        capturePath: dummyFile,
        previewPath: dummyFile,
        quad: Quad.unit(),
        rotation: 0,
        filterId: 'vivid_light',
      ),
    );

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Save or Discard?'), findsOneWidget);
    expect(find.text('Save and Exit'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(CameraScreen), findsOneWidget);
    expect(container.read(scanSessionProvider).pages.length, equals(1));

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).pages, isEmpty);
  });
}
