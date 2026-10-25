import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:docloom/core/theme/app_colors.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/data/fake_camera_permission_service.dart';
import 'package:docloom/features/scan/data/fake_camera_service.dart';
import 'package:docloom/features/scan/domain/camera_service.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';
import 'package:docloom/features/scan/presentation/camera_screen.dart';

Widget _buildApp({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: CameraScreen()),
  );
}

void main() {
  testWidgets('flash cycles in order with icons per Frame D and no popover', (tester) async {
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

    expect(find.byIcon(LucideIcons.zapOff), findsOneWidget);
    expect(camera.currentFlash, equals(CameraFlash.off));

    await tester.tap(find.byTooltip('Flash: Off'));
    await tester.pumpAndSettle();
    expect(camera.currentFlash, equals(CameraFlash.on));
    expect(find.byTooltip('Flash: On'), findsOneWidget);
    final onIcon = tester.widget<Icon>(find.byIcon(LucideIcons.zap));
    expect(onIcon.color, equals(AppColors.primaryLight));

    await tester.tap(find.byTooltip('Flash: On'));
    await tester.pumpAndSettle();
    expect(camera.currentFlash, equals(CameraFlash.auto));
    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.byTooltip('Flash: Auto'));
    await tester.pumpAndSettle();
    expect(camera.currentFlash, equals(CameraFlash.off));
    expect(find.byIcon(LucideIcons.zapOff), findsOneWidget);
  });

  testWidgets('Home Screen asks confirmation when pages exist', (tester) async {
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

    container.read(scanSessionProvider.notifier).addPage(
      ScanSessionPage(
        id: 'p1',
        capturePath: 'dummy.jpg',
        previewPath: 'dummy_thumb.jpg',
        quad: Quad.unit(),
        rotation: 0,
        filterId: 'vivid_light',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('setting_tile_home_screen')));
    await tester.pumpAndSettle();

    expect(find.text('Save or Discard?'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Save or Discard?'), findsNothing);
    expect(container.read(scanSessionProvider).pages.isNotEmpty, isTrue);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setting_tile_home_screen')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(container.read(scanSessionProvider).pages.isEmpty, isTrue);
  });
}
