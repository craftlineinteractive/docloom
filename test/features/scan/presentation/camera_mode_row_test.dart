import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/application/capture_mode_provider.dart';
import 'package:docloom/features/scan/domain/capture_mode.dart';
import 'package:docloom/features/scan/presentation/camera_mode_row.dart';
import 'package:docloom/features/scan/presentation/widgets/book_popup_dialog.dart';
import 'package:docloom/features/scan/presentation/widgets/id_card_popup_dialog.dart';
import 'package:docloom/features/scan/presentation/widgets/photo_size_popup_dialog.dart';

Widget _buildModeRow([CaptureMode initialMode = CaptureMode.document]) {
  return ProviderScope(
    overrides: [
      captureModeProvider.overrideWith(() => CaptureModeNotifier(initialMode)),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: Center(child: CameraModeRow()),
      ),
    ),
  );
}

void main() {
  testWidgets('renders all 5 visible camera modes in order', (tester) async {
    await tester.pumpWidget(_buildModeRow());
    expect(find.text('ID Card'), findsOneWidget);
    expect(find.text('Document'), findsOneWidget);
    expect(find.text('Book'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
    expect(find.text('QR Scanner'), findsOneWidget);
    expect(find.text('OCR Text'), findsNothing);
  });

  testWidgets('tapping ID Card tab when active opens IdCardPopupDialog', (tester) async {
    await tester.pumpWidget(_buildModeRow(CaptureMode.idCard));
    await tester.tap(find.text('ID Card'));
    await tester.pumpAndSettle();
    expect(find.byType(IdCardPopupDialog), findsOneWidget);
  });

  testWidgets('tapping Book tab when active opens BookPopupDialog', (tester) async {
    await tester.pumpWidget(_buildModeRow(CaptureMode.book));
    await tester.tap(find.text('Book'));
    await tester.pumpAndSettle();
    expect(find.byType(BookPopupDialog), findsOneWidget);
  });

  testWidgets('tapping Photo tab when active opens PhotoSizePopupDialog', (tester) async {
    await tester.pumpWidget(_buildModeRow(CaptureMode.photo));
    await tester.tap(find.text('Photo'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoSizePopupDialog), findsOneWidget);
  });
}
