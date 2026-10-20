import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/camera_settings_provider.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';
import 'package:docloom/features/scan/presentation/widgets/camera_settings_grid_panel.dart';

Widget _buildApp({
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: CameraScreen()),
  );
}

void main() {
  testWidgets('panel opens and closes via gear, Close button, and back button', (tester) async {
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

    expect(find.byType(CameraSettingsGridPanel), findsNothing);
    expect(container.read(autoCaptureSuspendedProvider), isFalse);

    // Open via gear
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(CameraSettingsGridPanel), findsOneWidget);
    expect(container.read(autoCaptureSuspendedProvider), isTrue);

    // Close via gear
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(CameraSettingsGridPanel), findsNothing);
    expect(container.read(autoCaptureSuspendedProvider), isFalse);

    // Open via gear, close via Close button
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(CameraSettingsGridPanel), findsOneWidget);
    await tester.tap(find.byKey(const Key('camera_settings_close_button')));
    await tester.pumpAndSettle();
    expect(find.byType(CameraSettingsGridPanel), findsNothing);

    // Open via gear, close via top bar back button without popping screen
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(CameraSettingsGridPanel), findsOneWidget);
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(CameraSettingsGridPanel), findsNothing);
    expect(find.byType(CameraScreen), findsOneWidget);
  });

  testWidgets('renders exactly 6 visible tiles in order and hidden tiles never render', (tester) async {
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

    final expectedOrder = [
      'Auto Crop',
      'Color Filter',
      'Home Screen',
      'Spirit Level',
      'Scan Quality',
      'Auto Capture\nTime',
    ];

    for (final title in expectedOrder) {
      expect(find.text(title), findsOneWidget);
    }

    expect(find.text('Capture Sound'), findsNothing);
    expect(find.text('Focus Sound'), findsNothing);
    expect(find.text('Image Rotation'), findsNothing);
    expect(find.byKey(const Key('setting_tile_settings')), findsNothing);
  });

  testWidgets('toggles flip state and value text for Auto Crop and Spirit Level', (tester) async {
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

    expect(container.read(cameraSettingsProvider).autoCrop, isTrue);
    expect(find.text('On'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('setting_tile_auto_crop')));
    await tester.pumpAndSettle();
    expect(container.read(cameraSettingsProvider).autoCrop, isFalse);
    expect(container.read(autoCropEnabledProvider), isFalse);
    expect(find.text('Off'), findsOneWidget);

    await tester.tap(find.byKey(const Key('setting_tile_spirit_level')));
    await tester.pumpAndSettle();
    expect(container.read(cameraSettingsProvider).spiritLevel, isFalse);
    expect(find.text('Off'), findsNWidgets(2));
  });
}
