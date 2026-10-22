import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/qr_scanner_providers.dart';
import 'package:docloom/features/scan/data/fake_url_launcher_service.dart';
import 'package:docloom/features/scan/domain/qr_content_parser.dart';
import 'package:docloom/features/scan/presentation/camera_bottom_bar.dart';
import 'package:docloom/features/scan/presentation/widgets/qr_cutout_overlay.dart';
import 'package:docloom/features/scan/presentation/widgets/qr_result_bottom_sheet.dart';
import 'package:docloom/features/scan/presentation/widgets/qr_url_confirm_dialog.dart';

void main() {
  group('QR Scanner Widgets', () {
    testWidgets('QrCutoutOverlay renders captions', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QrCutoutOverlay())));
      expect(find.text('Align QR code within the frame'), findsOneWidget);
      expect(find.text('Automatic scanning enabled'), findsOneWidget);
    });

    testWidgets('CameraBottomBar shows Auto Detect badge in QR mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraBottomBar(
            onCapture: () {},
            isEnabled: true,
            isQrMode: true,
          ),
        ),
      ));
      expect(find.text('Auto Detect'), findsOneWidget);
    });

    testWidgets('QrUrlConfirmDialog shows full URL and pops result', (tester) async {
      final uri = Uri.parse('https://docloom.app/verify?id=42');
      bool? dialogResult;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async => dialogResult = await QrUrlConfirmDialog.show(ctx, uri),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Open Link?'), findsOneWidget);
      expect(find.text(uri.toString()), findsOneWidget);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });

    testWidgets('QrResultBottomSheet opens link with confirm dialog', (tester) async {
      final fakeLauncher = FakeUrlLauncherService();
      final content = QrContentParser.parse('https://docloom.app/welcome');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [urlLauncherServiceProvider.overrideWithValue(fakeLauncher)],
          child: MaterialApp(
            home: Scaffold(
              body: QrResultBottomSheet(content: content, onScanAgain: () {}),
            ),
          ),
        ),
      );

      expect(find.text('Website Link'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Open Link?'), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Open')));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUris, contains(Uri.parse('https://docloom.app/welcome')));
    });

    testWidgets('QrResultBottomSheet for unsafe schemes does not show Open button', (tester) async {
      final fakeLauncher = FakeUrlLauncherService();
      final content = QrContentParser.parse('javascript:alert(1)');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [urlLauncherServiceProvider.overrideWithValue(fakeLauncher)],
          child: MaterialApp(
            home: Scaffold(
              body: QrResultBottomSheet(content: content, onScanAgain: () {}),
            ),
          ),
        ),
      );

      expect(find.text('Open'), findsNothing);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('QrResultBottomSheet for Wi-Fi displays Copy Password button', (tester) async {
      final content = QrContentParser.parse('WIFI:T:WPA;S:HomeWiFi;P:SuperSecret;;');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QrResultBottomSheet(content: content, onScanAgain: () {}),
            ),
          ),
        ),
      );

      expect(find.text('Wi-Fi Network'), findsOneWidget);
      expect(find.text('Copy Password'), findsOneWidget);
    });
  });
}
