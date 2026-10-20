import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/camera_settings_provider.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/domain/camera_settings.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';

Widget _buildApp({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: CameraScreen()),
  );
}

void main() {
  testWidgets('Color Filter picker writes CameraSettings', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(camera),
        cameraPermissionServiceProvider.overrideWithValue(permission),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container: container));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(container.read(cameraSettingsProvider).filterId, equals('vivid_light'));

    await tester.tap(find.byKey(const Key('setting_tile_color_filter')));
    await tester.pumpAndSettle();

    expect(find.text('Color Filter'), findsWidgets);
    expect(find.text('Grayscale'), findsOneWidget);

    await tester.tap(find.text('Grayscale'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(container.read(cameraSettingsProvider).filterId, equals('grayscale'));
    expect(find.text('Grayscale'), findsOneWidget);
  });

  testWidgets('Scan Quality picker writes CameraSettings', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(camera),
        cameraPermissionServiceProvider.overrideWithValue(permission),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container: container));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(container.read(cameraSettingsProvider).scanQuality, equals(ScanQuality.high));

    await tester.tap(find.byKey(const Key('setting_tile_scan_quality')));
    await tester.pumpAndSettle();

    expect(find.text('Scan Quality'), findsWidgets);
    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Largest files'), findsOneWidget);

    await tester.tap(find.text('Max'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(container.read(cameraSettingsProvider).scanQuality, equals(ScanQuality.max));
    expect(find.text('Max'), findsOneWidget);
  });

  testWidgets('Auto Capture Time picker writes CameraSettings', (tester) async {
    final camera = FakeCameraService();
    final permission = FakeCameraPermissionService();
    final container = ProviderContainer(
      overrides: [
        cameraServiceProvider.overrideWithValue(camera),
        cameraPermissionServiceProvider.overrideWithValue(permission),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildApp(container: container));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(container.read(cameraSettingsProvider).autoCaptureTimeSeconds, equals(2));

    await tester.tap(find.byKey(const Key('setting_tile_auto_capture_time')));
    await tester.pumpAndSettle();

    expect(find.text('Auto Capture Time'), findsOneWidget);
    expect(find.text('3 sec'), findsOneWidget);

    await tester.tap(find.text('3 sec'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(container.read(cameraSettingsProvider).autoCaptureTimeSeconds, equals(3));
    expect(find.text('3 sec'), findsOneWidget);
  });
}
